/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Panel for sending AVAX and ARC20 token transactions.
AVMEPanel {
  id: sendPanel
  title: "Transaction Details"
  property string txTotalCoinStr
  property string info
  property string historyInfo
  property alias chosenAsset: assetCombobox.chosenAsset
  property string to: (chosenAsset.symbol != "AVAX")
    ? chosenAsset.address : txToInput.text
  property string coinValue: (chosenAsset.symbol != "AVAX")
    ? "0.000000000000000000" : txAmountInput.text
  property string tokenValue: (chosenAsset.symbol != "AVAX")
    ? txAmountInput.text : "0.000000000000000000"
  property string txData: (chosenAsset.symbol != "AVAX")
    ? buildTokenTransferData(
      txToInput.text, txAmountInput.text, chosenAsset.decimals
    ) : ""
  property string gas: txGasLimitInput.text
  property string gasPrice: txGasPriceInput.text
  property bool automaticGas
  property alias toInput: txToInput.text
  property alias sendBtn: btnMakeTx

  Connections {
    target: accountHeader
    function onUpdatedBalances() { refreshAssetBalance() }
  }

  function buildTokenTransferData(to, value, decimals) {
    var ethCallJson = ({})
    var weiValue = qmlApi.fixedPointToWei(value, decimals)
    ethCallJson["function"] = "transfer(address,uint256)"
    ethCallJson["args"] = []
    ethCallJson["args"].push(to)
    ethCallJson["args"].push(weiValue)
    ethCallJson["types"] = []
    ethCallJson["types"].push("address")
    ethCallJson["types"].push("uint*")
    var ethCallString = JSON.stringify(ethCallJson)
    var ABI = qmlApi.buildCustomABI(ethCallString)
    return ABI
  }

  function updateInfo() {
    info = "You will send <b>"
      + ((chosenAsset.symbol != "AVAX") ? tokenValue : coinValue)
      + " " + chosenAsset.symbol
      + "</b><br>to the address <b>" + to + "</b>"
    historyInfo = "Sent " + chosenAsset.symbol
  }

  function updateTxCost() {
    if (autoGasCheck.checked) {
      var calculatedGasPrice = +accountHeader.gasPrice + 15
      if (calculatedGasPrice > 225) {
        txGasPriceInput.text = 225
      } else {
        txGasPriceInput.text = calculatedGasPrice
      }
    }
    if (chosenAsset.symbol == "AVAX") {  // Coin
      automaticGas = false;
      if (autoLimitCheck.checked) { txGasLimitInput.text = "21000" }
      txTotalCoinStr = qmlSystem.calculateTransactionCost(
        txAmountInput.text, sendPanel.gas, sendPanel.gasPrice
      )
    } else {  // Token
      automaticGas = true;
      if (autoLimitCheck.checked) { txGasLimitInput.text = "70000" }
      txTotalCoinStr = qmlSystem.calculateTransactionCost(
        "0", sendPanel.gas, sendPanel.gasPrice
      )
    }
  }

  function refreshAssetBalance() {
    if (chosenAsset.symbol == "AVAX") {
      assetBalance.text = (accountHeader.coinRawBalance != "")
      ? "Balance: <b>" + accountHeader.coinRawBalance + " AVAX</b>"
      : "Loading asset balance..."
    } else {
      var asset = accountHeader.tokenList[chosenAsset.address]
      assetBalance.text = (asset != undefined)
      ? "Balance: <b>" + asset["rawBalance"]
      + " " + chosenAsset.symbol + "</b>"
      : "Loading asset balance..."
    }
  }

  Column {
    id: txDetailsColumn
    anchors {
      top: parent.top
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: 80
      bottomMargin: 20
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 25

    Row {
      id: assetRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 20

      Text {
        id: assetText
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "You will send"
      }
      AVMEAssetCombobox {
        id: assetCombobox
        Component.onCompleted: { updateTxCost(); refreshAssetBalance() }
        onActivated: { updateTxCost(); refreshAssetBalance() }
      }
    }

    Text {
      id: assetBalance
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Loading asset balance..."
    }

    AVMEInput {
      id: txToInput
      width: (parent.width * 0.9)
      anchors.left: parent.left
      validator: RegExpValidator { regExp: /0x[0-9a-fA-F]{40}/ }
      label: "To"
      placeholder: "Receiver address - e.g. 0x123456789ABCDEF..."
      AVMEButton {
        id: txContactsBtn
        width: (parent.parent.width * 0.1) - anchors.leftMargin
        height: parent.height
        anchors.left: parent.right
        anchors.leftMargin: 10
        text: ""
        onClicked: contactSelectPopup.open()
        Image {
          anchors.fill: parent
          anchors.margins: 10
          source: "qrc:/img/icons/inboxes.png"
          antialiasing: true
          smooth: true
          fillMode: Image.PreserveAspectFit
        }
      }
    }

    AVMEInput {
      id: txAmountInput
      width: (parent.width * 0.8)
      anchors.left: parent.left
      validator: RegExpValidator {
        regExp: qmlSystem.createTxRegExp(chosenAsset.decimals)
      }
      label: "Amount"
      placeholder: "Fixed point amount (e.g. 0.5)"
      onTextEdited: updateTxCost()

      AVMEButton {
        id: btnAmountMax
        width: (parent.parent.width * 0.2) - anchors.leftMargin
        anchors {
          left: parent.right
          leftMargin: 10
        }
        text: "Max"
        onClicked: {
          txAmountInput.text = (chosenAsset.symbol == "AVAX")
          ? qmlSystem.getRealMaxAVAXAmount(
            accountHeader.coinRawBalance, txGasLimitInput.text, sendPanel.gasPrice
          )
          : (accountHeader.tokenList[chosenAsset.address]["rawBalance"])
          updateTxCost()
        }
      }
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: txGasLimitInput
        width: (parent.parent.width * 0.5) - (parent.spacing / 2)
        validator: RegExpValidator { regExp: /[0-9]+/ }
        label: "Gas Limit (in Wei)"
        enabled: !autoLimitCheck.checked
        onTextEdited: updateTxCost()
      }
      AVMEInput {
        id: txGasPriceInput
        width: (parent.parent.width * 0.5) - (parent.spacing / 2)
        validator: RegExpValidator { regExp: /[0-9]+/ }
        enabled: !autoGasCheck.checked
        label: "Gas Price (in Gwei)"
        onTextEdited: updateTxCost()
      }
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMECheckbox {
        id: autoLimitCheck
        property string prev
        width: (parent.parent.width * 0.5) - parent.spacing
        checked: true
        enabled: true
        text: "Automatic gas limit"
        onClicked: {
          if (!txGasLimitInput.enabled) { // Disabled field (auto limit on)
            txGasLimitInput.text = prev
          } else { // Enabled field (auto limit off)
            prev = txGasLimitInput.text
          }
          updateTxCost()
        }
      }

      AVMECheckbox {
        id: autoGasCheck
        property string prev
        width: (parent.parent.width * 0.5) - parent.spacing
        checked: true
        enabled: true
        text: "Recommended fees"
        onClicked: {
          if (!txGasPriceInput.enabled) { // Disabled field (auto fee on)
            txGasPriceInput.text = prev
          } else {  // Enabled field (auto fee off)
            prev = txGasPriceInput.text
          }
          updateTxCost()
        }
      }
    }

    Text {
      id: costsText
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Total transaction costs:<br><b>" + txTotalCoinStr + " AVAX</b>"
    }

    AVMEButton {
      id: btnMakeTx
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Make Transaction"
      Timer { id: ledgerRetryTimer; interval: 250; onTriggered: btnMakeTx.checkLedger() }
      enabled: (
        txToInput.acceptableInput && txAmountInput.acceptableInput &&
        txGasLimitInput.acceptableInput && txGasPriceInput.acceptableInput &&
        +txAmountInput.text != 0 && +txGasLimitInput.text != 0 &&
        txGasPriceInput.text != 0
      )
    }
  }
}

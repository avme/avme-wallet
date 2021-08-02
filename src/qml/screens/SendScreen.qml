/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/popups"

/**
 * Screen for sending AVAX and ARC20 token transactions.
 */
Item {
  id: sendScreen
  property string txTotalCoinStr
  /*
  // TODO: delete this after the operation side is rewritten
  property string txOperationStr
  property string txTotalTokenStr
  property string txTotalLPStr
  Connections {
    target: QmlSystem
    function onOperationOverride(op, amountCoin, amountToken, amountLP) {
      changeOperation(op)
      txAmountCoinInput.text = amountCoin
      txAmountTokenInput.text = amountToken
      txAmountLPInput.text = amountLP
      txAmountCoinInput.enabled = false
      txAmountTokenInput.enabled = false
      txAmountLPInput.enabled = false
      autoLimitCheck.visible = false
      autoGasCheck.visible = false
      updateTxCost()
      switch (op) {
        case "Swap AVME -> AVAX":
          txTotalCoinStr = QmlSystem.calculateTransactionCost(
            "0", txGasLimitInput.text, txGasPriceInput.text
          )
          break;
      }
    }
  }

  function changeOperation(op) {
    // Clean all inputs first, then set the gas limit and enable only the required inputs
    txToInput.text = txAmountCoinInput.text = txAmountTokenInput.text = txAmountLPInput.text = ""
    txOperationStr = op
    txToInput.visible = (op == "Send AVAX" || op == "Send AVME")
    autoLimitCheck.checked = autoGasCheck.checked = true
    if (op == "Send AVAX") {
      txGasLimitInput.text = "21000"
    } else if (op == "Send AVME") {
      txGasLimitInput.text = "70000"
    } else if (op == "Swap AVAX -> AVME" || op == "Swap AVME -> AVAX") {
      txGasLimitInput.text = "180000"
    } else {
      txGasLimitInput.text = "250000"
    }
    txGasPriceInput.text = QmlSystem.getAutomaticFee()
    updateTxCost()
    switch (op) {
      // AVAX only
      case "Send AVAX":
      case "Swap AVAX -> AVME":
        txAmountCoinInput.visible = true
        txAmountTokenInput.visible = false
        txAmountLPInput.visible = false
        break;
      // AVME only
      case "Send AVME":
      case "Swap AVME -> AVAX":
        txAmountCoinInput.visible = false
        txAmountTokenInput.visible = true
        txAmountLPInput.visible = false
        break;
      // AVAX + AVME
      case "Add Liquidity":
        txAmountCoinInput.visible = true
        txAmountTokenInput.visible = true
        txAmountLPInput.visible = false
        break;
      // LP only
      case "Remove Liquidity":
      case "Stake LP":
      case "Stake Compound LP":
      case "Unstake LP":
        txAmountCoinInput.visible = false
        txAmountTokenInput.visible = false
        txAmountLPInput.visible = true
        break;
      case "Unstake Compound LP":
        txAmountCoinInput.visible = false
        txAmountTokenInput.visible = false
        txAmountLPInput.visible = true
        break;
      // Nothing
      case "Approve Exchange":
      case "Approve Liquidity":
      case "Approve Staking":
      case "Approve Compound":
      case "Harvest AVME":
      case "Reinvest AVME":
      case "Exit Staking":
        txAmountCoinInput.visible = false
        txAmountTokenInput.visible = false
        txAmountLPInput.visible = false
        break;
    }
  }
  */

  Connections {
    target: accountHeader
    function onUpdatedBalances() { assetBalance.refresh() }
  }

  Component.onCompleted: { updateTxCost(); assetBalance.refresh() }

  function updateTxCost() {
    if (autoGasCheck.checked) { txGasPriceInput.text = QmlSystem.getAutomaticFee() }
    if (chooseAssetPopup.chosenAssetAddress == "") {  // Coin
      if (autoLimitCheck.checked) { txGasLimitInput.text = "21000" }
      txTotalCoinStr = QmlSystem.calculateTransactionCost(
        txAmountInput.text, txGasLimitInput.text, txGasPriceInput.text
      )
    } else {  // Token
      if (autoLimitCheck.checked) { txGasLimitInput.text = "70000" }
      txTotalCoinStr = QmlSystem.calculateTransactionCost(
        "0", txGasLimitInput.text, txGasPriceInput.text
      )
    }
  }

  function checkTransactionFunds() {
    if (chooseAssetPopup.chosenAssetSymbol == "AVAX") {  // Coin
      var hasCoinFunds = !QmlSystem.hasInsufficientFunds(
        accountHeader.coinBalance, QmlSystem.calculateTransactionCost(
          txAmountInput.text, txGasLimitInput.text, txGasPriceInput.text
        ), 18
      )
      return hasCoinFunds
    } else { // Token
      var hasCoinFunds = !QmlSystem.hasInsufficientFunds(
        accountHeader.coinBalance, QmlSystem.calculateTransactionCost(
          "0", txGasLimitInput.text, txGasPriceInput.text
        ), 18
      )
      var hasTokenFunds = !QmlSystem.hasInsufficientFunds(
        accountHeader.tokenList[chooseAssetPopup.chosenAssetAddress]["balance"],
        txAmountInput.text, chooseAssetPopup.chosenAssetDecimals
      )
      return (hasCoinFunds && hasTokenFunds)
    }
  }

  // Panel for the transaction inputs
  AVMEPanel {
    id: txDetailsPanel
    width: (parent.width * 0.5)
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      margins: 10
    }
    title: "Transaction Details"

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
        Image {
          id: assetImage
          anchors.verticalCenter: parent.verticalCenter
          height: 48
          antialiasing: true
          smooth: true
          fillMode: Image.PreserveAspectFit
          source: {
            var avmeAddress = QmlSystem.getAVMEAddress()
            if (chooseAssetPopup.chosenAssetSymbol == "AVAX") {
              source: "qrc:/img/avax_logo.png"
            } else if (chooseAssetPopup.chosenAssetAddress == avmeAddress) {
              source: "qrc:/img/avme_logo.png"
            } else {
              var img = QmlSystem.getARC20TokenImage(chooseAssetPopup.chosenAssetAddress)
              source: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
            }
          }
        }
        Text {
          id: assetSymbol
          anchors.verticalCenter: parent.verticalCenter
          verticalAlignment: Text.AlignVCenter
          color: "#FFFFFF"
          font.bold: true
          font.pixelSize: 14.0
          text: chooseAssetPopup.chosenAssetSymbol
        }
        AVMEButton {
          id: assetBtn
          anchors.verticalCenter: parent.verticalCenter
          text: "Change Asset"
          onClicked: chooseAssetPopup.open()
        }
      }

      Text {
        id: assetBalance
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        function refresh() {
          if (chooseAssetPopup.chosenAssetSymbol == "AVAX") {
            text = (accountHeader.coinBalance != "")
            ? "Total amount: <b>" + accountHeader.coinBalance + " AVAX</b>"
            : "Loading asset balance..."
          } else {
            var asset = accountHeader.tokenList[chooseAssetPopup.chosenAssetAddress]
            text = (asset != undefined)
            ? "Total amount: <b>" + asset["balance"]
            + " " + chooseAssetPopup.chosenAssetSymbol + "</b>"
            : "Loading asset balance..."
          }
        }
      }

      AVMEInput {
        id: txToInput
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        validator: RegExpValidator { regExp: /0x[0-9a-fA-F]{40}/ }
        label: "To"
        placeholder: "Receiver address - e.g. 0x123456789ABCDEF..."
      }

      AVMEInput {
        id: txAmountInput
        width: (parent.width * 0.8)
        anchors.left: parent.left
        validator: RegExpValidator {
          regExp: QmlSystem.createTxRegExp(chooseAssetPopup.chosenAssetDecimals)
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
            txAmountInput.text = (chooseAssetPopup.chosenAssetSymbol == "AVAX")
            ? QmlSystem.getRealMaxAVAXAmount(
              accountHeader.coinBalance, txGasLimitInput.text, txGasPriceInput.text
            )
            : (+accountHeader.tokenList[chooseAssetPopup.chosenAssetAddress]["balance"])
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

        CheckBox {
          id: autoLimitCheck
          property string prev
          width: (parent.parent.width * 0.5) - parent.spacing
          checked: true
          enabled: true
          text: "Automatic gas limit"
          font.pixelSize: 14.0
          contentItem: Text {
            text: parent.text
            font.pixelSize: 14.0
            color: parent.checked ? "#FFFFFF" : "#888888"
            verticalAlignment: Text.AlignVCenter
            leftPadding: parent.indicator.width + parent.spacing
          }
          onClicked: {
            if (!txGasLimitInput.enabled) { // Disabled field (auto limit on)
              txGasLimitInput.text = prev
            } else { // Enabled field (auto limit off)
              prev = txGasLimitInput.text
            }
            updateTxCost()
          }
        }

        CheckBox {
          id: autoGasCheck
          property string prev
          width: (parent.parent.width * 0.5) - parent.spacing
          checked: true
          enabled: true
          text: "Recommended fees"
          font.pixelSize: 14.0
          contentItem: Text {
            text: parent.text
            font.pixelSize: 14.0
            color: parent.checked ? "#FFFFFF" : "#888888"
            verticalAlignment: Text.AlignVCenter
            leftPadding: parent.indicator.width + parent.spacing
          }
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
        onClicked: {
          if (!checkTransactionFunds()) {
            fundsPopup.open()
          } else if (txToInput.text.length != 42) {
            incorrectInputPopup.open()
          } else {
            // TODO: fix Ledger
            //if (QmlSystem.getLedgerFlag()) {
            //  checkLedger()
            //} else {
            //  confirmTxPopup.open()
            //}
            confirmTxPopup.open()
          }
        }
        /*
        function checkLedger() {
          var data = QmlSystem.checkForLedger()
          if (data.state) {
            ledgerFailPopup.close()
            ledgerRetryTimer.stop()
            txProgressPopup.open()
            QmlSystem.txStart(
              txOperationStr, txToInput.text,
              txAmountCoinInput.text, txAmountTokenInput.text, txAmountLPInput.text,
              txGasLimitInput.text, txGasPriceInput.text, ""
            )
          } else {
            ledgerFailPopup.info = data.message
            ledgerFailPopup.open()
            ledgerRetryTimer.start()
          }
        }
        */
      }
    }
  }

  // Popup for choosing an asset to send
  AVMEPopupAssetSelect {
    id: chooseAssetPopup
    onAboutToHide: { updateTxCost(); assetBalance.refresh() }
  }

  // Popup for confirming transaction
  AVMEPopupConfirmTx {
    id: confirmTxPopup
    isSameAddress: (txToInput.text == accountHeader.currentAddress)
    info: "You will send "
    + "<b>" + txAmountInput.text + " " + chooseAssetPopup.chosenAssetSymbol + "</b>"
    + " to the address<br><b>" + txToInput.text + "</b>"
    + "<br>Gas Limit: <b>"
    + QmlSystem.weiToFixedPoint(txGasLimitInput.text, 18) + " AVAX</b>"
    + "<br>Gas Price: <b>"
    + QmlSystem.weiToFixedPoint(txGasPriceInput.text, 9) + " AVAX</b>"
    okBtn.onClicked: {} // TODO
    /*
    function confirmPass() {
      if (!QmlSystem.checkWalletPass(pass)) {
        timer.start()
      } else {
        confirmTxPopup.close()
        txProgressPopup.open()
        QmlSystem.txStart(
          txOperationStr, txToInput.text,
          txAmountCoinInput.text, txAmountTokenInput.text, txAmountLPInput.text,
          txGasLimitInput.text, txGasPriceInput.text, pass
        )
        confirmTxPopup.clean()
      }
    }
    okBtn.onClicked: confirmPass()
    Shortcut {
      sequences: ["Enter", "Return"]
      onActivated: {
        if (confirmTxPopup.passFocus) { confirmTxPopup.confirmPass() }
      }
    }
    */
  }

  // Popup for insufficient funds
  // TODO: fix this popup type's centering
  AVMEPopupInfo {
    id: fundsPopup
    icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your inputs."
  }

  AVMEPopupInfo {
    id: incorrectInputPopup
    icon: "qrc:/img/warn.png"
    info: "Incorrect destination address. Please check your inputs."
  }

  // Popup for transaction progress
  AVMEPopupTxProgress {
    id: txProgressPopup
  }

  // Info popup for if communication with Ledger fails
  AVMEPopupInfo {
    id: ledgerFailPopup
    icon: "qrc:/img/warn.png"
    onAboutToHide: ledgerRetryTimer.stop()
    okBtn.text: "Close"
  }
}

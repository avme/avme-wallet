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

  Component.onCompleted: updateTxCost()

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

  // TODO: revise this when balances are working
  function checkTransactionFunds() {
    var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
    var hasCoinFunds = !QmlSystem.hasInsufficientFunds(
      "Coin", acc.balanceAVAX, QmlSystem.calculateTransactionCost(
        txTotalCoinStr.text, txGasLimitInput.text, txGasPriceInput.text
      )
    )
    var hasTokenFunds = !QmlSystem.hasInsufficientFunds(
      "Token", acc.balanceAVME, txTotalTokenStr.text
    )
    if (chooseAssetPopup.chosenAssetAddress == "") { // Coin
      return hasCoinFunds
    } else {  // Token
      return (hasCoinFunds && hasTokenFunds)
    }
  }

  AVMEAccountHeader {
    id: accountHeader
  }

  // Panel for the transaction inputs
  AVMEPanel {
    id: txDetailsPanel
    width: (parent.width * 0.5)
    anchors {
      top: accountHeader.bottom
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
      spacing: 30

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
            var avme = QmlSystem.getAVMEData()
            if (chooseAssetPopup.chosenAssetSymbol == "AVAX") {
              source: "qrc:/img/avax_logo.png"
            } else if (chooseAssetPopup.chosenAssetAddress == avme.address) {
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
            if (chooseAssetPopup.chosenAssetAddress == "") { // Coin
              // TODO: fix balances to test this
              txAmountInput.text = QmlSystem.getRealMaxAVAXAmount(
                txGasLimitInput.text, txGasPriceInput.text
              )
            } else {  // Token
              // TODO: real token balances here
              var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
              txAmountTokenInput.text = acc.balanceAVME
            }
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
        /*
        // TODO: this
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
        onClicked: {
          if (!checkTransactionFunds()) {
            fundsPopup.open()
          } else {
            if (!(txToInput.text.length === 42) && txToInput.visible) {
              incorrectInputPopup.open()
            } else {
              confirmTxPopup.isSameAddress = (txFromInput.text === txToInput.text)
              if (QmlSystem.getLedgerFlag()) {
                checkLedger()
              } else {
                confirmTxPopup.open()
              }
            }
          }
        }
        */
      }
    }
  }

  // Popup for choosing an asset to send
  AVMEPopupAssetSelect {
    id: chooseAssetPopup
    onAboutToHide: updateTxCost()
  }

  // Popup for confirming transaction
  // TODO: rewrite this into a generic popup
  /*
  AVMEPopupConfirmTx {
    id: confirmTxPopup
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
  }
  */

  // Popup for insufficient funds
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

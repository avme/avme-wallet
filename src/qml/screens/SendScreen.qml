/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

// Screen for sending AVAX and ARC20 token transactions.
Item {
  id: sendScreen
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

  function checkTransactionFunds() {
    if (chooseAssetPopup.chosenAssetSymbol == "AVAX") {  // Coin
      var hasCoinFunds = !QmlSystem.hasInsufficientFunds(
        accountHeader.coinBalance, QmlSystem.calculateTransactionCost(
          sendPanel.amount, sendPanel.gasLimit, sendPanel.gasPrice
        ), 18
      )
      return hasCoinFunds
    } else { // Token
      var hasCoinFunds = !QmlSystem.hasInsufficientFunds(
        accountHeader.coinBalance, QmlSystem.calculateTransactionCost(
          "0", sendPanel.gasLimit, sendPanel.gasPrice
        ), 18
      )
      var hasTokenFunds = !QmlSystem.hasInsufficientFunds(
        accountHeader.tokenList[chooseAssetPopup.chosenAssetAddress]["balance"],
        sendPanel.amount, chooseAssetPopup.chosenAssetDecimals
      )
      return (hasCoinFunds && hasTokenFunds)
    }
  }

  // Panel for the transaction inputs
  AVMEPanelSend {
    id: sendPanel
    width: (parent.width * 0.5)
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      margins: 10
    }
    sendBtn.onClicked: {
      if (!checkTransactionFunds()) {
        fundsPopup.open()
      } else if (to.length != 42) {
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
  }

  // Popup for choosing an asset to send
  AVMEPopupAssetSelect {
    id: chooseAssetPopup
    onAboutToHide: { sendPanel.updateTxCost(); sendPanel.refreshAssetBalance() }
  }

  // Popup for confirming transaction
  AVMEPopupConfirmTx {
    id: confirmTxPopup
    isSameAddress: (sendPanel.to == accountHeader.currentAddress)
    info: "You will send "
    + "<b>" + sendPanel.amount + " " + chooseAssetPopup.chosenAssetSymbol + "</b>"
    + " to the address<br><b>" + sendPanel.to + "</b>"
    + "<br>Gas Limit: <b>"
    + QmlSystem.weiToFixedPoint(sendPanel.gasLimit, 18) + " AVAX</b>"
    + "<br>Gas Price: <b>"
    + QmlSystem.weiToFixedPoint(sendPanel.gasPrice, 9) + " AVAX</b>"
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

/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

// Screen for exchanging coins/tokens in a given Account
Item {
  id: exchangeScreen

  function checkTransactionFunds() {
    if (fromAssetPopup.chosenAssetSymbol == "AVAX") {  // Coin
      var hasCoinFunds = !qmlSystem.hasInsufficientFunds(
        accountHeader.coinRawBalance, qmlSystem.calculateTransactionCost(
          exchangePanel.amount, "180000", qmlSystem.getAutomaticFee()
        ), 18
      )
      return hasCoinFunds
    } else { // Token
      var hasCoinFunds = !qmlSystem.hasInsufficientFunds(
        accountHeader.coinRawBalance, qmlSystem.calculateTransactionCost(
          "0", "180000", qmlSystem.getAutomaticFee()
        ), 18
      )
      var hasTokenFunds = !qmlSystem.hasInsufficientFunds(
        accountHeader.tokenList[fromAssetPopup.chosenAssetAddress]["rawBalance"],
        exchangePanel.amount, fromAssetPopup.chosenAssetDecimals
      )
      return (hasCoinFunds && hasTokenFunds)
    }
  }

  // op = "approval" or "exchange"
  function checkLedger(op) {
    var data = qmlSystem.checkForLedger()
    if (data.state) {
      ledgerFailPopup.close()
      ledgerRetryTimer.stop()
      if (op == "approval") {
        confirmApprovalPopup.open()
      } else if (op == "exchange") {
        confirmExchangePopup.open()
      }
    } else {
      ledgerFailPopup.info = data.message
      ledgerFailPopup.open()
      ledgerRetryTimer.start()
    }
  }

  Timer { id: ledgerRetryTimer; interval: 250; onTriggered: parent.checkLedger() }

  AVMEPanelExchange {
    id: exchangePanel
    width: (parent.width * 0.5)
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      margins: 10
    }
    approveBtn.onClicked: {
      if (!checkTransactionFunds()) {
        fundsPopup.open()
      } else {
        exchangePanel.approveTx()
        confirmApprovalPopup.setData(
          exchangePanel.to,
          exchangePanel.coinValue,
          exchangePanel.txData,
          exchangePanel.gas,
          exchangePanel.gasPrice,
          exchangePanel.automaticGas,
          exchangePanel.info,
          exchangePanel.historyInfo
        )
        if (qmlSystem.getLedgerFlag()) {
          checkLedger("approval")
        } else {
          confirmApprovalPopup.open()
        }
      }
    }
    swapBtn.onClicked: {
      if (!checkTransactionFunds()) {
        fundsPopup.open()
      } else {
        exchangePanel.swapTx(exchangePanel.amountIn, exchangePanel.swapEstimate)
        confirmExchangePopup.setData(
          exchangePanel.to,
          exchangePanel.coinValue,
          exchangePanel.txData,
          exchangePanel.gas,
          exchangePanel.gasPrice,
          exchangePanel.automaticGas,
          exchangePanel.info,
          exchangePanel.historyInfo
        )
        if (qmlSystem.getLedgerFlag()) {
          checkLedger("exchange")
        } else {
          confirmExchangePopup.open()
        }
      }
    }
  }

  // Popups for choosing the asset going "in"/"out".
  // Defaults to "from AVAX to AVME".
  AVMEPopupAssetSelect {
    id: fromAssetPopup
    defaultToAVME: false
    Component.onCompleted: exchangePanel.fetchAllowance()
    onAboutToHide: {
      if (chosenAssetAddress == toAssetPopup.chosenAssetAddress) {
        if (chosenAssetAddress == qmlSystem.getContract("AVAX")) {
          toAssetPopup.forceAVME()
        } else {
          toAssetPopup.forceAVAX()
        }
      }
      exchangePanel.fetchAllowance()
    }
  }
  AVMEPopupAssetSelect {
    id: toAssetPopup
    defaultToAVME: true
    onAboutToHide: {
      if (chosenAssetAddress == fromAssetPopup.chosenAssetAddress) {
        if (chosenAssetAddress == qmlSystem.getContract("AVAX")) {
          fromAssetPopup.forceAVME()
        } else {
          fromAssetPopup.forceAVAX()
        }
      }
      exchangePanel.fetchAllowance()
    }
  }

  // Popup for insufficient funds
  AVMEPopupInfo {
    id: fundsPopup
    icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your inputs."
  }
  AVMEPopupInfo {
    id: zeroSwapPopup
    icon: "qrc:/img/warn.png"
    info: "Cannot send swap for 0 value."
  }

  // Popups for confirming approval and swap, respectively
  AVMEPopupConfirmTx {
    id: confirmApprovalPopup
    info: "You will approve "
    + "<b>" + fromAssetPopup.chosenAssetSymbol + "</b>"
    + " swapping for the current address"
  }
  AVMEPopupConfirmTx {
    id: confirmExchangePopup
    info: "You will swap "
    + "<b>" + exchangePanel.amount + " " + fromAssetPopup.chosenAssetSymbol + "</b><br>"
    + "for <b>" + exchangePanel.swapEstimate + " " + toAssetPopup.chosenAssetSymbol + "</b>"
  }

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

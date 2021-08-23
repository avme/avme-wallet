/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"


/*
	TODO FIXMEs FROM GEK:
	1.
		Hovering on this page causes a boost bad lexical cast error.
		it causes a fatal throw.

*/


// Screen for exchanging coins/tokens in a given Account
Item {
  id: exchangeScreen

  function checkTransactionFunds() {
    if (fromAssetPopup.chosenAssetSymbol == "AVAX" && !exchangePanel.isInverse) {  // Coin
      var Fees = +qmlApi.fixedPointToWei(exchangePanel.gasPrice, 8) * +exchangePanel.gas
      var TxCost = Fees + +qmlApi.fixedPointToWei(exchangePanel.amountIn, 18)
      if (TxCost > +qmlApi.fixedPointToWei(accountHeader.coinRawBalance, 18)) {
        return false
      }
      return true
    } else { // Token
      var Fees = +qmlApi.fixedPointToWei(exchangePanel.gasPrice, 8) * +exchangePanel.gas
      if (Fees > +qmlApi.fixedPointToWei(accountHeader.coinRawBalance, 18)) {
        return false
      }
      if (!exchangePanel.isInverse) {
        if (+accountHeader.tokenList[fromAssetPopup.chosenAssetAddress]["rawBalance"] < +exchangePanel.amountIn) {
         return false
        } 
      } else {
        if (+accountHeader.tokenList[toAssetPopup.chosenAssetAddress]["rawBalance"] < +exchangePanel.amountIn) {
         return false
        } 
      }

      return true
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
      exchangePanel.approveTx()
      if (!checkTransactionFunds()) {
        fundsPopup.open()
      } else {
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
      exchangePanel.swapTx(exchangePanel.amountIn, exchangePanel.swapEstimate)
      if (!checkTransactionFunds()) {
        fundsPopup.open()
      } else {
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
  Item {
    property bool fromAssetLoaded: false
    property bool toAssetLoaded: false
    function checkPopups() {
      if (fromAssetLoaded && toAssetLoaded) { exchangePanel.fetchAllowance(true) }
    }

    AVMEPopupAssetSelect {
      id: fromAssetPopup
      defaultToAVME: false
      Component.onCompleted: { parent.fromAssetLoaded = true; parent.checkPopups() }
      onAboutToHide: {
        if (chosenAssetAddress == toAssetPopup.chosenAssetAddress) {
          if (chosenAssetAddress == qmlSystem.getContract("AVAX")) {
            toAssetPopup.forceAVME()
          } else {
            toAssetPopup.forceAVAX()
          }
        }
        exchangePanel.fetchAllowance(true)
      }
    }
    AVMEPopupAssetSelect {
      id: toAssetPopup
      defaultToAVME: true
      Component.onCompleted: { parent.toAssetLoaded = true; parent.checkPopups() }
      onAboutToHide: {
        if (chosenAssetAddress == fromAssetPopup.chosenAssetAddress) {
          if (chosenAssetAddress == qmlSystem.getContract("AVAX")) {
            fromAssetPopup.forceAVME()
          } else {
            fromAssetPopup.forceAVAX()
          }
        }
        exchangePanel.fetchAllowance(true)
      }
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

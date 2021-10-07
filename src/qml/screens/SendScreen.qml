/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QmlApi 1.0

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

// Screen for sending AVAX and ARC20 token transactions.
Item {
  id: sendScreen

  function checkTransactionFunds() {
    if (sendPanel.chosenAsset.symbol == "AVAX") {  // Coin
      var hasCoinFunds = !qmlSystem.hasInsufficientFunds(
        accountHeader.coinRawBalance, qmlSystem.calculateTransactionCost(
          sendPanel.coinValue, sendPanel.gasLimit, sendPanel.gasPrice
        ), 18
      )
      return hasCoinFunds
    } else { // Token
      var hasCoinFunds = !qmlSystem.hasInsufficientFunds(
        accountHeader.coinRawBalance, qmlSystem.calculateTransactionCost(
          "0", sendPanel.gasLimit, sendPanel.gasPrice
        ), 18
      )
      var hasTokenFunds = !qmlSystem.hasInsufficientFunds(
        accountHeader.tokenList[sendPanel.chosenAsset.address]["rawBalance"],
        sendPanel.tokenValue, sendPanel.chosenAsset.decimals
      )
      return (hasCoinFunds && hasTokenFunds)
    }
  }

  function checkLedger() {
    var data = qmlSystem.checkForLedger()
    if (data.state) {
      ledgerFailPopup.close()
      ledgerRetryTimer.stop()
      confirmTxPopup.open()
    } else {
      ledgerFailPopup.info = data.message
      ledgerFailPopup.open()
      ledgerRetryTimer.start()
    }
  }

  Timer { id: ledgerRetryTimer; interval: 250; onTriggered: parent.checkLedger() }

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
        sendPanel.updateTxCost()
        sendPanel.updateInfo()
        confirmTxPopup.setData(sendPanel.to, sendPanel.coinValue, sendPanel.txData, sendPanel.gas, sendPanel.gasPrice, sendPanel.automaticGas, sendPanel.info, sendPanel.historyInfo)
        if (qmlSystem.getLedgerFlag()) {
          checkLedger()
        } else {
          confirmTxPopup.open()
        }
      }
    }
  }

  // Popup for choosing a contact
  AVMEPopupContactSelect {
    id: contactSelectPopup
  }

  // Popup for confirming transaction
  AVMEPopupConfirmTx {
    id: confirmTxPopup
    isSameAddress: (sendPanel.to == accountHeader.currentAddress)
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

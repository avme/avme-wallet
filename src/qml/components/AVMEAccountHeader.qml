/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Header that shows the current Account and options for changing it
Rectangle {
  id: accountHeader
  property var tokenList
  property var selectedToken
  anchors {
    top: parent.top
    left: parent.left
    right: parent.right
    margins: 10
  }
  height: 50
  color: "transparent"
  radius: 10

  Timer { id: addressTimer; interval: 2000 }
  Timer { id: ledgerRetryTimer; interval: 250; onTriggered: checkLedger() }

  function checkLedger() {
    var data = QmlSystem.checkForLedger()
    if (data.state) {
      ledgerFailPopup.close()
      ledgerRetryTimer.stop()
      ledgerPopup.open()
    } else {
      ledgerFailPopup.info = data.message
      ledgerFailPopup.open()
      ledgerRetryTimer.start()
    }
  }

  function refreshTokenList() {
    tokenList = QmlSystem.getARC20Tokens()
  }

  Text {
    id: addressText
    anchors {
      verticalCenter: parent.verticalCenter
      left: parent.left
      leftMargin: 10
    }
    color: "#FFFFFF"
    text: (!addressTimer.running) ? QmlSystem.getCurrentAccount() : "Copied to clipboard!"
    font.bold: true
    font.pixelSize: 18.0

    Rectangle {
      id: addressRect
      anchors.fill: parent
      anchors.margins: -10
      color: "transparent"
      z: parent.z - 1
      radius: 5
      MouseArea {
        id: addressMouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: (!addressTimer.running)
        onEntered: parent.color = "#3F434C"
        onExited: parent.color = "transparent"
        onClicked: {
          parent.color = "transparent"
          QmlSystem.copyToClipboard(QmlSystem.getCurrentAccount())
          addressTimer.start()
        }
      }
    }
  }

  AVMEButton {
    id: btnCopyToClipboard
    width: parent.width * 0.15
    anchors {
      verticalCenter: parent.verticalCenter
      right: btnChangeAccount.left
      rightMargin: 10
    }
    enabled: (!addressTimer.running)
    text: (!addressTimer.running) ? "Copy To Clipboard" : "Copied!"
    onClicked: {
      QmlSystem.copyToClipboard(QmlSystem.getCurrentAccount())
      addressTimer.start()
    }
  }

  AVMEButton {
    id: btnChangeAccount
    width: parent.width * 0.15
    anchors {
      verticalCenter: parent.verticalCenter
      right: btnChangeWallet.left
      rightMargin: 10
    }
    text: "Change Account"
    onClicked: {
      if (QmlSystem.getLedgerFlag()) {
        checkLedger()
      } else {
        QmlSystem.hideMenu()
        QmlSystem.setScreen(content, "qml/screens/AccountsScreen.qml")
      }
    }
  }

  AVMEButton {
    id: btnChangeWallet
    width: parent.width * 0.15
    anchors {
      verticalCenter: parent.verticalCenter
      right: parent.right
      rightMargin: 10
    }
    text: "Change Wallet"
    onClicked: {
      QmlSystem.setLedgerFlag(false)
      QmlSystem.hideMenu()
      QmlSystem.setScreen(content, "qml/screens/StartScreen.qml")
    }
  }

  // Popup for Ledger accounts
  AVMEPopupLedger {
    id: ledgerPopup
  }

  // Info popup for if communication with Ledger fails
  AVMEPopupInfo {
    id: ledgerFailPopup
    icon: "qrc:/img/warn.png"
    onAboutToHide: ledgerRetryTimer.stop()
    okBtn.text: "Close"
  }
}

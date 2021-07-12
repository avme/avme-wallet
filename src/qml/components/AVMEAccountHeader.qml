/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Header that shows the current Account and options for changing it
Rectangle {
  function qrEncode() {
    qrcodePopup.qrModel.clear()
    var qrData = QmlSystem.getQRCodeFromAddress(QmlSystem.getCurrentAccount())
    for (var i = 0; i < qrData.length; i++) {
      qrcodePopup.qrModel.set(i, JSON.parse(qrData[i]))
    }
  }
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
    font.pixelSize: 17.0

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

  Rectangle {
    id: qrCodeRect
    anchors.top: parent.top
    anchors.left: addressText.right
    anchors.leftMargin: height / 2
    anchors.verticalCenter: parent.verticalCenter
    color: "transparent"
    radius: 5
    height: addressText.height
    width: height
    Image {
      id: qrCodeImage
      anchors.verticalCenter: parent.verticalCenter
      anchors.horizontalCenter: parent.horizontalCenter
      height: parent.height * 0.8
      width: parent.width * 0.8
      mipmap: true
      source: "qrc:/img/icons/qrcode.png"
    }
    MouseArea {
      id: qrCodeMouseArea
      anchors.fill: parent
      hoverEnabled: true
      onEntered: {
        parent.color = "#3F434C"
        qrCodeImage.source = "qrc:/img/icons/qrcodeSelect.png"
      }
      onExited: {
        parent.color = "transparent"
        qrCodeImage.source = "qrc:/img/icons/qrcode.png"
      }
      onClicked: {
        qrEncode()
        qrcodePopup.open()
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
  
  AVMEPopupQRCode {
    id: qrcodePopup
    qrcodeWidth: QmlSystem.getQRCodeSize(QmlSystem.getCurrentAccount())
    textAddress.text: QmlSystem.getCurrentAccount()
  }
}

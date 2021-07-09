/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Popup for viewing an Account's private key. Has to be opened manually.
AVMEPopup {
  id: viewPrivKeyPopup
  widthPct: 0.7
  heightPct: 0.5
  property string account
  readonly property alias pass: keyPassInput.text
  property alias showBtn: btnShow
  property color popupBgColor: "#1C2029"
  property color popupKeyBgColor: "#2D3542"
  property color popupSelectionColor: "#58A0B9"

  onAboutToShow: btnCopy.enabled = false

  function showPrivKey() {
    if (keyText.timer.running) { keyText.timer.stop() }
    keyText.text = QmlSystem.getPrivateKeys(account, keyPassInput.text)
    btnCopy.enabled = true
  }

  function showErrorMsg() {
    keyText.text = "Wrong passphrase, please try again"
    keyText.timer.start()
    btnCopy.enabled = false
  }

  function clean() {
    account = ""
    keyPassInput.text = ""
    keyText.text = ""
    btnCopy.enabled = false
  }

  Text {
    id: warningText
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      topMargin: 20
    }
    horizontalAlignment: Text.AlignHCenter
    color: "#FFFFFF"
    font.pixelSize: 14.0
    text: "Please authenticate to view the private key for the Account:<br>"
    + "<b>" + account + "</b>"
    + "<br><br><b>YOU ARE FULLY RESPONSIBLE FOR GUARDING YOUR PRIVATE KEYS."
    + "<br>KEEP THEM AWAY FROM PRYING EYES AND DO NOT SHARE THEM WITH ANYONE."
    + "<br>WE ARE NOT HELD LIABLE FOR ANY POTENTIAL FUND LOSSES CAUSED BY THIS."
    + "<br>PROCEED AT YOUR OWN RISK.</b>"
  }

  AVMEInput {
    id: keyPassInput
    anchors {
      top: warningText.bottom
      horizontalCenter: parent.horizontalCenter
      margins: 20
    }
    width: parent.width / 3
    echoMode: TextInput.Password
    passwordCharacter: "*"
    label: "Passphrase"
    placeholder: "Your Wallet's passphrase"
  }

  TextArea {
    id: keyText
    property alias timer: keyTextTimer
    width: parent.width - 100
    height: 50
    anchors {
      top: keyPassInput.bottom
      left: parent.left
      right: parent.right
      bottom: btnRow.top
      margins: 20
    }
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    readOnly: true
    selectByMouse: true
    selectionColor: popupSelectionColor
    color: "#FFFFFF"
    font.pixelSize: 14.0
    background: Rectangle {
      width: parent.width
      height: parent.height
      color: popupKeyBgColor
    }
    Timer { id: keyTextTimer; interval: 2000; onTriggered: keyText.text = "" }
  }

  Row {
    id: btnRow
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      bottomMargin: 20
    }
    spacing: 10

    AVMEButton {
      id: btnClose
      text: "Close"
      onClicked: {
        viewPrivKeyPopup.clean()
        viewPrivKeyPopup.close()
      }
    }
    AVMEButton {
      id: btnCopy
      text: (!copyTimer.running) ? "Copy" : "Copied!"
      Timer { id: copyTimer; interval: 2000 }
      onClicked: {
        QmlSystem.copyToClipboard(keyText.text)
        copyTimer.start()
      }
    }
    AVMEButton {
      id: btnShow
      text: "Show"
      enabled: (keyPassInput.text !== "")
      onClicked: {
        if (QmlSystem.checkWalletPass(pass)) {
          showPrivKey()
        } else {
          showErrorMsg()
        }
      }
    }
  }
}

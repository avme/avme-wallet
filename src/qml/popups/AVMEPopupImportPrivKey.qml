/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Popup for importing an Account with a private key.
AVMEPopup {
  id: importPrivKeyPopup
  widthPct: 0.55
  heightPct: 0.6
  property alias privKey: privKeyInput.text
  property alias name: nameInput.text
  property alias pass: passInput.text
  property alias passTimer: infoPassTimer
  property alias addressTimer: infoAddressTimer
  property alias keyTimer: infoKeyTimer
  property color popupBgColor: "#1C2029"

  onAboutToShow: privKeyInput.forceActiveFocus()
  onAboutToHide: {
    privKeyInput.text = nameInput.text = passInput.text = ""
    passViewBtn.view = false
  }

  Column {
    id: items
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 30

    // Enter/Return key override
    Keys.onPressed: {
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        if (btnImport.enabled) { btnImport.handleImport() }
      }
    }

    Text {
      id: infoLabel
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: {
        if (infoPassTimer.running) {
          text: "Wrong password, please try again."
        } else if (infoAddressTimer.running) {
          text: "Account is already in Wallet, please try another."
        } else if (infoKeyTimer.running) {
          text: "Private key is invalid, please try another."
        } else {
          text: "Enter your Account's private key."
        }
      }
      Timer { id: infoPassTimer; interval: 2000 }
      Timer { id: infoAddressTimer; interval: 2000 }
      Timer { id: infoKeyTimer; interval: 2000 }
    }

    AVMEInput {
      id: privKeyInput
      width: (importPrivKeyPopup.width * 0.95)
      anchors.horizontalCenter: parent.horizontalCenter
      validator: RegExpValidator { regExp: /[0-9a-fA-F]{64}/ }
      label: "Private key"
      placeholder: "e.g. 1a2b3c4d5e6f..."
    }

    AVMEInput {
      id: nameInput
      width: (importPrivKeyPopup.width * 0.95)
      anchors.horizontalCenter: parent.horizontalCenter
      label: "(Optional) Name"
      placeholder: "Name for your Account"
    }

    Row {
      id: passRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: passInput
        width: (importPrivKeyPopup.width * 0.85) - parent.spacing
        echoMode: (passViewBtn.view) ? TextInput.Normal : TextInput.Password
        passwordCharacter: "*"
        label: "Passphrase"
        placeholder: "Your Wallet's passphrase"
      }
      AVMEButton {
        id: passViewBtn
        property bool view: false
        width: (importPrivKeyPopup.width * 0.1)
        height: passInput.height
        text: ""
        onClicked: view = !view
        AVMEAsyncImage {
          anchors.fill: parent
          anchors.margins: 5
          loading: false
          imageSource: (parent.view)
          ? "qrc:/img/icons/eye-f.png" : "qrc:/img/icons/eye-close-f.png"
        }
      }
    }

    AVMEButton {
      id: btnImport
      width: (importPrivKeyPopup.width * 0.95)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (privKeyInput.acceptableInput && passInput.text != "")
      text: (privKeyInput.acceptableInput)
        ? "Import Account" : "Invalid private key"
      onClicked: handleImport()
      function handleImport() {
        if (qmlSystem.privateKeyExists(privKeyInput.text)) {
          addressTimer.start()
        } else if (!qmlSystem.isPrivateKey(privKeyInput.text)) {
          keyTimer.start()
        } else if (!qmlSystem.checkWalletPass(passInput.text)) {
          passTimer.start()
        } else {
          accountInfoPopup.text = "Importing Account..."
          accountInfoPopup.open()
          qmlSystem.createAccount(privKey, name, pass)
        }
      }
    }

    AVMEButton {
      id: btnClose
      width: (importPrivKeyPopup.width * 0.95)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Close"
      onClicked: importPrivKeyPopup.close()
    }
  }
}

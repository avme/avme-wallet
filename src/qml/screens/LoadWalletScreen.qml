/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

// Screen for loading a Wallet
Item {
  id: loadWalletScreen
  property alias folder: loadFolderInput.text
  property alias pass: loadPassInput.text
  property alias loadBtn: btnLoad
  property alias saveWallet: saveWalletCheck.checked
  property bool walletExists

  Connections {
    target: qmlSystem
    function onWalletLoaded(success) {
      if (success) {
        qmlSystem.setLedgerFlag(false)
        qmlSystem.deleteLastWalletPath()
        if (saveWallet) { qmlSystem.saveLastWalletPath() }
        window.infoPopup.close()
        qmlSystem.cleanAndClose()
        qmlSystem.loadAccounts()
        qmlSystem.startWSServer()
        window.menu.changeScreen("Accounts")
      } else {
        window.infoPopup.close()
        errorPopup.open()
      }
    }
  }

  Component.onCompleted: {
    var lastWallet = qmlSystem.getLastWalletPath()
    loadFolderInput.text = (lastWallet != "") ? lastWallet : qmlSystem.getDefaultWalletPath()
    saveWalletCheck.checked = (lastWallet != "")
    walletExists = qmlSystem.checkFolderForWallet(loadFolderInput.text)
    loadPassInput.forceActiveFocus()
  }

  function loadWallet() {
    window.infoPopup.info = "Loading Wallet,<br>please wait..."
    window.infoPopup.open()
    if (qmlSystem.isWalletLoaded()) { qmlSystem.closeWallet() }
    qmlSystem.loadWallet(folder, pass)
  }

  AVMEPanel {
    id: loadPanel
    width: (parent.width * 0.6)
    height: (parent.height * 0.6)
    anchors.centerIn: parent
    title: ""

    Column {
      id: items
      width: parent.width
      anchors.verticalCenter: parent.verticalCenter
      spacing: 30

      // Enter/Numpad enter key override
      Keys.onPressed: {
        if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
          if (btnLoad.enabled) { loadWallet() }
        }
      }

      Text {
        id: info
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Enter the following details to load a Wallet."
      }

      // Load Wallet folder
      Row {
        id: loadFolderRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AVMEInput {
          id: loadFolderInput
          width: (items.width * 0.9) - (loadFolderDialogBtn.width + parent.spacing)
          readOnly: true
          label: "Wallet folder"
          placeholder: "Your Wallet's top folder"
        }
        AVMEButton {
          id: loadFolderDialogBtn
          width: (items.width * 0.1)
          height: loadFolderInput.height
          text: ""
          onClicked: loadFolderDialog.visible = true
          Image {
            anchors.fill: parent
            anchors.margins: 5
            source: "qrc:/img/icons/folder.png"
            antialiasing: true
            smooth: true
            fillMode: Image.PreserveAspectFit
          }
        }
        FolderDialog {
          id: loadFolderDialog
          title: "Choose your Wallet folder"
          onAccepted: {
            loadFolderInput.text = qmlSystem.cleanPath(loadFolderDialog.folder)
            walletExists = qmlSystem.checkFolderForWallet(loadFolderInput.text)
          }
        }
      }

      // Passphrase
      AVMEInput {
        id: loadPassInput
        anchors.horizontalCenter: parent.horizontalCenter
        width: (items.width * 0.9)
        echoMode: TextInput.Password
        passwordCharacter: "*"
        label: "Passphrase"
        placeholder: "Your Wallet's passphrase"
      }

      CheckBox {
        id: saveWalletCheck
        checked: false
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Always open this Wallet at startup"
        contentItem: Text {
          text: parent.text
          font.pixelSize: 14.0
          color: parent.checked ? "#FFFFFF" : "#888888"
          verticalAlignment: Text.AlignVCenter
          leftPadding: parent.indicator.width + parent.spacing
        }
        ToolTip {
          id: saveWalletTooltip
          visible: parent.hovered
          delay: 500
          text: "Checking this will automatically open this Wallet"
          + "<br>when the program starts, until it is closed manually."
          contentItem: Text {
            font.pixelSize: 12.0
            color: "#FFFFFF"
            text: saveWalletTooltip.text
          }
          background: Rectangle { color: "#1C2029" }
        }
      }

      AVMEButton {
        id: btnLoad
        width: (items.width * 0.9)
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (loadFolderInput.text != "" && loadPassInput.text != "" && walletExists)
        text: (walletExists) ? "Load Wallet" : "No Wallet found"
        onClicked: loadWallet()
      }
    }
  }

  AVMEPopupInfo {
    id: errorPopup; icon: "qrc:/img/warn.png"
    info: "Error on Wallet loading.<br>Please check your passphrase."
  }
}

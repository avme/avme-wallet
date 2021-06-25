/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

AVMEPanel {
  id: loadWalletPanel
  title: "Load Wallet"
  property alias retryTimer: ledgerRetryTimer
  Keys.onReturnPressed: btnLoad.loadWallet() // Enter key
  Keys.onEnterPressed: btnLoad.loadWallet() // Numpad enter key

  Column {
    id: loadItems
    anchors {
      left: parent.left
      right: parent.right
      verticalCenter: parent.verticalCenter
      margins: 20
    }
    spacing: 30
    topPadding: 50

    // Ledger button
    Text {
      id: ledgerTitle
      color: "#FFFFFF"
      font.bold: true
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Have a Ledger device?"
    }
    
    AVMEButton {
      id: btnStartLedger
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Open Ledger Wallet"
      Timer { id: ledgerRetryTimer; interval: 250; onTriggered: parent.checkLedger() }
      onClicked: checkLedger()
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
    }

    // Text separator
    Text {
      id: separator
      color: "#FFFFFF"
      font.bold: true
      anchors.horizontalCenter: parent.horizontalCenter
      text: "- or -"
    }

    // Load Wallet folder
    Row {
      id: loadFolderRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: loadFolderInput
        width: (loadItems.width * 0.9) - (loadFolderDialogBtn.width + parent.spacing)
        readOnly: true
        label: "Wallet folder"
        placeholder: "Your Wallet's top folder"
        Component.onCompleted: {
          loadFolderInput.text = QmlSystem.getDefaultWalletPath()
          loadWalletExists = QmlSystem.checkFolderForWallet(loadFolderInput.text)
        }
      }
      AVMEButton {
        id: loadFolderDialogBtn
        width: 40
        height: loadFolderInput.height
        text: "..."
        onClicked: loadFolderDialog.visible = true
      }
      FolderDialog {
        id: loadFolderDialog
        title: "Choose your Wallet folder"
        onAccepted: {
          loadFolderInput.text = QmlSystem.cleanPath(loadFolderDialog.folder)
          loadWalletExists = QmlSystem.checkFolderForWallet(loadFolderInput.text)
        }
      }
    }

    // Passphrase
    AVMEInput {
      id: loadPassInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: (loadItems.width * 0.9)
      echoMode: TextInput.Password
      passwordCharacter: "*"
      label: "Passphrase"
      placeholder: "Your Wallet's passphrase"
    }

    // Buttons for Load Wallet
    Row {
      id: btnLoadRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 20

      AVMEButton {
        id: btnLoad
        width: (loadItems.width * 0.4)
        enabled: (loadFolderInput.text != "" && loadPassInput.text != "" && loadWalletExists)
        text: (loadWalletExists) ? "Load Wallet" : "No Wallet found"
        onClicked: btnLoad.loadWallet()
        function loadWallet() {
          try {
            if (QmlSystem.isWalletLoaded()) {
              QmlSystem.stopAllBalanceThreads()
              QmlSystem.closeWallet()
            }
            if (!QmlSystem.loadWallet(loadFolderInput.text, loadPassInput.text)) {
              throw "Error on Wallet loading. Please check"
              + "<br>the folder path and/or passphrase.";
            }
            console.log("Wallet loaded successfully")
            QmlSystem.setFirstLoad(true)
            QmlSystem.setScreen(content, "qml/screens/AccountsScreen.qml")
          } catch (error) {
            walletFailPopup.info = error.toString()
            walletFailPopup.open()
          }
        }
      }
    }
  }
}

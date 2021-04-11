import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Initial screen (for creating/loading a Wallet)

Item {
  id: startScreen
  property bool createWalletExists
  property bool loadWalletExists

  Column {
    id: items
    anchors.fill: parent
    spacing: 30
    topPadding: 10

    // Logo
    Image {
      id: logo
      height: 80
      anchors.horizontalCenter: parent.horizontalCenter
      fillMode: Image.PreserveAspectFit
      source: "qrc:/img/avme_banner.png"
    }

    // Create Wallet text
    Text {
      id: createText
      color: "#FFFFFF"
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      text: "Enter the following details to create/import a Wallet:"
    }

    // Create Wallet folder
    Row {
      id: folderRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: createFolderInput
        width: (items.width / 2) - (createFolderDialogBtn.width + parent.spacing)
        readOnly: true
        label: "Wallet folder"
        placeholder: "Your Wallet's top folder"
      }
      AVMEButton {
        id: createFolderDialogBtn
        width: 40
        height: createFolderInput.height
        text: "..."
        onClicked: createFolderDialog.visible = true
      }
      FolderDialog {
        id: createFolderDialog
        title: "Choose your Wallet folder"
        onAccepted: {
          createFolderInput.text = System.cleanPath(createFolderDialog.folder)
          createWalletExists = System.checkFolderForWallet(createFolderInput.text)
        }
      }
    }

    // Optional seed (Import)
    AVMEInput {
      id: seedInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: items.width / 2
      label: "(Optional) Seed"
      placeholder: "Restoring an existing Wallet? Enter your 12-word seed here"
    }

    // Passphrase
    AVMEInput {
      id: createPassInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: items.width / 2
      echoMode: TextInput.Password
      passwordCharacter: "*"
      label: "Passphrase"
      placeholder: "Your Wallet's passphrase"
    }

    // Button for Create/Import Wallet
    AVMEButton {
      id: btnCreate
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width / 4
      enabled: (createFolderInput.text != "" && createPassInput.text != "" && !createWalletExists)
      height: 50
      text: {
        if (createWalletExists) {
          text: "Wallet already exists"
        } else if (!createWalletExists && seedInput.text == "") {
          text: "Create a new Wallet"
        } else if (!createWalletExists && seedInput.text != "") {
          text: "Import an existing Wallet"
        }
      }
      onClicked: {
        try {
          if (!createWalletExists && seedInput.text == "") {
            if (!System.createWallet(createFolderInput.text, createPassInput.text)) {
              throw "Error on Wallet creation. Please check"
              + "<br>the folder path and/or passphrase.";
            }
            console.log("Wallet created successfully, now loading it...")
          } else if (!createWalletExists && seedInput.text != "") {
            if (!System.seedIsValid(seedInput.text)) {
              throw "Error on Wallet importing. Seed is invalid,"
              + "<br>please check the spelling and/or formatting."
            } else if (!System.importWallet(seedInput.text, createFolderInput.text, createPassInput.text)) {
              throw "Error on Wallet importing. Please check"
              + "<br>the folder path and/or passphrase.";
            }
            console.log("Wallet imported successfully, now loading it...")
          }
          if (System.isWalletLoaded()) {
            System.stopAllBalanceThreads()
            System.closeWallet()
          }
          if (!System.loadWallet(createFolderInput.text, createPassInput.text)) {
            throw "Error on Wallet loading. Please check"
            + "<br>the folder path and/or passphrase.";
          }
          console.log("Wallet loaded successfully")
          // Always default to AVAX & AVME on first load
          if (System.getCurrentCoin() == "") {
            System.setCurrentCoin("AVAX")
            System.setCurrentCoinDecimals(18)
          }
          if (System.getCurrentToken() == "") {
            System.setCurrentToken("AVME")
            System.setCurrentTokenDecimals(18)
          }
          System.setFirstLoad(true)
          System.walletLoaded()
          System.setScreen(content, "qml/screens/AccountsScreen.qml")
        } catch (error) {
          walletFailPopup.info = error
          walletFailPopup.open()
        }
      }
    }

    // Load text
    Text {
      id: loadText
      color: "#FFFFFF"
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      text: "Or, if you already have a Wallet, load it here:"
    }

    // Wallet folder
    Row {
      id: loadFolderRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: loadFolderInput
        width: (items.width / 2) - (loadFolderDialogBtn.width + parent.spacing)
        readOnly: true
        label: "Wallet folder"
        placeholder: "Your Wallet's top folder"
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
          loadFolderInput.text = System.cleanPath(loadFolderDialog.folder)
          loadWalletExists = System.checkFolderForWallet(loadFolderInput.text)
        }
      }
    }

    // Passphrase
    AVMEInput {
      id: loadPassInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: items.width / 2
      echoMode: TextInput.Password
      passwordCharacter: "*"
      label: "Passphrase"
      placeholder: "Your Wallet's passphrase"
    }

    // Button
    AVMEButton {
      id: btn
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width / 4
      enabled: (loadFolderInput.text != "" && loadPassInput.text != "" && loadWalletExists)
      height: 50
      text: (loadWalletExists) ? "Open this Wallet" : "No Wallet found"
      onClicked: {
        try {
          if (System.isWalletLoaded()) {
            System.stopAllBalanceThreads()
            System.closeWallet()
          }
          if (!System.loadWallet(loadFolderInput.text, loadPassInput.text)) {
            throw "Error on Wallet loading. Please check"
            + "<br>the folder path and/or passphrase.";
          }
          console.log("Wallet loaded successfully")
          // Always default to AVAX & AVME on first load
          if (System.getCurrentCoin() == "") {
            System.setCurrentCoin("AVAX")
            System.setCurrentCoinDecimals(18)
          }
          if (System.getCurrentToken() == "") {
            System.setCurrentToken("AVME")
            System.setCurrentTokenDecimals(18)
          }
          System.setFirstLoad(true)
          System.walletLoaded()
          System.setScreen(content, "qml/screens/AccountsScreen.qml")
        } catch (error) {
          walletFailPopup.info = error
          walletFailPopup.open()
        }
      }
    }
  }

  // Info popup for if the Wallet creation/loading/importing fails
  AVMEPopupInfo {
    id: walletFailPopup
    icon: "qrc:/img/warn.png"
  }
}

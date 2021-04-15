/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Starting screen (for managing Wallets)

// TODO: automatic scanning for default path Wallet

Item {
  id: startScreen
  property bool isCreate
  property bool isLoad
  property bool createWalletExists
  property bool loadWalletExists

  // Background logo image
  Image {
    id: logoBg
    anchors {
      horizontalCenter: parent.horizontalCenter
      horizontalCenterOffset: 400
    }
    width: 1000
    height: 1000
    opacity: 0.15
    antialiasing: true
    smooth: true
    fillMode: Image.PreserveAspectFit
    source: "qrc:/img/avme_logo_hd.png"
  }

  // Header (logo + text)
  Image {
    id: logo
    width: 150
    height: 150
    anchors {
      top: parent.top
      left: parent.left
      topMargin: 50
      leftMargin: 50
    }
    antialiasing: true
    smooth: true
    source: "qrc:/img/avme_logo_hd.png"
    fillMode: Image.PreserveAspectFit

    Text {
      anchors {
        verticalCenter: parent.verticalCenter
        left: parent.right
        leftMargin: 20
      }
      font.bold: true
      color: "#FFFFFF"
      font.pointSize: 32.0
      text: {
        if (isCreate) {
          text: "Create/Import Wallet"
        } else if (isLoad) {
          text: "Load Wallet"
        } else {
          text: "Welcome to the AVME Wallet"
        }
      }
    }
  }

  // Starting rectangle
  Rectangle {
    id: startRect
    width: parent.width * 0.4
    height: 150
    visible: (!isCreate && !isLoad)
    anchors {
      top: logo.bottom
      left: parent.left
      topMargin: 50
      leftMargin: 50
    }
    color: "#2D3542"
    radius: 10

    AVMEButton {
      id: btnStartCreate
      width: parent.width * 0.9
      anchors {
        centerIn: parent
        verticalCenterOffset: -30
      }
      text: "Create/Import Wallet"
      onClicked: isCreate = true
    }

    AVMEButton {
      id: btnStartLoad
      width: parent.width * 0.9
      anchors {
        centerIn: parent
        verticalCenterOffset: 30
      }
      text: "Load Wallet"
      onClicked: isLoad = true
    }
  }

  // Create/Import rectangle
  Rectangle {
    id: createRect
    width: parent.width * 0.4
    height: 350
    visible: isCreate
    anchors {
      top: logo.bottom
      left: parent.left
      topMargin: 50
      leftMargin: 50
    }
    color: "#2D3542"
    radius: 10

    Column {
      id: createItems
      anchors.fill: parent
      spacing: 30
      topPadding: 30

      // Create Wallet folder
      Row {
        id: createFolderRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AVMEInput {
          id: createFolderInput
          width: (createItems.width * 0.9) - (createFolderDialogBtn.width + parent.spacing)
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

      // Passphrase
      AVMEInput {
        id: createPassInput
        anchors.horizontalCenter: parent.horizontalCenter
        width: (createItems.width * 0.9)
        echoMode: TextInput.Password
        passwordCharacter: "*"
        label: "Passphrase"
        placeholder: "Your Wallet's passphrase"
      }

      // Optional seed (Import)
      Text {
        id: createSeedText
        color: "#FFFFFF"
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: "Importing an existing Wallet?"
      }

      AVMEInput {
        id: createSeedInput
        anchors.horizontalCenter: parent.horizontalCenter
        width: (createItems.width * 0.9)
        label: "(Optional) Seed"
        placeholder: "Your 12-word seed phrase"
      }

      // Buttons for Create/Import Wallet
      Row {
        id: btnCreateRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20

        AVMEButton {
          id: btnCreateBack
          width: (createItems.width * 0.4)
          text: "Back"
          onClicked: isCreate = false
        }

        AVMEButton {
          id: btnCreate
          width: (createItems.width * 0.4)
          enabled: (createFolderInput.text != "" && createPassInput.text != "" && !createWalletExists)
          text: {
            if (createWalletExists) {
              text: "Wallet exists"
            } else if (!createWalletExists && createSeedInput.text == "") {
              text: "Create Wallet"
            } else if (!createWalletExists && createSeedInput.text != "") {
              text: "Import Wallet"
            }
          }
          onClicked: {
            try {
              if (!createWalletExists && createSeedInput.text == "") {
                if (!System.createWallet(createFolderInput.text, createPassInput.text)) {
                  throw "Error on Wallet creation. Please check"
                  + "<br>the folder path and/or passphrase.";
                }
                console.log("Wallet created successfully, now loading it...")
              } else if (!createWalletExists && createSeedInput.text != "") {
                if (!System.seedIsValid(createSeedInput.text)) {
                  throw "Error on Wallet importing. Seed is invalid,"
                  + "<br>please check the spelling and/or formatting."
                } else if (!System.importWallet(createSeedInput.text, createFolderInput.text, createPassInput.text)) {
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
      }
    }
  }

  // Load rectangle
  Rectangle {
    id: loadRect
    width: parent.width * 0.4
    height: 225
    visible: isLoad
    anchors {
      top: logo.bottom
      left: parent.left
      topMargin: 50
      leftMargin: 50
    }
    color: "#2D3542"
    radius: 10

    Column {
      id: loadItems
      anchors.fill: parent
      spacing: 30
      topPadding: 30

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
          id: btnLoadBack
          width: (loadItems.width * 0.4)
          text: "Back"
          onClicked: isLoad = false
        }

        AVMEButton {
          id: btnLoad
          width: (loadItems.width * 0.4)
          enabled: (loadFolderInput.text != "" && loadPassInput.text != "" && loadWalletExists)
          text: (loadWalletExists) ? "Load Wallet" : "No Wallet found"
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
    }
  }

  // Info popup for if the Wallet creation/loading/importing fails
  AVMEPopupInfo {
    id: walletFailPopup
    icon: "qrc:/img/warn.png"
  }
}

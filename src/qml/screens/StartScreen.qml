/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

// Starting screen (for managing Wallets).
Item {
  id: startScreen
  property bool createAndLoad

  Connections {
    target: qmlSystem
    function onWalletCreated(success) {
      createAndLoad = true
      if (success) {
        infoPopup.info = "Loading Wallet,<br>please wait..."
        if (qmlSystem.isWalletLoaded()) { qmlSystem.closeWallet() }
        qmlSystem.loadWallet(createWalletPopup.folder, createWalletPopup.pass)
      } else {
        infoPopup.close()
        walletFailPopup.info = "Error on Wallet "
          + ((createWalletPopup.seed) ? "importing." : "creating.")
        walletFailPopup.open()
      }
    }
    function onWalletLoaded(success) {
      if (success) {
        qmlSystem.setLedgerFlag(false)
        if (
          createWalletPopup.saveWallet.checked ||
          (loadWalletPopup.saveWallet.enabled && loadWalletPopup.saveWallet.checked)
        ) {
          qmlSystem.saveLastWalletPath()
        }
        if (createAndLoad) {
          infoPopup.info = "Creating an Account<br>for the new Wallet..."
          qmlSystem.createAccount(
            createWalletPopup.seed, 0, "default", createWalletPopup.pass
          )
        } else {
          infoPopup.close()
          qmlSystem.loadAccounts()
          qmlSystem.setScreen(content, "qml/screens/AccountsScreen.qml")
        }
      } else {
        infoPopup.close()
        walletFailPopup.info = "Error on Wallet loading.<br>Please check your passphrase."
        walletFailPopup.open()
      }
    }
    function onAccountCreated(success, data) {
      if (success) {
        infoPopup.close()
        qmlSystem.setCurrentAccount(data.accAddress)
        qmlSystem.setFirstLoad(true)
        newWalletSeedPopup.showSeed(createWalletPopup.pass)
        newWalletSeedPopup.open()
        createWalletPopup.clean()
        createWalletPopup.close()
      } else {
        infoPopup.close()
        walletFailPopup.info = "Error on Account creation."
        walletFailPopup.open()
      }
    }
  }

  Component.onCompleted: {
    var lastWallet = qmlSystem.getLastWalletPath()
    console.log(lastWallet)
    if (lastWallet != "") {
      loadWalletPopup.folder = lastWallet
      loadWalletPopup.saveWallet.visible = false
      loadWalletPopup.saveWallet.enabled = false
      loadWalletPopup.open()
    }
  }

  function useSeed() {
    createWalletPopup.seed = seedPopup.fullSeed
    seedPopup.clean()
    seedPopup.close()
    createWalletPopup.open()
  }

  AVMEPanel {
    id: startPanel
    title: "Welcome to the AVME Wallet"
    width: (parent.width * 0.4)
    height: (parent.height * 0.6)
    anchors {
      horizontalCenter: parent.horizontalCenter
      verticalCenter: parent.verticalCenter
    }

    Image {
      id: logo
      width: 256
      anchors {
        top: parent.top
        horizontalCenter: parent.horizontalCenter
        topMargin: 80
      }
      antialiasing: true
      smooth: true
      source: "qrc:/img/Welcome_Logo_AVME.png"
      fillMode: Image.PreserveAspectFit
    }

    Column {
      width: (parent.width * 0.9)
      height: (parent.height * 0.5)
      anchors {
        top: logo.bottom
        horizontalCenter: parent.horizontalCenter
        topMargin: 40
      }
      spacing: 20

      AVMEButton {
        id: btnCreateWallet
        width: (parent.width * 0.6)
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Create New Wallet"
        onClicked: {
          createWalletPopup.seed = ""
          createWalletPopup.open()
        }
      }
      AVMEButton {
        id: btnImportWallet
        width: (parent.width * 0.6)
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Import Wallet Seed"
        onClicked: seedPopup.open()
      }
      AVMEButton {
        id: btnLoadWallet
        width: (parent.width * 0.6)
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Load Wallet"
        onClicked: loadWalletPopup.open()
      }
    }
  }

  // Popup for creating a new Wallet
  AVMEPopupCreateWallet {
    id: createWalletPopup
    widthPct: 0.4
    heightPct: 0.7
    createBtn.onClicked: createWallet()
    function createWallet() {
      infoPopup.info = ((seed) ? "Importing" : "Creating") + " Wallet,<br>please wait..."
      infoPopup.open()
      qmlSystem.createWallet(folder, pass, seed)
    }
  }

  // Popup for loading an existing Wallet
  AVMEPopupLoadWallet {
    id: loadWalletPopup
    widthPct: 0.4
    heightPct: 0.6
    loadBtn.onClicked: loadWallet()
    function loadWallet() {
      createAndLoad = false
      infoPopup.info = "Loading Wallet,<br>please wait..."
      infoPopup.open()
      if (qmlSystem.isWalletLoaded()) { qmlSystem.closeWallet() }
      qmlSystem.loadWallet(folder, pass)
    }
  }

  // Popup for entering a BIP39 seed
  AVMEPopupSeed { id: seedPopup }

  AVMEPopup {
    id: infoPopup
    property alias info: infoText.text
    widthPct: 0.2
    heightPct: 0.1
    Text {
      id: infoText
      color: "#FFFFFF"
      horizontalAlignment: Text.AlignHCenter
      anchors.centerIn: parent
      font.pixelSize: 14.0
    }
  }

  AVMEPopupInfo {
    id: errorPopup
    icon: "qrc:/img/warn.png"
  }

  // Info popup for if the Wallet creation/loading/importing fails
  AVMEPopupInfo {
    id: walletFailPopup
    icon: "qrc:/img/warn.png"
  }

  // Info popup for if the seed import fails
  AVMEPopupInfo {
    id: seedFailPopup
    icon: "qrc:/img/warn.png"
    info: "Seed is invalid. Please check if it's typed correctly."
  }

  // Popup for viewing the seed at Wallet creation
  AVMEPopupNewWalletSeed {
    id: newWalletSeedPopup
    widthPct: 0.9
    heightPct: 0.5
    okBtn.onClicked: {
      newWalletSeedPopup.clean()
      newWalletSeedPopup.close()
      qmlSystem.loadTokenDB()
      qmlSystem.loadHistoryDB(qmlSystem.getCurrentAccount())
      qmlSystem.loadAppDB()
      qmlSystem.loadAddressDB()
      qmlSystem.loadConfigDB()
      qmlSystem.loadARC20Tokens()
      accountHeader.getAddress()
      qmlSystem.goToOverview()
      qmlSystem.setScreen(content, "qml/screens/OverviewScreen.qml")
    }
  }
}

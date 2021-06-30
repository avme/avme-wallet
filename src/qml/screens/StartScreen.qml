/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

// Starting screen (for managing Wallets)
// TODO: set Ledger flag

Item {
  id: startScreen
  property bool createWalletExists
  property bool loadWalletExists

  Connections {
    target: QmlSystem
    function onAccountCreated(obj) {
      // TODO: fix this
      QmlSystem.setCurrentAccount(obj.accAddress)
      QmlSystem.setFirstLoad(true)
      QmlSystem.loadAccounts()
      QmlSystem.startAllBalanceThreads()
      while (!QmlSystem.accountHasBalances(obj.accAddress)) {} // This is ugly but hey it works
      walletNewPopup.close()
      QmlSystem.goToOverview();
      QmlSystem.setScreen(content, "qml/screens/OverviewScreen.qml")
    }
    function onAccountCreationFailed() {
      walletFailPopup.info = error.toString()
      walletFailPopup.open()
    }
  }

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

  Timer { id: ledgerRetryTimer; interval: 250; onTriggered: parent.checkLedger() }

  // Header logo
  Image {
    id: logo
    width: 256
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      topMargin: 30
    }
    antialiasing: true
    smooth: true
    source: "qrc:/img/Welcome_Logo_AVME.png"
    fillMode: Image.PreserveAspectFit
  }

  AVMEPanel {
    id: startPanel
    title: "Welcome to the AVME Wallet"
    width: (parent.width * 0.4)
    height: (parent.height * 0.5)
    anchors {
      horizontalCenter: parent.horizontalCenter
      verticalCenter: parent.verticalCenter
    }

    Column {
      width: (parent.width * 0.9)
      height: (parent.height * 0.5)
      anchors.centerIn: parent
      spacing: 20

      AVMEButton {
        id: btnCreateWallet
        width: (parent.width * 0.6)
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Create New Wallet"
        onClicked: createWalletPopup.open()
      }
      AVMEButton {
        id: btnImportWallet
        width: (parent.width * 0.6)
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Import Wallet Seed"
        onClicked: {} // TODO
      }
      AVMEButton {
        id: btnLoadWallet
        width: (parent.width * 0.6)
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Load Wallet"
        onClicked: loadWalletPopup.open()
      }
      AVMEButton {
        id: btnOpenLedger
        width: (parent.width * 0.6)
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Open Ledger"
        onClicked: startScreen.checkLedger()
      }
    }
  }

  // TODO: use a signal at Wallet creation (before seed popup)
  AVMEPopupCreateWallet {
    id: createWalletPopup
  }

  AVMEPopupLoadWallet {
    id: loadWalletPopup
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

  // Info popup for if the Wallet creation/loading/importing fails
  AVMEPopupInfo {
    id: walletFailPopup
    icon: "qrc:/img/warn.png"
  }

  // Popup for viewing the seed at Wallet creation
  AVMEPopupNewWalletSeed {
    id: newWalletSeedPopup
    okBtn.onClicked: {
      QmlSystem.createAccount(newWalletSeed, 0, "default", newWalletPass)
      newWalletSeedPopup.clean()
      newWalletSeedPopup.close()
      walletNewPopup.open()
    }
  }

  // Popup for waiting while the first Account is created for a new Wallet
  // TODO: fix this
  AVMEPopup {
    id: walletNewPopup
    property string pass
    //info: "Creating an Account<br>for the new Wallet..."
  }
}

/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"
import "qrc:/qml/panels"

// Starting screen (for managing Wallets)
// TODO: set Ledger flag

Item {
  id: startScreen
  property bool createWalletExists
  property bool loadWalletExists

  Connections {
    target: QmlSystem
    function onAccountCreated(obj) {
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

  // Create/Import Panel
  AVMEPanelCreateWallet {
    id: createWalletPanel
    width: (parent.width * 0.4)
    height: (parent.height * 0.65)
    anchors {
      left: parent.left
      verticalCenter: parent.verticalCenter
      verticalCenterOffset: 50
      margins: 50
    }
  }

  // Text separator
  Text {
    id: separator
    color: "#FFFFFF"
    font.bold: true
    anchors.centerIn: parent
    text: "- or -"
  }

  // Load/Ledger Panel
  AVMEPanelLoadWallet {
    id: loadWalletPanel
    width: (parent.width * 0.4)
    height: (parent.height * 0.65)
    anchors {
      right: parent.right
      verticalCenter: parent.verticalCenter
      verticalCenterOffset: 50
      margins: 50
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
    onAboutToHide: loadWalletPanel.retryTimer.stop()
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
  AVMEPopup {
    id: walletNewPopup
    property string pass
    info: "Creating an Account<br>for the new Wallet..."
  }
}

/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

// Screen for listing Accounts and their general operations
// TODO: back button that closes the Wallet

Item {
  id: accountsScreen

  Connections {
    target: QmlSystem
    function onAccountCreated(data) {
      chooseAccountPopup.clean()
      chooseAccountPopup.close()
      createAccountPopup.close()
      importAccountPopup.close()
      fetchAccounts()
    }
    function onAccountCreationFailed() {
      createAccountPopup.close()
      importAccountPopup.close()
      accountFailPopup.open()
    }
  }

  Component.onCompleted: {
    fetchAccounts()
  }

  function fetchAccounts() {
    accountSelectPanel.accountModel.clear()
    var accList = QmlSystem.listAccounts()
    for (var i = 0; i < accList.length; i++) {
      accountSelectPanel.accountModel.set(i, JSON.parse(accList[i]))
    }
    fetchBalances()
  }

  function fetchBalances() {
    for (var i = 0; i < accountSelectPanel.accountModel.count; i++) {
      var address = accountSelectPanel.accountModel.get(i).address
      var bal = QmlSystem.getAccountAVAXBalance(address)
      var usd = QmlSystem.getAccountAVAXValue(address, bal)
      accountSelectPanel.accountModel.setProperty(i, "coinAmount", bal + " AVAX")
      accountSelectPanel.accountModel.setProperty(i, "coinValue", "$" + usd)
    }
  }

  function useSeed() {
    chooseAccountPopup.foreignSeed = seedPopup.fullSeed
    seedPopup.clean()
    seedPopup.close()
    chooseAccountPopup.open()
  }

  AVMEPopupChooseAccount { id: chooseAccountPopup }
  AVMEPopupSeed { id: seedPopup }

  AVMEPanelAccountSelect {
    id: accountSelectPanel
    height: parent.height * 0.9
    width: parent.width * 0.9
    anchors.centerIn: parent
    btnCreate.onClicked: chooseAccountPopup.open()
    btnImport.onClicked: seedPopup.open()
    btnSelect.onClicked: {
      QmlSystem.setCurrentAccount(accountList.currentItem.itemAddress)
      QmlSystem.goToOverview()
      QmlSystem.setScreen(content, "qml/screens/OverviewScreen.qml")
    }
    btnErase.onClicked: confirmErasePopup.open()
  }

  // Popups for waiting for a new Account to be created/imported, respectively
  // TODO: unify those into one
  AVMEPopup {
    id: createAccountPopup
    widthPct: 0.2
    heightPct: 0.1
    Text {
      color: "#FFFFFF"
      horizontalAlignment: Text.AlignHCenter
      anchors.centerIn: parent
      font.pixelSize: 14.0
      text: "Creating Account..."
    }
  }

  AVMEPopup {
    id: importAccountPopup
    widthPct: 0.2
    heightPct: 0.1
    Text {
      color: "#FFFFFF"
      horizontalAlignment: Text.AlignHCenter
      anchors.centerIn: parent
      font.pixelSize: 14.0
      text: "Importing Account..."
    }
  }

  AVMEPopup {
    id: eraseAccountPopup
    widthPct: 0.2
    heightPct: 0.1
    Text {
      color: "#FFFFFF"
      horizontalAlignment: Text.AlignHCenter
      anchors.centerIn: parent
      font.pixelSize: 14.0
      text: "Erasing Account..."
    }
  }

  // Info popup for if the seed import fails
  AVMEPopupInfo {
    id: seedFailPopup
    icon: "qrc:/img/warn.png"
    info: "Seed is invalid. Please check if it's typed correctly."
  }

  AVMEPopupInfo {
    id: eraseFailPopup
    icon: "qrc:/img/warn.png"
    info: "Failed to erase Account, please try again."
  }

  AVMEPopupYesNo {
    id: confirmErasePopup
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to erase this Account?"
    yesBtn.onClicked: {
      confirmErasePopup.close()
      eraseAccountPopup.open()
      if (QmlSystem.eraseAccount(accountSelectPanel.accountList.currentItem.itemAddress)) {
        eraseAccountPopup.close()
        fetchAccounts()
      } else {
        eraseAccountPopup.close()
        eraseFailPopup.open()
      }
    }
    noBtn.onClicked: {
      confirmErasePopup.close()
    }
  }
}


/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

// Screen for listing and managing Accounts in the Wallet.
Item {
  id: accountsScreen

  Connections {
    target: qmlSystem
    function onAccountCreated(success, data) {
      if (success) {
        chooseAccountPopup.clean()
        chooseAccountPopup.close()
        accountInfoPopup.close()
        ledgerPopup.close()
        fetchAccounts()
      } else {
        accountInfoPopup.close()
        accountFailPopup.open()
      }
    }
    function onAccountAVAXBalancesUpdated(address, avaxBalance, avaxValue) {
      for (var i = 0; i < accountSelectPanel.accountModel.count; i++) {
        if (accountSelectPanel.accountModel.get(i).address == address) {
          accountSelectPanel.accountModel.setProperty(
            i, "coinAmount", avaxBalance + " AVAX"
          )
          accountSelectPanel.accountModel.setProperty(
            i, "coinValue", "$" + avaxValue
          )
        }
      }
    }
  }

  Component.onCompleted: {
    qmlSystem.loadLedgerDB()
    qmlSystem.loadConfigDB()
    fetchAccounts()
  }
  function fetchAccounts() {
    accountSelectPanel.accountModel.clear()
    var accList = qmlSystem.listAccounts()
    var addList = []
    for (var i = 0; i < accList.length; i++) {
      var accJson = JSON.parse(accList[i])
      accountSelectPanel.accountModel.set(i, accJson)
      accountSelectPanel.accountModel.setProperty(i, "coinAmount", "Loading...")
      accountSelectPanel.accountModel.setProperty(i, "coinValue", "Loading...")
      addList.push(accJson.address)
    }
    accountSelectPanel.accountModel.sortByAddress()
    qmlSystem.getAllAVAXBalances(addList)
  }

  function checkLedger() {
    var data = qmlSystem.checkForLedger()
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

  AVMEPanelAccountSelect {
    id: accountSelectPanel
    width: parent.width * 0.95
    height: parent.height * 0.9
    anchors.centerIn: parent
    btnAdd.onClicked: addAccountSelectPopup.open()
    btnSelect.onClicked: chooseSelectedAccount()
    btnErase.onClicked: confirmErasePopup.open()
    function chooseSelectedAccount() {
      qmlSystem.cleanAndCloseAccount()
      if (accountList.currentItem.itemIsLedger) {
        qmlSystem.setLedgerFlag(true)
        qmlSystem.setCurrentHardwareAccount(accountList.currentItem.itemAddress)
        qmlSystem.setCurrentHardwareAccountPath(accountList.currentItem.itemDerivationPath)
        qmlSystem.importLedgerAccount(qmlSystem.getCurrentHardwareAccount(), qmlSystem.getCurrentHardwareAccountPath())
      } else {
        qmlSystem.setLedgerFlag(false)
        qmlSystem.setCurrentAccount(accountList.currentItem.itemAddress)
      }
      qmlSystem.loadHistoryDB(qmlSystem.getCurrentAccount())
      qmlSystem.startWSServer()
      accountHeader.getAddress()
      window.menu.changeScreen("Overview")
    }
  }

  AVMEPopup {
    id: addAccountSelectPopup
    widthPct: 0.4
    heightPct: 0.4
    Column {
      width: parent.width * 0.9
      height: parent.height * 0.9
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      spacing: 20

      Text {
        id: addAccountText
        color: "#FFFFFF"
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 14.0
        text: "Which kind of Account do you want to add?"
      }
      AVMEButton {
        id: addNormalBtn
        width: parent.width
        text: "Add Normal Account"
        onClicked: {
          chooseAccountPopup.foreignSeed = ""
          addAccountSelectPopup.close()
          chooseAccountPopup.open()
        }
      }
      AVMEButton {
        id: addSeedBtn
        width: parent.width
        text: "Import Account From Seed"
        onClicked: {
          addAccountSelectPopup.close()
          chooseAccountPopup.open()
          seedPopup.open()
        }
      }
      AVMEButton {
        id: addLedgerBtn
        width: parent.width
        text: "Import Account From Ledger"
        onClicked: {
          addAccountSelectPopup.close()
          checkLedger()
        }
      }
      AVMEButton {
        id: addBackBtn
        width: parent.width
        text: "Back"
        onClicked: addAccountSelectPopup.close()
      }
    }
  }

  AVMEPopupChooseAccount { id: chooseAccountPopup }
  AVMEPopupSeed { id: seedPopup; clearBtn.visible: false }
  AVMEPopupLedger { id: ledgerPopup }

  AVMEPopup {
    id: accountInfoPopup
    property alias text: accountInfoText.text
    widthPct: 0.2
    heightPct: 0.1
    Text {
      id: accountInfoText
      color: "#FFFFFF"
      horizontalAlignment: Text.AlignHCenter
      anchors.centerIn: parent
      font.pixelSize: 14.0
    }
  }

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
    widthPct: 0.4
    heightPct: 0.25
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to erase this Account?"
    yesBtn.onClicked: {
      confirmErasePopup.close()
      accountInfoPopup.text = "Erasing Account..."
      accountInfoPopup.open()
      if (accountSelectPanel.accountList.currentItem.itemIsLedger) {
        if (qmlSystem.deleteLedgerAccount(accountSelectPanel.accountList.currentItem.itemAddress)) {
          accountInfoPopup.close()
          fetchAccounts()
        } else {
          accountInfoPopup.close()
          eraseFailPopup.open()
        }
      } else {
        if (qmlSystem.eraseAccount(accountSelectPanel.accountList.currentItem.itemAddress)) {
          accountInfoPopup.close()
          fetchAccounts()
        } else {
          accountInfoPopup.close()
          eraseFailPopup.open()
        }
      }
    }
    noBtn.onClicked: {
      confirmErasePopup.close()
    }
  }

  AVMEPopupInfo {
    id: ledgerFailPopup
    icon: "qrc:/img/warn.png"
    onAboutToHide: ledgerRetryTimer.stop()
    okBtn.text: "Close"
  }
}


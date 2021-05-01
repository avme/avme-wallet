/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Screen for listing Accounts and their general operations

Item {
  id: accountsScreen

  Connections {
    target: System
    function onAccountCreated(data) {
      createAccountPopup.close()
      reloadList()
    }
    function onAccountCreationFailed() {
      createAccountPopup.close()
      accountFailPopup.open()
    }
  }

  Component.onCompleted: {
    if (System.getFirstLoad()) {
      System.setFirstLoad(false)
      reloadList()
    } else {
      fetchAccounts()
    }
  }

  // Timer for reloading the Account balances on the list
  Timer {
    id: listReloadTimer
    interval: 1000
    repeat: true
    onTriggered: reloadBalances()
  }

  // Helpers for manipulating the Account list
  function reloadList() {
    console.log("Reloading list...")
    fetchAccountsPopup.open()
    System.stopAllBalanceThreads()
    listReloadTimer.stop()
    System.loadAccounts()
    fetchAccounts()
    System.startAllBalanceThreads()
    listReloadTimer.start()
    fetchAccountsPopup.close()
  }

  function fetchAccounts() {
    console.log("Fetching Accounts...")
    accountsList.clear()
    var accList = System.listAccounts()
    for (var i = 0; i < accList.length; i++) {
      accountsList.append(JSON.parse(accList[i]))
    }
  }

  function reloadBalances() {
    var accList = System.listAccounts()
    for (var i = 0; i < accList.length; i++) {
      accountsList.set(i, JSON.parse(accList[i]))
    }
  }

  // Text if there's no Accounts in the Wallet
  Text {
    id: noAccountsText
    anchors {
      top: parent.top
      topMargin: 60
      horizontalCenter: parent.horizontalCenter
    }
    horizontalAlignment: Text.AlignHCenter
    color: "#FFFFFF"
    font.pointSize: 18.0
    text: "No Accounts found.<br>You can create or import one using the button below."
    visible: (accountsList.count == 0)
  }

  // Account list
  Rectangle {
    id: listRect
    anchors {
      top: parent.top
      bottom: btnBottomRow.top
      left: parent.left
      right: parent.right
      margins: 10
    }
    visible: (accountsList.count != 0)
    radius: 5
    color: "#4458A0C9"

    AVMEWalletList {
      id: walletList
      width: listRect.width
      height: listRect.height
      model: ListModel { id: accountsList }
    }
  }

  // Action buttons
  Row {
    id: btnBottomRow
    spacing: 10
    anchors {
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      bottomMargin: 10
      leftMargin: 10
    }

    AVMEButton {
      id: btnNewAccount
      width: (parent.width / 3) - parent.spacing
      text: "Create/Import a new Account"
      onClicked: chooseAccountPopup.open()
    }

    AVMEButton {
      id: btnUseAccount
      width: (parent.width / 3) - parent.spacing
      enabled: {
        var hasCoin = (walletList.currentItem.itemCoinAmount != "")
        var hasToken = (walletList.currentItem.itemTokenAmount != "")
        var hasFreeLP = (walletList.currentItem.itemFreeLPAmount != "")
        var hasLockedLP = (walletList.currentItem.itemLockedLPAmount != "")
        enabled: (walletList.currentItem && (hasCoin && hasToken && hasFreeLP && hasLockedLP))
      }
      text: "Use this Account"
      onClicked: {
        System.setCurrentAccount(walletList.currentItem.itemAccount)
        listReloadTimer.stop()
        System.goToOverview();
        System.setScreen(content, "qml/screens/OverviewScreen.qml")
      }
    }

    AVMEButton {
      id: btnEraseAccount
      width: (parent.width / 3) - parent.spacing
      enabled: (walletList.currentItem)
      text: "Erase this Account"
      onClicked: {
        erasePopup.account = walletList.currentItem.itemAccount
        erasePopup.open()
      }
    }
  }

  // Popup for choosing an Account from a generated list
  AVMEPopupChooseAccount {
    id: chooseAccountPopup
    chooseBtn.onClicked: {
      if (System.accountExists(item.itemAccount)) {
        addressTimer.start()
      } else if (!System.checkWalletPass(pass)) {
        infoTimer.start()
      } else {
        try {
          System.stopAllBalanceThreads()
          listReloadTimer.stop()
          chooseAccountPopup.close()
          System.createAccount(foreignSeed, index, name, pass)
          chooseAccountPopup.clean()
          createAccountPopup.open()
        } catch (error) {
          chooseAccountPopup.close()
          accountFailPopup.open()
        }
      }
    }
  }

  // Popup for fetching Accounts
  AVMEPopup {
    id: fetchAccountsPopup
    info: "Loading Accounts...<br>Please wait."
  }

  // Popup for waiting for a new Account to be created
  AVMEPopup {
    id: createAccountPopup
    info: "Creating/Importing Account..."
  }

  // Info popup for if the Account creation fails
  AVMEPopupInfo {
    id: accountFailPopup
    icon: "qrc:/img/warn.png"
    info: "Error on Account creation/importing. Please try again."
  }

  // Info popup for if the Account erasure fails
  AVMEPopupInfo {
    id: eraseFailPopup
    icon: "qrc:/img/warn.png"
    info: "Error on erasing Account. Please try again."
  }

  // Yes/No popup for confirming Account erasure
  AVMEPopupYesNo {
    id: erasePopup
    property string account
    height: window.height / 2
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to erase this Account?<br>"
    + "<b>" + account + "</b>"
    + "<br>All funds on it will be <b>PERMANENTLY LOST</b>."

    Text {
      id: erasePassInfo
      property alias timer: erasePassInfoTimer
      y: (parent.height / 2) - 30
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottomMargin: (parent.height / 2) + 50
      Timer { id: erasePassInfoTimer; interval: 2000 }
      color: "#FFFFFF"
      text: (!erasePassInfoTimer.running)
      ? "Please authenticate to confirm the action."
      : "Wrong passphrase, please try again"
    }

    AVMEInput {
      id: erasePassInput
      width: parent.width / 2
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: erasePassInfo.bottom
      anchors.topMargin: 30
      echoMode: TextInput.Password
      passwordCharacter: "*"
      label: "Passphrase"
      placeholder: "Your Wallet's passphrase"
    }

    yesBtn.onClicked: {
      if (System.checkWalletPass(erasePassInput.text)) {
        if (System.eraseAccount(walletList.currentItem.itemAccount)) {
          System.stopAllBalanceThreads()
          listReloadTimer.stop()
          erasePopup.close()
          erasePopup.account = ""
          erasePassInput.text = ""
          reloadList()
        } else {
          erasePopup.close()
          erasePopup.account = ""
          erasePassInput.text = ""
          eraseFailPopup.open()
        }
      } else {
        erasePassInfoTimer.start()
      }
    }
    noBtn.onClicked: {
      erasePopup.account = ""
      erasePassInput.text = ""
      erasePopup.close()
    }
  }
}


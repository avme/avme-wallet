/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

/**
 * Popup for choosing an Account from a list generated with a BIP39 seed.
 * Has to be opened manually.
 * Has the following items:
 * - "startingIndex": the starting index used to generate the Accounts
 * - "isWaiting": boolean for waiting while Accounts are being generated
 * - "foreignSeed": an imported seed that overrides the one from the Wallet
 * - "seedList": the proper Account list
 * - "chooseBtn.onClicked": what to do when confirming the action
 * - "infoTimer / pass": aliases for passphrase timer and the passphrase itself
 * - "refreshList()": start the process of generating more Accounts
 * - "clean()": helper function to clean up inputs/data
 */
AVMEPopup {
  id: chooseAccountPopup
  widthPct: 0.5
  heightPct: 0.95
  property int startingIndex: -1
  property bool isWaiting: false
  property string foreignSeed
  property alias seedList: chooseAccountList
  property alias chooseBtn: btnChoose
  property alias infoTimer: infoPassTimer
  property alias addressTimer: infoAddressTimer
  property alias index: chooseAccountList.currentIndex
  property alias item: chooseAccountList.currentItem
  property alias name: nameInput.text
  property alias pass: passInput.text
  property color popupBgColor: "#1C2029"

  onAboutToShow: passInput.focus = true

  Connections {
    target: qmlSystem
    function onAccountGenerated(data) {
      accountList.append(data)
      isWaiting = false
      qmlSystem.getAccountAVAXBalances(data.account)
    }
    function onAccountAVAXBalancesUpdated(
      address, avaxBalance, avaxValue, avaxPrice, avaxPriceData
    ) {
      for (var i = 0; i < accountList.count; i++) {
        if (accountList.get(i).account == address) {
          accountList.setProperty(i, "balance", avaxBalance)
        }
      }
    }
  }

  function refreshList() {
    if (startingIndex == -1) { startingIndex = 0 }
    qmlSystem.generateAccounts(
      ((foreignSeed != "") ? foreignSeed : qmlSystem.getWalletSeed(passInput.text)),
      startingIndex
    );
    isWaiting = true
  }

  function clean() {
    accountList.clear()
    startingIndex = -1
    isWaiting = false
    nameInput.text = passInput.text = foreignSeed = ""
  }

  Column {
    id: items
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 30

    Text {
      id: infoLabel
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: {
        if (infoPassTimer.running) {
          text: "Wrong password, please try again"
        } else if (infoSeedTimer.running) {
          text: "Seed is invalid, please try another"
        } else if (infoAddressTimer.running) {
          text: "Address is already in Wallet, please try another"
        } else if (isWaiting) {
          text: "Generating Accounts... this may take a while, please wait..."
        } else if (chooseAccountList.currentIndex > -1) {
          text: "Choose an Account from the list."
        } else {
          text: "Enter your passphrase to generate an Account list."
        }
      }
      Timer { id: infoPassTimer; interval: 2000 }
      Timer { id: infoSeedTimer; interval: 2000 }
      Timer { id: infoAddressTimer; interval: 2000 }
    }

    Rectangle {
      id: listRect
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width * 0.7)
      height: (parent.height * 0.6)
      radius: 5
      color: "#16141F"

      AVMEAccountSeedList {
        id: chooseAccountList
        height: parent.height
        width: parent.width
        anchors.fill: parent
        model: ListModel { id: accountList }
      }
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: nameInput
        width: (chooseAccountPopup.width * 0.4)
        enabled: (!isWaiting && chooseAccountList.currentIndex > -1)
        label: "(Optional) Name"
        placeholder: "Name for your Account"
      }

      AVMEInput {
        id: passInput
        width: (chooseAccountPopup.width * 0.4)
        enabled: (!isWaiting)
        echoMode: TextInput.Password
        passwordCharacter: "*"
        label: "Passphrase"
        placeholder: "Your Wallet's passphrase"
      }
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btnChoose
        width: (chooseAccountPopup.width * 0.4)
        enabled: (!isWaiting && passInput.text != "" && chooseAccountList.currentIndex > -1)
        text: "Choose this Account"
        onClicked: {
          if (qmlSystem.accountExists(item.itemAccount)) {
            addressTimer.start()
          } else if (!qmlSystem.checkWalletPass(pass)) {
            infoTimer.start()
          } else {
            accountInfoPopup.text = (foreignSeed == "")
              ? "Creating Account..." : "Importing Account..."
            accountInfoPopup.open()
            qmlSystem.createAccount(foreignSeed, index, name, pass)
          }
        }
      }

      AVMEButton {
        id: btnMore
        width: (chooseAccountPopup.width * 0.4)
        enabled: (!isWaiting && passInput.text != "")
        text: "Generate +10 Accounts"
        onClicked: {
          if (foreignSeed != "" && !qmlSystem.seedIsValid(foreignSeed)) {
            infoSeedTimer.start()
          } else if (!qmlSystem.checkWalletPass(passInput.text)) {
            infoPassTimer.start()
          } else {
            if (startingIndex != -1) { startingIndex += 10 }
            refreshList()
          }
        }
      }
    }

    AVMEButton {
      id: btnBack
      width: (chooseAccountPopup.width * 0.8)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (!isWaiting)
      text: "Back"
      onClicked: {
        chooseAccountPopup.clean()
        chooseAccountPopup.close()
      }
    }
  }
}

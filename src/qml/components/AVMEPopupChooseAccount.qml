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

Popup {
  id: chooseAccountPopup
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

  Connections {
    target: System

    onAccountsGenerated: {
      for (var i = 0; i < accounts.length; i++) {
        accountList.append(JSON.parse(accounts[i]))
      }
      isWaiting = false
    }
  }

  function refreshList() {
    if (startingIndex == -1) { startingIndex = 0 }
    System.generateAccounts(
      ((foreignSeed != "") ? foreignSeed : System.getWalletSeed(passInput.text)),
      startingIndex
    );
    isWaiting = true
  }

  function clean() {
    accountList.clear()
    startingIndex = -1
    isWaiting = false
    seedInput.enabled = true
    nameInput.text = passInput.text = seedInput.text = foreignSeed = ""
  }

  width: parent.width * 0.9
  height: parent.height * 0.9
  x: (parent.width * 0.1) / 2
  y: (parent.height * 0.1) / 2
  modal: true
  focus: true
  padding: 0  // Remove white borders
  closePolicy: Popup.NoAutoClose
  background: Rectangle { anchors.fill: parent; color: popupBgColor; radius: 10 }

  Column {
    id: items
    anchors.fill: parent
    spacing: 30
    topPadding: 20

    Text {
      id: infoLabel
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
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
      width: (items.width * 0.9)
      height: (items.height * 0.55)
      anchors.horizontalCenter: parent.horizontalCenter
      radius: 5
      color: "#4458A0C9"

      AVMEAccountSeedList {
        id: chooseAccountList
        anchors.fill: parent
        model: ListModel { id: accountList }
      }
    }

    AVMEInput {
      id: seedInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: (items.width * 0.9)
      label: "(Optional) Override seed"
      placeholder: "Enter a seed here to import Accounts from different Wallets"
    }

    Row {
      id: inputRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: nameInput
        width: items.width / 4
        enabled: (!isWaiting && chooseAccountList.currentIndex > -1)
        label: "(Optional) Name"
        placeholder: "Name for your Account"
      }

      AVMEInput {
        id: passInput
        width: items.width / 4
        enabled: (!isWaiting)
        echoMode: TextInput.Password
        passwordCharacter: "*"
        label: "Passphrase"
        placeholder: "Your Wallet's passphrase"
      }
    }

    Row {
      id: bottomRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btnBack
        width: (items.width / 4) - parent.spacing
        enabled: (!isWaiting)
        text: "Back"
        onClicked: {
          chooseAccountPopup.clean()
          chooseAccountPopup.close()
        }
      }
      AVMEButton {
        id: btnChoose
        width: (items.width / 4) - parent.spacing
        enabled: (!isWaiting && passInput.text != "" && chooseAccountList.currentIndex > -1)
        text: "Choose this Account"
      }
      AVMEButton {
        id: btnMore
        width: (items.width / 4) - parent.spacing
        enabled: (!isWaiting && passInput.text != "")
        text: "Generate +10 Accounts"
        onClicked: {
          if (seedInput.text != "" && !System.seedIsValid(seedInput.text)) {
            infoSeedTimer.start()
          } else if (!System.checkWalletPass(passInput.text)) {
            infoPassTimer.start()
          } else {
            seedInput.enabled = false
            if (seedInput.text != "") { foreignSeed = seedInput.text }
            if (startingIndex != -1) { startingIndex += 10 }
            refreshList()
          }
        }
      }
    }
  }
}
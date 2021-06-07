/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

/**
 * Popup for choosing an Account from a Ledger device.
 * Has to be opened manually.
 * Has the following items:
 * - "chosenPath": the selected derivation path
 * - "startingIndex": the starting index used to generate the Accounts
 * - "isWaiting": boolean for waiting while Accounts are being generated
 * - "ledgerList": the proper Account list
 * - "pathValue": the current derivation path in the combobox
 * - "chooseBtn.onClicked": what to do when confirming the action
 * - "refreshList()": start the process of generating more Accounts
 * - "clean()": helper function to clean up inputs/data
 */
Popup {
  id: ledgerPopup
  property string chosenPath: ""
  property int startingIndex: -1
  property bool isWaiting: false
  property alias ledgerList: ledgerAccountList
  property alias chooseBtn: btnChoose
  property alias index: ledgerAccountList.currentIndex
  property alias item: ledgerAccountList.currentItem
  property alias pathValue: ledgerPath.currentValue
  property color popupBgColor: "#1C2029"

  Connections {
    target: System
    function onLedgerAccountGenerated(data) {
      accountList.append(data)
      isWaiting = false
    }
  }

  function refreshList() {
    System.generateLedgerAccounts(chosenPath, startingIndex)
    isWaiting = true
  }

  function clean() {
    accountList.clear()
    System.cleanLedgerAccounts()
    startingIndex = -1
    isWaiting = false
    chosenPath = ""
  }

  width: window.width * 0.9
  height: 700
  x: (window.width * 0.1) / ((window.menuToggle) ? (width / 2) : 2)
  y: (window.height * 0.5) - (height / 2)
  modal: true
  focus: true
  padding: 0  // Remove white borders
  closePolicy: Popup.NoAutoClose
  background: Rectangle { anchors.fill: parent; color: popupBgColor; radius: 10 }

  Row {
    id: topRow
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 20

    Text {
      id: infoLabel
      anchors {
        top: parent.top
        margins: 20
      }
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: {
        if (isWaiting) {
          text: "Generating Accounts..."
        } else {
          text: "Choose a derivation path:"
        }
      }
    }
    ComboBox {
      id: ledgerPath
      anchors.verticalCenter: infoLabel.verticalCenter
      width: 300
      model: [
        "m/44'/60'/0'/",
        "m/44'/60'/0'/0/",
        "m/44'/60'/160720'/0'/",
        "m/44'/1'/0'/0/",
        "m/44'/60'/0'/0/0/",
      ]
    }
  }

  Rectangle {
    id: listRect
    anchors {
      top: topRow.bottom
      left: parent.left
      right: parent.right
      margins: 20
    }
    height: (parent.height * 0.8)
    radius: 5
    color: "#4458A0C9"

    AVMEAccountSeedList {
      id: ledgerAccountList
      anchors.fill: parent
      model: ListModel { id: accountList }
    }
  }

  Row {
    id: bottomRow
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      margins: 20
    }
    spacing: 10

    AVMEButton {
      id: btnBack
      width: (ledgerPopup.width / 4) - parent.spacing
      enabled: (!isWaiting)
      text: "Back"
      onClicked: {
        ledgerPopup.clean()
        ledgerPopup.close()
      }
    }
    AVMEButton {
      id: btnChoose
      width: (ledgerPopup.width / 4) - parent.spacing
      enabled: (!isWaiting && ledgerAccountList.currentIndex > -1)
      text: "Choose this Account"
      onClicked: {
        // Always default to AVAX & AVME on first load
        if (System.getCurrentCoin() == "") {
          System.setCurrentCoin("AVAX")
          System.setCurrentCoinDecimals(18)
        }
        if (System.getCurrentToken() == "") {
          System.setCurrentToken("AVME")
          System.setCurrentTokenDecimals(18)
        }
        System.stopAllBalanceThreads()
        System.setLedger(true);
        System.setCurrentAccount(ledgerList.currentItem.itemAccount)
        System.setCurrentAccountPath(ledgerPopup.pathValue + ledgerPopup.index)
        System.importLedgerAccount(System.getCurrentAccount(), System.getCurrentAccountPath());
        System.startAllBalanceThreads()
        System.goToOverview();
        System.setScreen(content, "qml/screens/OverviewScreen.qml")
      }
    }
    AVMEButton {
      id: btnMore
      width: (ledgerPopup.width / 4) - parent.spacing
      enabled: (!isWaiting)
      text: "Generate +10 Accounts"
      onClicked: {
        if (startingIndex == -1) {
          startingIndex = 0
        } else if (startingIndex != -1) {
          startingIndex += 10
        }
        if (pathValue != chosenPath) {
          chosenPath = pathValue
        }
        accountList.clear()
        refreshList()
      }
    }
  }
}


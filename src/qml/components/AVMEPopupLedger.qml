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
    target: qmlSystem
    function onLedgerAccountGenerated(dataStr) {
      var data = JSON.parse(dataStr)
      for (var account in data) {
        accountList.append(data[account])
      }
      isWaiting = false
    }
  }

  function refreshList() {
    qmlSystem.generateLedgerAccounts(chosenPath, startingIndex)
    isWaiting = true
  }

  function clean() {
    accountList.clear()
    qmlSystem.cleanLedgerAccounts()
    startingIndex = -1
    isWaiting = false
    chosenPath = ""
  }

  width: (parent.width * 0.9)
  height: (parent.height * 0.9)
  x: (parent.width * 0.1) / 2
  y: (parent.height * 0.5) - (height / 2)
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
    AVMECombobox {
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

  Image {
    id: ledgerLoadingPng
    visible: isWaiting
    width: parent.height * 0.25
    height: width
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    fillMode: Image.PreserveAspectFit
    source: "qrc:/img/icons/loading.png"
    RotationAnimator {
      target: ledgerLoadingPng
      from: 0
      to: 360
      duration: 1000
      loops: Animation.Infinite
      easing.type: Easing.InOutQuad
      running: true
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
        qmlSystem.importLedgerAccount(ledgerList.currentItem.itemAccount, ledgerPopup.pathValue + ledgerPopup.index);
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


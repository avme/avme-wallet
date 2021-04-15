/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Popup for creting a new Account. Has to be opened manually.
 * Has the following items:
 * - "name" (optional, readonly): the Account's name/label
 * - "pass" (readonly): the Wallet password input
 * - "doneBtn.onClicked": what to do when confirming the action
 * - "clean()": helper function to clean up inputs/data
 */

Popup {
  id: newAccountPopup
  readonly property alias name: nameInput.text
  readonly property alias pass: passInput.text
  property alias doneBtn: btnDone

  function clean() {
    nameInput.text = passInput.text = ""
  }

  width: window.width / 2
  height: window.height / 2
  x: width / 2
  y: height / 2
  modal: true
  focus: true
  padding: 0  // Remove white borders
  closePolicy: Popup.NoAutoClose
  background: Rectangle { anchors.fill: parent; color: "#9A4FAD" }

  Column {
    anchors.fill: parent
    spacing: 30
    topPadding: 40

    // Account name/label
    Text {
      id: nameInfo
      anchors.horizontalCenter: parent.horizontalCenter
      text: "You can give a name to your Account, or leave blank for nothing."
    }

    AVMEInput {
      id: nameInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width / 1.5
      label: "Name (optional)"
      placeholder: "Label for your Account"
    }

    // Passphrase
    Text {
      id: passInfo
      property alias timer: passInfoTimer
      anchors.horizontalCenter: parent.horizontalCenter
      Timer { id: passInfoTimer; interval: 2000 }
      text: (!passInfoTimer.running)
      ? "Please authenticate to confirm the action."
      : "Wrong passphrase, please try again"
    }

    AVMEInput {
      id: passInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width / 2
      echoMode: TextInput.Password
      passwordCharacter: "*"
      label: "Passphrase"
      placeholder: "Your Wallet's passphrase"
    }

    // Buttons
    Row {
      id: btnRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btnBack
        width: newAccountPopup.width / 4
        text: "Back"
        onClicked: {
          newAccountPopup.clean()
          newAccountPopup.close()
        }
      }

      AVMEButton {
        id: btnDone
        width: newAccountPopup.width / 4
        text: "Done"
        enabled: (passInput.text !== "")
      }
    }
  }
}

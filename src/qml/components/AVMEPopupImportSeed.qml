/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Popup for importing an Account using a BIP39 seed. Has to be opened manually.
 * Has the following items:
 * - "seed": the 12-word seed input
 * - "doneBtn.onClicked": what to do when confirming the action
 * - "clean()": helper function to clean up inputs/data
 */

Popup {
  id: importSeedPopup
  readonly property alias seed: seedInput.text
  readonly property alias name: nameInput.text
  readonly property alias pass: passInput.text
  property alias doneBtn: btnDone

  function clean() {
    seedInput.text = ""
  }

  width: window.width - 200
  height: (window.height / 2) + 50
  x: 100
  y: (window.height / 2) - 200
  modal: true
  focus: true
  padding: 0  // Remove white borders
  closePolicy: Popup.NoAutoClose
  background: Rectangle { anchors.fill: parent; color: "#9A4FAD" }

  Column {
    anchors.fill: parent
    spacing: 30
    topPadding: 40

    Text {
      id: infoText
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      text: "Please enter your Account's 12-word seed (words separated by SPACE)."
    }

    AVMEInput {
      id: seedInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width - 100
      label: "Seed"
      placeholder: "Your 12-word seed"
    }

    AVMEInput {
      id: nameInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width / 4
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
      width: parent.width / 4
      echoMode: TextInput.Password
      passwordCharacter: "*"
      label: "Passphrase"
      placeholder: "Your Wallet's passphrase"
    }

    Text {
      id: errorText
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      visible: false
      text: "Invalid seed, please check the words and/or length."
      Timer { id: errorTimer; interval: 2000; onTriggered: errorText.visible = false }
    }

    Row {
      id: btnRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btnBack
        text: "Back"
        onClicked: {
          importSeedPopup.clean()
          importSeedPopup.close()
        }
      }
      AVMEButton {
        id: btnDone
        text: "Done"
        enabled: (seedInput.text !== "")
      }
    }
  }
}

import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Popup for importing a BIP39 seed. Has to be opened manually.
 * Has the following items:
 * - "seed": the 12-word seed input
 * - "doneBtn.onClicked": what to do when confirming the action
 * - "clean()": helper function to clean up inputs/data
 */

Popup {
  id: importSeedPopup
  readonly property alias seed: seedInput.text
  property alias doneBtn: btnDone

  function clean() {
    seedInput.text = ""
  }

  width: window.width - 200
  height: (window.height / 4) + 50
  x: 100
  y: (window.height / 2) - 100
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

import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Popup for viewing the Wallet's seed. Has to be opened manually.
 * Has the following items:
 * - "pass" (readonly): the Wallet password input
 * - "showBtn.onClicked": what to do when confirming the action
 * - "showSeed()": self-explanatory
 * - "showErrorMsg()": self-explanatory
 * - "clean()": helper function to clean up inputs/data
 */

Popup {
  id: viewSeedPopup
  readonly property alias pass: passInput.text
  property alias showBtn: btnShow

  function showSeed() {
    if (seedText.timer.running) { seedText.timer.stop() }
    seedText.text = System.getWalletSeed(passInput.text)
  }

  function showErrorMsg() {
    seedText.text = "Wrong passphrase, please try again"
    seedText.timer.start()
  }

  function clean() {
    passInput.text = ""
    seedText.text = ""
  }

  width: (window.width * 0.85)
  height: (window.height * 0.6)
  x: (window.width * 0.15) / 2
  y: (window.height * 0.4) / 2
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
      id: warningText
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      text: "Please authenticate to view the seed for this Wallet.<br>"
      + "<br><br><b>YOU ARE FULLY RESPONSIBLE FOR GUARDING YOUR SEED."
      + "<br>KEEP IT AWAY FROM PRYING EYES AND DO NOT SHARE IT WITH ANYONE."
      + "<br>WE ARE NOT HELD LIABLE FOR ANY POTENTIAL FUND LOSSES CAUSED BY THIS."
      + "<br>PROCEED AT YOUR OWN RISK.</b>"
    }

    AVMEInput {
      id: passInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width / 3
      echoMode: TextInput.Password
      passwordCharacter: "*"
      label: "Passphrase"
      placeholder: "Your Wallet's passphrase"
    }

    TextArea {
      id: seedText
      property alias timer: seedTextTimer
      width: parent.width - 100
      height: 50
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      readOnly: true
      selectByMouse: true
      selectionColor: "#9CE3FD"
      color: "black"
      background: Rectangle {
        width: parent.width
        height: parent.height
        color: "#782D8B"
      }
      Timer { id: seedTextTimer; interval: 2000; onTriggered: seedText.text = "" }
    }

    Row {
      id: btnRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btnClose
        text: "Close"
        onClicked: {
          viewSeedPopup.clean()
          viewSeedPopup.close()
        }
      }
      AVMEButton {
        id: btnShow
        text: "Show"
        enabled: (passInput.text !== "")
      }
    }
  }
}

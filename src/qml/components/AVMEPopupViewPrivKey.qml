import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Popup for viewing an Account's private key. Has to be opened manually.
 * Has the following items:
 * - "account": the Account bound to the private key
 * - "pass" (readonly): the Wallet password input
 * - "showBtn.onClicked": what to do when confirming the action
 * - "showPrivKey()": self-explanatory
 * - "showErrorMsg()": self-explanatory
 * - "clean()": helper function to clean up inputs/data
 */

Popup {
  id: viewPrivKeyPopup
  property string account
  readonly property alias pass: keyPassInput.text
  property alias showBtn: btnShow

  function showPrivKey() {
    if (keyText.timer.running) { keyText.timer.stop() }
    keyText.text = System.getPrivateKeys(account, keyPassInput.text)
  }

  function showErrorMsg() {
    keyText.text = "Wrong passphrase, please try again"
    keyText.timer.start()
  }

  function clean() {
    account = ""
    keyPassInput.text = ""
    keyText.text = ""
  }

  width: (window.width / 2) + 200
  height: (window.height / 2) + 50
  x: (width / 2) - 200
  y: (height / 2) - 50
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
      text: "Please authenticate to view the private key for the Account:<br>"
      + "<b>" + account + "</b>"
      + "<br><br><b>YOU ARE FULLY RESPONSIBLE FOR GUARDING YOUR PRIVATE KEYS."
      + "<br>KEEP THEM AWAY FROM PRYING EYES AND DO NOT SHARE THEM WITH ANYONE."
      + "<br>WE ARE NOT HELD LIABLE FOR ANY POTENTIAL FUND LOSSES CAUSED BY THIS."
      + "<br>PROCEED AT YOUR OWN RISK.</b>"
    }

    AVMEInput {
      id: keyPassInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width / 3
      echoMode: TextInput.Password
      passwordCharacter: "*"
      label: "Passphrase"
      placeholder: "Your Wallet's passphrase"
    }

    TextArea {
      id: keyText
      property alias timer: keyTextTimer
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
      Timer { id: keyTextTimer; interval: 2000; onTriggered: keyText.text = "" }
    }

    Row {
      id: btnRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btnClose
        text: "Close"
        onClicked: {
          viewPrivKeyPopup.clean()
          viewPrivKeyPopup.close()
        }
      }
      AVMEButton {
        id: btnShow
        text: "Show"
        enabled: (keyPassInput.text !== "")
      }
    }
  }
}

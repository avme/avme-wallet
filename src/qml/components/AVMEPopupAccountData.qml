import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Popup for showing a new Account's data. Has to be opened manually.
 * Has the following items:
 * - "accId": the Account's id
 * - "accName": the Account's name/label (if it has one)
 * - "accAddress": the Account's address
 * - "accSeed": the Account's BIP39 seed
 * - "okBtn.onClicked": what to do when confirming the action
 * - "setData(id, name, address, seed)": set Account data to be shown
 * - "clean()": helper function to clean up inputs/data
 */

Popup {
  id: accountDataPopup
  property string accId
  property string accName
  property string accAddress
  property string accSeed
  property alias okBtn: btnOk

  function setData(id, name, address, seed) {
    accId = id
    accName = name
    accAddress = address
    accSeed = ""
    for (var i = 0; i < 12; i++) {
      accSeed += seed[i];
      if (i != 11) { accSeed += " "; }
    }
  }

  function clean() {
    accId = accName = accAddress = accSeed = ""
  }

  width: window.width
  height: (window.height / 2) + 50
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
      id: infoLabel
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      text: "Account successfully created!"
    }

    Text {
      id: infoText
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignLeft
      text: "<b>Id:</b> " + accId
      + "<br><b>Name:</b> " + accName
      + "<br><b>Address:</b> " + accAddress
    }
    
    Text {
      id: seedLabel
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      text: "This is your seed for this Account. Please write it down."
      + "<br><b>YOU ARE FULLY RESPONSIBLE FOR GUARDING YOUR SEED."
      + "<br>KEEP IT AWAY FROM PRYING EYES AND DO NOT SHARE IT WITH ANYONE.</b>"
    }

    TextArea {
      id: seedText
      width: parent.width - 10
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
      text: accSeed
    }

    AVMEButton {
      id: btnOk
      anchors.horizontalCenter: parent.horizontalCenter
      text: "OK"
    }
  }
}

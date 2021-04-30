/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

// Popup for viewing the Wallet's seed.
Popup {
  id: viewSeedPopup
  property string newWalletPass
  property string newWalletSeed
  property alias pass: passInput
  property alias seed: seedText
  property alias showBtn: btnShow
  property alias closeBtn: btnClose
  property color popupBgColor: "#1C2029"
  property color popupSeedBgColor: "#2D3542"
  property color popupSelectionColor: "#58A0B9"

  function showSeed() {
    if (seedText.timer.running) { seedText.timer.stop() }
    seedText.text = System.getWalletSeed(passInput.text)
    newWalletSeed = seedText.text
  }

  function showErrorMsg() {
    seedText.text = "Wrong passphrase, please try again"
    seedText.timer.start()
  }

  function clean() {
    passInput.text = ""
    seedText.text = ""
  }

  width: (parent.width * 0.9)
  height: (parent.height * 0.6)
  x: (parent.width * 0.1) / 2
  y: (parent.height * 0.4) / 2
  modal: true
  focus: true
  padding: 0  // Remove white borders
  closePolicy: Popup.NoAutoClose
  background: Rectangle { anchors.fill: parent; color: popupBgColor; radius: 10 }

  Column {
    anchors.fill: parent
    spacing: 30
    topPadding: 40

    Text {
      id: warningText
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
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
      selectionColor: popupSelectionColor
      color: "#FFFFFF"
      background: Rectangle {
        width: parent.width
        height: parent.height
        color: popupSeedBgColor
        radius: 10
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

/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Copy of AVMEPopupViewSeed for the Create Account screen.
AVMEPopup {
  id: newWalletSeedPopup
  property string newWalletSeed
  property alias seed: seedText
  property alias okBtn: btnOk
  property color popupBgColor: "#1C2029"
  property color popupSeedBgColor: "#2D3542"
  property color popupSelectionColor: "#58A0B9"

  function showSeed(pass) {
    seedText.text = qmlSystem.getWalletSeed(pass)
    newWalletSeed = seedText.text
  }

  function clean() {
    seedText.text = ""
  }

  Column {
    id: items
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 30

    Text {
      id: warningText
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "This is your seed for this Wallet. Please note it down.<br>"
      + "You can view it at any time in the Settings menu.<br>"
      + "<br><br><b>YOU ARE FULLY RESPONSIBLE FOR GUARDING YOUR SEED."
      + "<br>KEEP IT AWAY FROM PRYING EYES AND DO NOT SHARE IT WITH ANYONE."
      + "<br>WE ARE NOT HELD LIABLE FOR ANY POTENTIAL FUND LOSSES CAUSED BY THIS."
      + "<br>PROCEED AT YOUR OWN RISK.</b>"
    }

    TextArea {
      id: seedText
      width: (parent.width * 0.9)
      height: 75
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      readOnly: true
      selectByMouse: true
      selectionColor: popupSelectionColor
      color: "#FFFFFF"
      wrapMode: Text.Wrap
      font.pixelSize: 14.0
      background: Rectangle {
        width: parent.width
        height: parent.height
        color: popupSeedBgColor
        radius: 10
      }
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btnCopyToClipboard
        width: (items.width * 0.2)
        enabled: (!copyTimer.running)
        text: (!copyTimer.running) ? "Copy To Clipboard" : "Copied!"
        onClicked: {
          qmlSystem.copyToClipboard(seedText.text)
          copyTimer.start()
        }
        Timer { id: copyTimer; interval: 2000 }
      }

      AVMEButton {
        id: btnOk
        width: (items.width * 0.2)
        text: "OK"
      }
    }
  }
}

/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Popup for viewing the Wallet's seed.
AVMEPopup {
  id: viewSeedPopup
  widthPct: 0.75
  heightPct: 0.65
  property string newWalletPass
  property string newWalletSeed
  property color popupBgColor: "#1C2029"
  property color popupSeedBgColor: "#2D3542"
  property color popupSelectionColor: "#58A0B9"

  onAboutToShow: {
    btnCopy.enabled = false
    passInput.focus = true
  }
  onAboutToHide: viewSeedPopup.clean()

  function showSeed() {
    if (seedText.timer.running) { seedText.timer.stop() }
    seedText.text = qmlSystem.getWalletSeed(passInput.text)
    newWalletSeed = seedText.text
    btnCopy.enabled = true
  }

  function showErrorMsg() {
    seedText.text = "Wrong passphrase, please try again"
    seedText.timer.start()
    btnCopy.enabled = false
  }

  function clean() {
    passInput.text = ""
    seedText.text = ""
    btnCopy.enabled = false
  }

  Column {
    id: items
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 30

    // Enter/Numpad enter key override
    Keys.onPressed: {
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        if (btnShow.enabled) { btnShow.checkPass() }
      }
    }

    Text {
      id: warningText
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
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
      width: (parent.width * 0.9)
      height: 75
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      readOnly: true
      selectByMouse: true
      selectionColor: popupSelectionColor
      color: "#FFFFFF"
      font.pixelSize: 14.0
      wrapMode: Text.Wrap
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
        onClicked: viewSeedPopup.close()
      }
      AVMEButton {
        id: btnCopy
        text: (!copyTimer.running) ? "Copy" : "Copied!"
        Timer { id: copyTimer; interval: 2000 }
        onClicked: {
          qmlSystem.copyToClipboard(seedText.text)
          copyTimer.start()
        }
      }
      AVMEButton {
        id: btnShow
        text: "Show"
        enabled: (passInput.text !== "")
        onClicked: checkPass()
        function checkPass() {
          if (qmlSystem.checkWalletPass(passInput.text)) {
            showSeed()
          } else {
            showErrorMsg()
          }
        }
      }
    }
  }
}

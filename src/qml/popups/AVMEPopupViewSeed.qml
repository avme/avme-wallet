/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Popup for viewing the Wallet's seed.
AVMEPopup {
  id: viewSeedPopup
  widthPct: 0.7
  heightPct: 0.5
  property string newWalletPass
  property string newWalletSeed
  property color popupBgColor: "#1C2029"
  property color popupSeedBgColor: "#2D3542"
  property color popupSelectionColor: "#58A0B9"

  onAboutToShow: btnCopy.enabled = false

  function showSeed() {
    if (seedText.timer.running) { seedText.timer.stop() }
    seedText.text = QmlSystem.getWalletSeed(passInput.text)
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

  Text {
    id: warningText
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      topMargin: 20
    }
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
    anchors {
      top: warningText.bottom
      horizontalCenter: parent.horizontalCenter
      margins: 20
    }
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
    anchors {
      top: passInput.bottom
      left: parent.left
      right: parent.right
      bottom: btnRow.top
      margins: 20
    }
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    readOnly: true
    selectByMouse: true
    selectionColor: popupSelectionColor
    color: "#FFFFFF"
    font.pixelSize: 14.0
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
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      bottomMargin: 20
    }
    spacing: 20

    AVMEButton {
      id: btnClose
      text: "Close"
      onClicked: {
        viewSeedPopup.clean()
        viewSeedPopup.close()
      }
    }
    AVMEButton {
      id: btnCopy
      text: (!copyTimer.running) ? "Copy" : "Copied!"
      Timer { id: copyTimer; interval: 2000 }
      onClicked: {
        QmlSystem.copyToClipboard(seedText.text)
        copyTimer.start()
      }
    }
    AVMEButton {
      id: btnShow
      text: "Show"
      enabled: (passInput.text !== "")
      onClicked: {
        if (QmlSystem.checkWalletPass(passInput.text)) {
          showSeed()
        } else {
          showErrorMsg()
        }
      }
    }
  }
}

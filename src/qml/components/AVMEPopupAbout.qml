/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Popup for showing info about the program and other legal jib-jab.
Popup {
  id: aboutPopup
  property color popupBgColor: "#1C2029"
  width: window.width * 0.5
  height: window.height * 0.5
  x: (window.width * 0.5) / 2
  y: (window.height * 0.5) / 2
  modal: true
  focus: true
  padding: 0  // Remove white borders
  closePolicy: Popup.NoAutoClose
  background: Rectangle { anchors.fill: parent; color: popupBgColor; radius: 10 }

  Text {
    id: header
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      topMargin: 20
    }
    font.pointSize: 18.0
    color: "#FFFFFF"
    horizontalAlignment: Text.AlignHCenter
    text: "About the AVME Wallet"
  }

  Image {
    id: logo
    height: 128
    anchors {
      top: header.bottom
      horizontalCenter: parent.horizontalCenter
      topMargin: 10
    }
    antialiasing: true
    smooth: true
    source: "qrc:/img/avme_logo_hd.png"
    fillMode: Image.PreserveAspectFit
  }

  Text {
    id: aboutText
    anchors {
      top: logo.bottom
      horizontalCenter: parent.horizontalCenter
      topMargin: 10
    }
    color: "#FFFFFF"
    horizontalAlignment: Text.AlignHCenter
    textFormat: Text.RichText
    text: "Copyright (c) 2020-2021 AVME Developers<br>
    Distributed under the MIT/X11 software license,<br>
    see the accompanying file LICENSE or<br>
    <a style=\"text-decoration-color: #368097\" href=\"http://www.opensource.org/licenses/mit-license.php\">
    http://www.opensource.org/licenses/mit-license.php</a>."
    onLinkActivated: Qt.openUrlExternally(link)
  }

  Row {
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      bottomMargin: 20
    }  
    spacing: 10

    AVMEButton {
      id: btnAboutQt
      anchors.verticalCenter: parent.verticalCenter
      text: "About Qt"
      onClicked: System.openQtAbout()
    }

    AVMEButton {
      id: btnClose
      anchors.verticalCenter: parent.verticalCenter
      text: "Close"
      onClicked: aboutPopup.close()
    }
  }
}

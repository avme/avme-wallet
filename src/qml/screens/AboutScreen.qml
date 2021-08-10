/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtCharts 2.2

import "qrc:/qml/components"

// Screen for showing info about the project
Item {
  id: aboutScreen

  AVMEPanel {
    id: aboutPanel
    anchors {
      top: parent.top
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      margins: 10
    }
    title: "About the Program"

    Column {
      anchors.centerIn: parent
      spacing: 40

      Image {
        id: logo
        height: 256
        anchors.horizontalCenter: parent.horizontalCenter
        antialiasing: true
        smooth: true
        source: "qrc:/img/avme_logo_hd.png"
        fillMode: Image.PreserveAspectFit
      }

      Text {
        id: header
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 18.0
        color: "#FFFFFF"
        horizontalAlignment: Text.AlignHCenter
        font.bold: true
        text: "AVME WALLET " + qmlSystem.getProjectVersion()
      }

      Text {
        id: aboutText
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#FFFFFF"
        font.pixelSize: 18.0
        horizontalAlignment: Text.AlignHCenter
        textFormat: Text.RichText
        text: "COPYRIGHT © 2020-2021 AVME DEVELOPERS<br>
        DISTRIBUTED UNDER THE MIT/X11 SOFTWARE LICENSE<br>
        SEE THE ACCOMPANYING LICENSE FILE OR<br>
        <a style=\"text-decoration-color: #368097\" href=\"http://www.opensource.org/licenses/mit-license.php\">
        http://www.opensource.org/licenses/mit-license.php</a>."
        onLinkActivated: Qt.openUrlExternally(link)
      }

      AVMEButton {
        id: btnAboutQt
        anchors.horizontalCenter: parent.horizontalCenter
        text: "About Qt"
        onClicked: qmlSystem.openQtAbout()
      }
    }
  }
}

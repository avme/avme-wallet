/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

// Panel template for basic info/data/etc.
Rectangle {
  id: panel
  property alias title: titleText.text

  implicitWidth: 300
  implicitHeight: 300
  color: "#0F0C18"
  radius: 5
  border.color: "#1D1827"
  border.width: 10

  Text {
    id: titleText
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      margins: 20
    }
    color: "#FFFFFF"
    font.pixelSize: 18.0
    font.bold: true
    font.capitalization: Font.AllUppercase
    text: "Title"

    Rectangle {
      id: titleUnderline
      color: parent.color
      width: (parent.width * 1.1)
      height: 1
      anchors {
        top: parent.bottom
        horizontalCenter: parent.horizontalCenter
        topMargin: 5
      }
    }
  }
}

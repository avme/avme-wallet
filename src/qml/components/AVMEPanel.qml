/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Panel template for basic info/data/etc.
Rectangle {
  id: panel
  property alias title: titleLabel.text
  property alias header: panelHeader

  implicitWidth: 300
  implicitHeight: 300
  color: "#2D3542"
  radius: 10

  Rectangle {
    id: panelHeader
    anchors.top: parent.top
    width: parent.width
    height: 40
    color: "#1D212A"
    radius: 10

    Label {
      id: titleLabel
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      anchors.leftMargin: 10
      color: "#FFFFFF"
      text: "Title"
    }
    Rectangle {
      id: headerBottom
      anchors.bottom: parent.bottom
      width: parent.width
      height: 10
      color: "#1D212A"
    }
  }
}

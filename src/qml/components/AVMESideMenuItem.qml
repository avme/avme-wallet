import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Individual item for the side menu

Rectangle {
  id: sideMenuItem
  property alias icon: itemIcon.source
  property alias label: itemLabel.text
  signal changeActiveItem()

  implicitWidth: 70
  implicitHeight: 70
  anchors.horizontalCenter: parent.horizontalCenter
  color: "#1C2029"

  Image {
    id: itemIcon
    width: parent.width
    height: parent.height * 0.6
    anchors.top: parent.top
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    fillMode: Image.PreserveAspectFit
    antialiasing: true
    smooth: true
  }

  Text {
    id: itemLabel
    width: parent.width
    height: parent.height * 0.4
    anchors.bottom: parent.bottom
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    font.pointSize: 8.0
    color: "#FFFFFF"
  }

  MouseArea {
    id: itemMouseArea
    anchors.fill: parent
    hoverEnabled: true
    onEntered: parent.color = "#3E424B"
    onExited: parent.color = "#1C2029"
    onClicked: {
      parent.color = "#1C2029"
      changeActiveItem()
    }
  }
}


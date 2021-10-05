/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Stylized checkbox.
 * Tooltip will only appear if "tooltipText" is not empty.
 */
CheckBox {
  id: checkbox
  property string tooltipText: ""

  indicator: Rectangle {
    width: 32
    height: 32
    y: (parent.height / 2) - (height / 2)
    radius: 5
    opacity: enabled ? 1.0 : 0.3
    color: "transparent"
    border.color: checkbox.down ? "#2BE8F4" : "#FFFFFF"
    Image {
      width: parent.width / 2
      height: parent.height / 2
      anchors.centerIn: parent
      visible: checkbox.checked
      antialiasing: true
      smooth: true
      source: "qrc:/img/icons/check.png"
    }
  }

  contentItem: Text {
    text: checkbox.text
    font.pixelSize: 14.0
    opacity: enabled ? 1.0 : 0.3
    color: checkbox.down ? "#2BE8F4" : "#FFFFFF"
    verticalAlignment: Text.AlignVCenter
    leftPadding: checkbox.indicator.width + checkbox.spacing
  }

  ToolTip {
    id: tooltip
    visible: (tooltipText != "" && parent.hovered)
    delay: 500
    background: Rectangle { color: "#1C2029" }
    contentItem: Text {
      font.pixelSize: 12.0
      color: "#FFFFFF"
      text: tooltipText
    }
  }
}

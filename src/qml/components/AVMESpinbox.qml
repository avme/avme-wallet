/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

// Stylized spinbox.
SpinBox {
  id: spinbox
  width: 128
  height: 32

  contentItem: TextInput {
    z: 2
    text: spinbox.textFromValue(spinbox.value, spinbox.locale)
    font.pixelSize: 14.0
    color: (enabled) ? "#2BE8F4" : "#88FFFFFF"
    selectionColor: "#FFFFFF"
    selectedTextColor: "#000000"
    horizontalAlignment: Qt.AlignHCenter
    verticalAlignment: Qt.AlignVCenter
    readOnly: !spinbox.editable
    validator: spinbox.validator
    inputMethodHints: Qt.ImhFormattedNumbersOnly
  }

  up.indicator: Rectangle {
    x: (spinbox.mirrored) ? 0 : (parent.width - width)
    width: parent.height
    height: parent.height
    radius: 5
    color: (spinbox.up.pressed) ? "#882BE8F4" : "transparent"
    Text {
      text: "+"
      font.pixelSize: 24.0
      color: (spinbox.enabled) ? "#2BE8F4" : "#88FFFFFF"
      anchors.centerIn: parent
      fontSizeMode: Text.Fit
    }
  }

  down.indicator: Rectangle {
    x: (spinbox.mirrored) ? (parent.width - width) : 0
    width: parent.height
    height: parent.height
    radius: 5
    color: (spinbox.down.pressed) ? "#882BE8F4" : "transparent"
    Text {
      text: "-"
      font.pixelSize: 24.0
      color: (spinbox.enabled) ? "#2BE8F4" : "#88FFFFFF"
      anchors.centerIn: parent
      fontSizeMode: Text.Fit
    }
  }

  background: Rectangle {
    color: "transparent"
    border.color: (enabled) ? "#FFFFFF" : "#44FFFFFF"
    radius: 5
  }
}

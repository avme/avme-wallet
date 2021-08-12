/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Stylized input field for user data. May need manual sizing and positioning.
 * Requires *at least one of* the following items:
 * "label": the text shown above the input field
 * "placeholder": the placeholder text shown in the input field
 */
TextField {
  id: input
  property string label
  property string placeholder
  property color inputColor: "#1D1B26"
  property color inputLabelColor: "#FFFFFF"
  property color inputDisabledColor: "#44888888"
  property color inputSelectionColor: "#58A0B9"
  property color inputPlaceholderColor: "#88FFFFFF"
  property color inputBorderColor: "#5C5575"

  implicitWidth: 320
  implicitHeight: 40
  selectByMouse: true
  color: "#FFFFFF"
  font.pixelSize: 14.0
  selectionColor: inputSelectionColor
  background: Rectangle {
    width: parent.width
    height: parent.height
    anchors.bottom: parent.bottom
    color: input.enabled ? inputColor : inputDisabledColor
    border.color: inputBorderColor
    border.width: 3
    radius: 1
  }

  // Label above the input field
  Text {
    id: labelText
    color: inputLabelColor
    anchors.bottom: input.top
    anchors.left: input.left
    anchors.bottomMargin: 2
    font.pixelSize: 12.0
    font.capitalization: Font.AllUppercase
    text: label
  }

  // Custom placeholder text
  Text {
    id: labelPlaceholder
    anchors.verticalCenter: parent.verticalCenter
    leftPadding: 10
    color: inputPlaceholderColor
    font.pixelSize: 14.0
    text: placeholder
    visible: !input.text
  }
}

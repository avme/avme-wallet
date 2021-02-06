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

  implicitWidth: 320
  implicitHeight: 40
  selectByMouse: true
  color: "black"
  selectionColor: "#9CE3FD"
  background: Rectangle {
    width: parent.width
    height: parent.height
    anchors.bottom: parent.bottom
    color: input.enabled ? "#449CE3FD" : "#44888888"
  }

  // "Neon" line below the input field
  Rectangle {
    width: parent.width
    height: 2
    anchors.bottom: parent.bottom
    border.width: 2
    border.color: input.enabled ? "#7AC1DB" : "#888888"
    color: "transparent"
  }

  // Label above the input field
  Text {
    id: labelText
    anchors.bottom: input.top
    anchors.left: input.left
    anchors.bottomMargin: 5
    font.pointSize: 10.0
    text: label
  }

  // Custom placeholder text
  Text {
    id: labelPlaceholder
    anchors.verticalCenter: parent.verticalCenter
    leftPadding: 10
    color: "#88000000"
    text: placeholder
    visible: !input.text
  }
}

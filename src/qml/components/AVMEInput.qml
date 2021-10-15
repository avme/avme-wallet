/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.12
import QtQuick.Controls 2.12

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

  MouseArea {
    id: rightClickMouseArea
    property int selectStart
    property int selectEnd
    property int curPos
    anchors.fill: parent
    acceptedButtons: Qt.RightButton
    enabled: (!input.readOnly)
    onClicked: {
      selectStart = input.selectionStart
      selectEnd = input.selectionEnd
      curPos = input.cursorPosition
      rightClickMenu.x = mouse.x
      rightClickMenu.y = mouse.y
      rightClickMenu.open()
      input.cursorPosition = curPos
      input.select(selectStart, selectEnd)
    }
    Menu {
      id: rightClickMenu
      width: 100
      background: Rectangle { color: "#2E2938"; radius: 5 }
      delegate: MenuItem {
        id: rightClickMenuItem
        implicitWidth: 100
        implicitHeight: 40
        background: Rectangle {
          implicitWidth: 100
          implicitHeight: 40
          color: (rightClickMenuItem.highlighted) ? "#3F3A49" : "transparent"
          radius: 5
        }
        contentItem: Text {
          text: rightClickMenuItem.text
          font: rightClickMenuItem.font
          color: (rightClickMenuItem.enabled) ? "#FFFFFF" : "#888888"
          horizontalAlignment: Text.AlignLeft
          verticalAlignment: Text.AlignVCenter
          elide: Text.ElideRight
        }
      }
      Action {
        text: "Cut"
        enabled: (
          input.echoMode == TextInput.Normal &&
          rightClickMouseArea.selectStart != rightClickMouseArea.selectEnd
        )
        onTriggered: input.cut()
      }
      Action {
        text: "Copy"
        enabled: (
          input.echoMode == TextInput.Normal &&
          rightClickMouseArea.selectStart != rightClickMouseArea.selectEnd
        )
        onTriggered: input.copy()
      }
      Action {
        text: "Paste"
        onTriggered: input.paste()
      }
    }
  }
}

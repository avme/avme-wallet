/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

// Stylized button with AVME's color set.

Button {
  id: btn
  property color btnColor: "#782D8B"
  property color btnTextColor: "#FFFFFF"
  property color btnPressedColor: "#671C7A"
  property color btnHoveredColor: "#9A4FAD"
  property color btnDisabledColor: "#88340947"

  text: "Button"
  implicitWidth: 120
  implicitHeight: 40
  focus: false
  focusPolicy: Qt.NoFocus

  background: Rectangle {
    color: {
      if (btn.down) {
        color: btnPressedColor
      } else if (btn.hovered) {
        color: btnHoveredColor
      } else if (!btn.enabled) {
        color: btnDisabledColor
      } else {
        color: btnColor
      }
    }
    opacity: btn.down ? "0.7" : "1.0"
    radius: 5
  }

  contentItem: Text {
    text: btn.text
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    color: btnTextColor
    elide: Text.ElideRight
  }
}

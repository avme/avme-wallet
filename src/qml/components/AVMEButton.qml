import QtQuick 2.9
import QtQuick.Controls 2.2

// Stylized button with AVME's color set.

Button {
  id: btn
  property color btnColor: "#F66986"
  property color btnPressedColor: "#D44764"
  property color btnHoveredColor: "#F88BA8"
  property color btnDisabledColor: "#88F66986"

  text: "Button"
  implicitWidth: 120
  implicitHeight: 40

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
}

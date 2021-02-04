import QtQuick 2.9
import QtQuick.Controls 2.2

// Stylized button with AVME's color set.

Button {
  id: btn
  text: "Button"
  implicitWidth: 120
  implicitHeight: 40
  background: Rectangle {
    color: btn.down ? "#D44764" : "#F66986"
    opacity: btn.down ? "0.7" : "1.0"
    radius: 5
  }
}

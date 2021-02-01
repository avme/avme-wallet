import QtQuick 2.9
import QtQuick.Controls 2.2

Button {
  id: btn
  text: "Button"
  implicitWidth: 100
  implicitHeight: 50
  background: Rectangle {
    color: btn.down ? "#D44764" : "#F66986"
    opacity: btn.down ? "0.7" : "1.0"
    radius: 5
  }
}

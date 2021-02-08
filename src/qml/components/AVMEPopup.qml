import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Popup for just showing a short message. Has to be opened/closed manually.
 * Requires the following items:
 * "info": the text that will be shown
 */

Popup {
  id: popup
  property string info
  property color popupBgColor: "#9A4FAD"

  width: window.width / 4
  height: window.height / 8
  x: (window.width / 2) - (width / 2)
  y: (window.height / 2) - (height / 2)
  modal: true
  focus: true
  padding: 0  // Remove white borders
  closePolicy: Popup.NoAutoClose

  Rectangle {
    anchors.fill: parent
    color: popupBgColor
    Text {
      anchors.centerIn: parent
      horizontalAlignment: Text.AlignHCenter
      text: info
    }
  }
}

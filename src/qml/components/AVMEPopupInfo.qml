import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Popup for info.
 * Requires the following items:
 * "icon": the image that will be shown
 * "info": the text that will be shown
 */

Popup {
  id: infoPopup
  property string icon
  property string info
  property color popupBgColor: "#9A4FAD"

  width: window.width / 2
  height: window.height / 4
  x: (window.width / 2) - (width / 2)
  y: (window.height / 2) - (height / 2)
  background: Rectangle { anchors.fill: parent; color: popupBgColor }
  modal: true
  focus: true
  padding: 0  // Remove white borders
  closePolicy: Popup.NoAutoClose

  Row {
    id: infoContent
    anchors {
      horizontalCenter: parent.horizontalCenter
      top: parent.top
      topMargin: parent.height / 6
    }
    spacing: 10

    Image {
      id: png
      height: 50
      anchors.verticalCenter: parent.verticalCenter
      fillMode: Image.PreserveAspectFit
      source: icon
    }

    Text {
      id: label
      anchors.verticalCenter: png.verticalCenter
      horizontalAlignment: Text.AlignHCenter
      text: info
    }
  }

  AVMEButton {
    id: btn
    anchors {
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      bottomMargin: parent.height / 6
    }
    text: "OK"
    onClicked: infoPopup.close()
  }
}

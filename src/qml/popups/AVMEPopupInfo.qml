/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

/**
 * Popup for info.
 * Requires the following items:
 * "icon": the image that will be shown
 * "info": the text that will be shown
 */
AVMEPopup {
  id: infoPopup
  widthPct: 0.5
  heightPct: 0.25
  property string icon
  property string info
  property alias okBtn: btnOk
  property color popupBgColor: "#1C2029"

  // Enter/Numpad enter key override
  Item {
    focus: true
    Keys.onPressed: {
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        infoPopup.close()
      }
    }
  }

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
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: info
    }
  }

  AVMEButton {
    id: btnOk
    anchors {
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      bottomMargin: parent.height / 6
    }
    text: "OK"
    onClicked: infoPopup.close()
  }
}

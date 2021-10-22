/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

/**
 * Popup for a Yes/No selection.
 * Requires the following items:
 * "icon": the image that will be shown
 * "info": the text that will be shown
 * "yesBtn.onClicked": what to do when the "Yes" button is clicked
 * "noBtn.onClicked": what to do when the "No" button is clicked
 */
AVMEPopup {
  id: customPathPopup
  property string customPath: customPathInput.text
  property color popupBgColor: "#1C2029"
  widthPct: 0.4
  heightPct: 0.3

  onAboutToShow: customPathInput.forceActiveFocus()

  Text {
    id: customPathText
    height: parent.height * 0.2
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    anchors {
      top: parent.top
      topMargin: parent.height / 6
      left: parent.left
      leftMargin: parent.width * 0.15
    }
    color: "#FFFFFF"
    font.pixelSize: 14.0
    text: "Custom Path: "
  }

  AVMEInput {
    id: customPathInput
    width: parent.width * 0.7
    height: parent.height * 0.2
    anchors {
      top: parent.top
      topMargin: parent.height / 6
      right: parent.right
      rightMargin: parent.width * 0.15
    }
    placeholder: "e.g. m/44'/60'/0'/0/"
    // Enter/Numpad enter key override
    Keys.onPressed: {
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        customPathPopup.close()
      }
    }
  }

  Row {
    id: btns
    anchors {
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      bottomMargin: parent.height / 10
    }
    AVMEButton {
      id: closeBtn
      text: "Ok"
      onClicked: customPathPopup.close()
    }
  }
}

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
  id: yesnoPopup
  property string icon
  property string info
  property alias yesBtn: yes
  property alias noBtn: no
  property color popupBgColor: "#1C2029"

  Row {
    id: yesnoContent
    anchors {
      horizontalCenter: parent.horizontalCenter
      top: parent.top
      topMargin: parent.height / 6
    }
    spacing: 10

    AVMEAsyncImage {
      id: png
      width: 50
      height: 50
      loading: false
      anchors.verticalCenter: parent.verticalCenter
      imageSource: icon
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

  Row {
    id: btns
    anchors {
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      bottomMargin: parent.height / 6
    }
    spacing: 10

    AVMEButton { id: no; text: "No" }
    AVMEButton { id: yes; text: "Yes" }
  }
}

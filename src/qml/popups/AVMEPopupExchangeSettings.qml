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
  id: exchangeSettingsPopup
  property string slippage: qmlApi.div(qmlApi.sub(100, slippageInput.text), 100)
  property color popupBgColor: "#1C2029"
  widthPct: 0.25
  heightPct: 0.2


  Text {
    id: "slippageText"
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    height: parent.height * 0.2
    anchors.top: parent.top
    anchors.topMargin: parent.height / 6
    anchors.left: parent.left
    anchors.leftMargin: parent.width * 0.2
    color: "#FFFFFF"
    font.pixelSize: 14.0
    text: "Slippage: "
  }

  AVMEInput {
    width: parent.width * 0.35
    height: parent.height * 0.2
    anchors.top: parent.top
    anchors.topMargin: parent.height / 6
    anchors.right: parent.right
    anchors.rightMargin: parent.width * 0.2
    id: slippageInput
    inputMask: "00.00;"
    text: "1.0"
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
     onClicked: {
        exchangeSettingsPopup.close()
      } 
    }
  }
}

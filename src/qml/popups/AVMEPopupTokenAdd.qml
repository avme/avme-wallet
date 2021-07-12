/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

/**
 * Popup for adding a new ARC20 token.
 */
AVMEPopup {
  id: addTokenPopup

  Column {
    id: items
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 30

    // Enter/Return key override
    Keys.onPressed: {
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        // TODO
      }
    }

    Text {
      id: info
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Enter the address for your desired token."
    }

    AVMEInput {
      id: addressInput
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      label: "Token address"
      // TODO: validator with regex here
      placeholder: "e.g. 0x1234567890ABCDEF..."
    }

    AVMEInput {
      id: symbolInput
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: false
      label: "Token symbol"
    }

    AVMEInput {
      id: nameInput
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: false
      label: "Token name"
    }

    AVMEInput {
      id: decimalsInput
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: false
      // TODO: validator with regex here
      label: "Token decimals"
    }

    AVMEButton {
      id: btnOk
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Add Token"
      onClicked: {} // TODO
    }

    AVMEButton {
      id: btnClose
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Close"
      onClicked: addTokenPopup.close()
    }
  }
}

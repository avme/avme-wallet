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

  function clean() {
    addressInput.text = ""
  }

  Column {
    id: items
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 30

    // Enter/Return key override
    Keys.onPressed: {
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        if (btnOk.enabled) { btnOk.handleToken() }
      }
    }

    Text {
      id: info
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: {
        if (existsTimer.running) {
          text: "Token was already added, please try another."
        } else if (notFoundTimer.running) {
          text: "Token not found, please try another."
        } else {
          text: "Enter the address for your desired token."
        }
      }
      Timer { id: existsTimer; interval: 2000 }
      Timer { id: notFoundTimer; interval: 2000 }
    }

    AVMEInput {
      id: addressInput
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      label: "Token address"
      validator: RegExpValidator { regExp: /0x[0-9a-fA-F]{40}/ }
      placeholder: "e.g. 0x1234567890ABCDEF..."
    }

    AVMEButton {
      id: btnOk
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (addressInput.acceptableInput)
      text: "Add token"
      onClicked: handleToken()
      function handleToken() {
        if (qmlSystem.ARC20TokenWasAdded(addressInput.text)) {
          existsTimer.start()
        } else if (!qmlSystem.ARC20TokenExists(addressInput.text)) {
          notFoundTimer.start()
        } else {
          var tokenData = qmlSystem.getARC20TokenData(addressInput.text)
          qmlSystem.addARC20Token(
            tokenData.address, tokenData.symbol, tokenData.name,
            tokenData.decimals, tokenData.avaxPairContract
          )
          qmlSystem.downloadARC20TokenImage(tokenData.address)
          addTokenPopup.clean()
          addTokenPopup.close()
        }
      }
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

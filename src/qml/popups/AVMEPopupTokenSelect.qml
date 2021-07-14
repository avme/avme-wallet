/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

/**
 * Popup for choosing an ARC20 token to be operated on.
 * The selected token's info is stored in the popup itself, so it's possible to
 * have multiple instances of the popup at the same time in the same screen.
 */
AVMEPopup {
  id: chooseTokenPopup
  widthPct: 0.4
  heightPct: 0.8
  property alias selectedToken: tokenSelectList.currentItem
  property var chosenToken

  // Always default to AVME when popup is ready
  Component.onCompleted: chosenToken = QmlSystem.getAVMEData()

  onAboutToShow: {
    // AVME is hardcoded here and always shows up
    tokenList.clear()
    var avme = QmlSystem.getAVMEData()
    tokenList.append(avme)
    QmlSystem.loadARC20Tokens()
    var tokens = QmlSystem.getARC20Tokens()
    for (var i = 0; i < tokens.length; i++) {
      tokenList.append(tokens[i])
    }
  }

  function chooseToken() {
    chosenToken.address = selectedToken.itemAddress
    chosenToken.symbol = selectedToken.itemSymbol
    chosenToken.name = selectedToken.itemName
    chosenToken.decimals = selectedToken.itemDecimals
    chosenToken.avaxPairContract = selectedToken.itemAVAXPairContract
  }

  Column {
    id: items
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 20

    Text {
      id: infoLabel
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Choose the token you want to use."
    }

    Rectangle {
      id: listRect
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width * 0.9)
      height: (parent.height * 0.7)
      radius: 5
      color: "#16141F"

      AVMETokenList {
        id: tokenSelectList
        height: parent.height
        width: parent.width
        anchors.fill: parent
        model: ListModel { id: tokenList }
      }
    }

    AVMEButton {
      id: btnChoose
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (tokenSelectList.currentIndex > -1)
      text: "Select this token"
      onClicked: {
        chooseToken()
        chooseTokenPopup.close()
      }
    }

    AVMEButton {
      id: btnClose
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Close"
      onClicked: chooseTokenPopup.close()
    }
  }
}

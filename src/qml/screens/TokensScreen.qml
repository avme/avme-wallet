/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Screen for managing the Wallet's registered tokens.
Item {
  id: tokensScreen
  property string avmeAddress
  property alias selectedToken: tokenGrid.currentItem

  Component.onCompleted: reloadTokens()

  function reloadTokens() {
    // AVME is hardcoded here and always shows up
    tokenList.clear()
    var avme = QmlSystem.getAVMEData()
    tokenList.append(avme)
    avmeAddress = avme.address
    QmlSystem.loadARC20Tokens()
    var tokens = QmlSystem.getARC20Tokens()
    for (var i = 0; i < tokens.length; i++) {
      tokenList.append(tokens[i]);
    }
  }

  AVMEAccountHeader {
    id: accountHeader
  }

  AVMEPanel {
    id: tokensPanel
    width: (parent.width * 0.6)
    title: "Token List"
    anchors {
      top: accountHeader.bottom
      bottom: parent.bottom
      left: parent.left
      margins: 10
    }

    // TODO: sort alphabetically by ticker (currently it's sorted by address)
    AVMETokenGrid {
      id: tokenGrid
      width: (parent.width * 0.9)
      anchors {
        top: parent.top
        bottom: btnRow.top
        horizontalCenter: parent.horizontalCenter
        topMargin: 80
        bottomMargin: 20
      }
      model: ListModel { id: tokenList }
    }

    Row {
      id: btnRow
      anchors {
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
        bottomMargin: 20
      }
      spacing: 20

      AVMEButton {
        id: btnAdd
        width: (tokensPanel.width * 0.3)
        text: "Add a new token"
        onClicked: addTokenPopup.open()
      }
      AVMEButton {
        id: btnRemove
        width: (tokensPanel.width * 0.3)
        enabled: (
          selectedToken != null && avmeAddress != "" &&
          selectedToken.itemAddress != avmeAddress
        )
        text: (enabled) ? "Remove this token" : "Can't remove"
        onClicked: confirmEraseTokenPopup.open()
      }
    }
  }

  AVMEPanel {
    id: tokenDetailsPanel
    width: (parent.width * 0.4)
    title: "Token Details"
    anchors {
      top: accountHeader.bottom
      bottom: parent.bottom
      right: parent.right
      margins: 10
    }

    Column {
      anchors.centerIn: parent
      spacing: 20

      // TODO: image
      Text {
        id: tokenSymbol
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 18.0
        font.bold: true
        text: ((selectedToken != null) ? selectedToken.itemSymbol : "")
      }
      Text {
        id: tokenName
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "<b>Name:</b> "
        + ((selectedToken != null) ? selectedToken.itemName : "")
      }
      Text {
        id: tokenDecimals
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "<b>Decimals:</b> "
        + ((selectedToken != null) ? selectedToken.itemDecimals : "")
      }
      Text {
        id: tokenAddress
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "<b>Address:</b><br>"
        + ((selectedToken != null) ? selectedToken.itemAddress : "")
      }
      Text {
        id: tokenAVAXPairContract
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "<b>AVAX Pair Contract:</b><br>"
        + ((selectedToken != null) ? selectedToken.itemAVAXPairContract : "")
      }
    }
  }

  // Popup for adding a new token
  AVMEPopupTokenAdd {
    id: addTokenPopup
    widthPct: 0.4
    heightPct: 0.7
  }

  // Popup for confirming token removal
  AVMEPopupYesNo {
    id: confirmEraseTokenPopup
    widthPct: 0.4
    heightPct: 0.25
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to remove this token?"
    yesBtn.onClicked: {
      // TODO: error handling and info popup(?)
      QmlSystem.removeARC20Token(selectedToken.itemAddress);
      confirmEraseTokenPopup.close()
      reloadTokens()
    }
    noBtn.onClicked: {
      confirmEraseTokenPopup.close()
    }
  }
}

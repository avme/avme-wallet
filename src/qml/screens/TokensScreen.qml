/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Screen for managing the Wallet's registered tokens.
Item {
  id: tokensScreen

  AVMEAccountHeader {
    id: accountHeader
  }

  AVMEPanel {
    id: tokensPanel
    property alias grid: tokenGrid
    width: (parent.width * 0.6)
    title: "Token List"
    anchors {
      top: accountHeader.bottom
      bottom: parent.bottom
      left: parent.left
      margins: 10
    }

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
        onClicked: {} // TODO
      }
      AVMEButton {
        id: btnRemove
        width: (tokensPanel.width * 0.3)
        // TODO: check against AVME address to disable the button
        text: "Remove this token"
        onClicked: {} // TODO
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
        text: "<b>" + tokensPanel.grid.currentItem.itemSymbol + "</b>"
      }
      Text {
        id: tokenName
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "<b>Name:</b> " + tokensPanel.grid.currentItem.itemName
      }
      Text {
        id: tokenDecimals
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "<b>Decimals:</b> " + tokensPanel.grid.currentItem.itemDecimals
      }
      Text {
        id: tokenAddress
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "<b>Address:</b><br>" + tokensPanel.grid.currentItem.itemAddress
      }
      Text {
        id: tokenAVAXPairContract
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "<b>AVAX Pair Contract:</b><br>" + tokensPanel.grid.currentItem.itemAVAXPairContract
      }
    }
  }
}

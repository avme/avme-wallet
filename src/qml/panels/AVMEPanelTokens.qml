/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Panel for showing the Wallet's registered ARC20 tokens.
AVMEPanel {
  id: tokensPanel
  title: "Token List"
  property alias selectedToken: tokenGrid.currentItem
  property alias addListBtn: btnAddList
  property alias addTokenBtn: btnAddToken
  property alias removeTokenBtn: btnRemoveToken

  function reloadTokens() {
    tokenList.clear()
    qmlSystem.loadARC20Tokens()
    var tokens = qmlSystem.getARC20Tokens()
    for (var i = 0; i < tokens.length; i++) {
      tokenList.append(tokens[i]);
    }
    tokenList.sortBySymbol()
  }

  Component.onCompleted: reloadTokens()

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
    model: ListModel {
      id: tokenList
      function sortBySymbol() {
        for (var i = 0; i < count; i++) {
          for (var j = 0; j < i; j++) {
            if (get(i).symbol < get(j).symbol) { move(i, j, 1) }
          }
        }
      }
    }
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
      id: btnAddList
      width: (tokensPanel.width * 0.275)
      text: "Add new token"
    }
    AVMEButton {
      id: btnAddToken
      width: (tokensPanel.width * 0.275)
      text: "Add token from address"
    }
    AVMEButton {
      id: btnRemoveToken
      width: (tokensPanel.width * 0.275)
      enabled: (
        tokenGrid.currentItem != null &&
        tokenGrid.currentItem.itemAddress != qmlSystem.getContract("AVME")
      )
      text: (enabled) ? "Remove token" : "Can't remove"
    }
  }
}

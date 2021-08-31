/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Popup for adding a new ARC20 token from the list in the repo.
AVMEPopup {
  id: addListTokenPopup
  property var tokens: null

  onAboutToShow: {
    tokens = qmlSystem.getARC20TokenList()
    refreshList("")
  }
  onAboutToHide: {
    tokenModel.clear()
    tokens = null
    filterInput.text = ""
  }

  function refreshList(filter) {
    tokenModel.clear()
    for (var i = 0; i < tokens.length; i++) {
      var nameMatch = tokens[i]["name"].toUpperCase().includes(filter.toUpperCase())
      var symbolMatch = tokens[i]["symbol"].toUpperCase().includes(filter.toUpperCase())
      if (filter == "" || nameMatch || symbolMatch) {
        tokens[i]["balance"] = ""
        tokenModel.append(tokens[i])
      }
    }
    tokenModel.sortBySymbol()
    tokenList.currentIndex = -1
  }

  Column {
    id: items
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 20

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
      text: (tokens != null)
      ? "Choose a token from the list." : "Fetching token list, please wait..."
    }

    Rectangle {
      id: listRect
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width * 0.9)
      height: (parent.height * 0.65)
      radius: 5
      color: "#16141F"

      AVMETokenList {
        id: tokenList
        anchors.fill: parent
        model: ListModel {
          id: tokenModel
          function sortBySymbol() {
            for (var i = 0; i < count; i++) {
              for (var j = 0; j < i; j++) {
                if (get(i).symbol < get(j).symbol) { move(i, j, 1) }
              }
            }
          }
        }
      }
    }

    AVMEInput {
      id: filterInput
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      label: "Filter by symbol or name"
      onTextEdited: addListTokenPopup.refreshList(filterInput.text)
    }

    AVMEButton {
      id: btnOk
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (tokenList.currentItem != null)
      text: "Add token"
      onClicked: {
        var tokenData = qmlSystem.getARC20TokenData(tokenList.currentItem.itemAddress)
        qmlSystem.addARC20Token(
          tokenData.address, tokenData.symbol, tokenData.name,
          tokenData.decimals, tokenData.avaxPairContract
        )
        qmlSystem.downloadARC20TokenImage(tokenData.address)
        addListTokenPopup.close()
      }
    }

    AVMEButton {
      id: btnClose
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Close"
      onClicked: addListTokenPopup.close()
    }
  }
}

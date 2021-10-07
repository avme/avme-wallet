/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Combobox for choosing an asset to be operated on.
 * The selected asset's info is stored in the box itself (chosenAsset),
 * so it's possible to have multiple instances of the box at the same time,
 * in the same screen, without one interfering with the others.
 */
AVMECombobox {
  id: assetCombobox
  property var chosenAsset
  property bool defaultToAVME: false

  Component.onCompleted: {
    assetModel.append({
      symbol: "AVAX",
      name: "Avalanche",
      decimals: 18,
      balance: accountHeader.coinRawBalance
    })
    var tokens = accountHeader.tokenList
    for (var token in tokens) {
      var tmpTokenList = ({})
      tmpTokenList["address"] = token
      tmpTokenList["name"] = tokens[token]["name"]
      tmpTokenList["symbol"] = tokens[token]["symbol"]
      tmpTokenList["decimals"] = tokens[token]["decimals"]
      tmpTokenList["balance"] = tokens[token]["rawBalance"]
      assetModel.append(tmpTokenList)
    }
    assetModel.sort()
    currentIndex = (defaultToAVME) ? 1 : 0
  }

  onCurrentIndexChanged: chosenAsset = assetModel.get(currentIndex)

  model: ListModel {
    id: assetModel
    function sort() {
      var avaxIndex, avmeIndex
      for (var i = 0; i < count; i++) {
        for (var j = 0; j < i; j++) {
          if (get(i).symbol < get(j).symbol) move(i, j, 1)
        }
      }
      for (var i = 0; i < count; i++) {
        if (get(i).symbol == "AVAX") move(i, 0, 1)
        if (get(i).symbol == "AVME") move(i, 1, 1)
      }
    }
  }

  contentItem: Row {
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 10
    AVMEAsyncImage {
      width: 32
      height: 32
      anchors.verticalCenter: parent.verticalCenter
      imageSource: {
        if (assetCombobox.chosenAsset.symbol == "AVAX") {
          imageSource: "qrc:/img/avax_logo.png"
        } else if (assetCombobox.chosenAsset.symbol == "AVME") {
          imageSource: "qrc:/img/avme_logo.png"
        } else {
          var img = qmlSystem.getARC20TokenImage(assetCombobox.chosenAsset.address)
          imageSource: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
        }
      }
    }
    Text {
      text: assetCombobox.chosenAsset.symbol
      font.bold: true
      font.pixelSize: 14.0
      color: (assetCombobox.pressed) ? "#2BE8F4" : "#FFFFFF"
      verticalAlignment: Text.AlignVCenter
      anchors.verticalCenter: parent.verticalCenter
      elide: Text.ElideRight
    }
  }

  delegate: ItemDelegate {
    width: assetCombobox.width
    background: Rectangle { color: (highlighted) ? "#4F4F5C" : "#3F3F4B" }
    contentItem: Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10
      AVMEAsyncImage {
        width: 32
        height: 32
        anchors.verticalCenter: parent.verticalCenter
        imageSource: {
          if (symbol == "AVAX") {
            imageSource: "qrc:/img/avax_logo.png"
          } else if (symbol == "AVME") {
            imageSource: "qrc:/img/avme_logo.png"
          } else {
            var img = qmlSystem.getARC20TokenImage(address)
            imageSource: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
          }
        }
      }
      Text {
        text: symbol
        color: (highlighted) ? "#2BE8F4" : "#FFFFFF"
        font.bold: true
        font.pixelSize: 14.0
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
        anchors.verticalCenter: parent.verticalCenter
      }
    }
    highlighted: assetCombobox.highlightedIndex === index
  }
}

/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

/**
 * Popup for choosing an asset (coin/token) to be operated on.
 * The selected asset's info is stored in the popup itself, so it's possible to
 * have multiple instances of the popup at the same time in the same screen.
 */
AVMEPopup {
  id: chooseAssetPopup
  widthPct: 0.3
  heightPct: 0.7
  property bool defaultToAVME: false
  property alias selectedCoin: coinSelectList.currentItem
  property alias selectedToken: tokenSelectList.currentItem
  property string chosenAssetAddress
  property string chosenAssetSymbol
  property string chosenAssetName
  property int chosenAssetDecimals
  property string chosenAssetAVAXPairContract

  Component.onCompleted: {
    coinList.clear()
    coinList.append({
      symbol: "AVAX",
      name: "Avalanche",
      decimals: 18,
      balance: accountHeader.coinRawBalance
    })
    tokenList.clear()
    var tokens = accountHeader.tokenList
    for (var token in tokens) {
      var tmpTokenList = ({})
      tmpTokenList["address"] = token
      tmpTokenList["name"] = tokens[token]["name"]
      tmpTokenList["symbol"] = tokens[token]["symbol"]
      tmpTokenList["decimals"] = tokens[token]["decimals"]
      tmpTokenList["balance"] = tokens[token]["rawBalance"]
      tokenList.append(tmpTokenList)
    }
    tokenList.sortBySymbol()
    if (defaultToAVME) {
      forceAVME()
    } else {
      forceAVAX()
    }
  }

  function forceAVAX() {
    coinSelectList.grabFocus()
    coinSelectList.currentIndex = 0
    chooseAsset()
  }

  function forceAVME() {
    tokenSelectList.grabFocus()
    for (var i = 0; i < tokenList.count; i++) {
      if (tokenList.get(i).address == qmlSystem.getAVMEAddress()) {
        tokenSelectList.currentIndex = i;
        chooseAsset()
      }
    }
  }

  function chooseAsset() {
    if (coinSelectList.currentIndex > -1) {
      if (selectedCoin.itemSymbol == "AVAX") {
        chosenAssetAddress = qmlSystem.getContract("AVAX")
      }
      chosenAssetSymbol = selectedCoin.itemSymbol
      chosenAssetName = selectedCoin.itemName
      chosenAssetDecimals = selectedCoin.itemDecimals
      chosenAssetAVAXPairContract = ""
    } else if (tokenSelectList.currentIndex > -1) {
      chosenAssetAddress = selectedToken.itemAddress
      chosenAssetSymbol = selectedToken.itemSymbol
      chosenAssetName = selectedToken.itemName
      chosenAssetDecimals = selectedToken.itemDecimals
    }
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
      text: "Choose the asset you want to use."
    }

    Rectangle {
      id: listRect
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width * 0.9)
      height: (parent.height * 0.65)
      radius: 5
      color: "#16141F"

      Column {
        anchors.fill: parent
        spacing: 0
        AVMECoinList {
          id: coinSelectList
          width: (parent.width * 0.9)
          height: (parent.height * 0.25)
          anchors.horizontalCenter: parent.horizontalCenter
          onGrabFocus: tokenSelectList.currentIndex = -1
          model: ListModel { id: coinList }
        }
        AVMETokenList {
          id: tokenSelectList
          width: (parent.width * 0.9)
          height: (parent.height * 0.75)
          anchors.horizontalCenter: parent.horizontalCenter
          onGrabFocus: coinSelectList.currentIndex = -1
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
      }
    }

    AVMEButton {
      id: btnChoose
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (coinSelectList.currentIndex > -1 || tokenSelectList.currentIndex > -1)
      text: "Select this asset"
      onClicked: {
        chooseAsset()
        chooseAssetPopup.close()
      }
    }

    AVMEButton {
      id: btnClose
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Close"
      onClicked: chooseAssetPopup.close()
    }
  }
}

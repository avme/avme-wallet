/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Custom list for a wallet's assets and amounts.
 * Requires a ListModel with the following items:
 * - "assetName": the account's name/label (string)
 * - "coinAmount": the asset's amount in <coin-name> (string)
 * - "tokenAmount": the asset's amount in <token-name> (string)
 * - "isToken": let the list know if the asset is a token or a coin
 *              in order to properly display values. (bool)
 * - "fiatAmount": the asset's amount in <fiat> (string)
 * - "imagePath": the asset's logo file path (string)
 */
ListView {
  id: assetList

  Component.onCompleted: reloadAssets()

  function reloadAssets() {
    assetListModel.clear()
    var tokens = accountHeader.tokenList
    if (tokens == ({})) {
      console.log("equals")
    }
    // AVAX is a obligatory asset, but it is not inside tokenList
    var avax = ({})
      if (accountHeader.coinBalance) {
        avax["assetName"] = "AVAX"
        avax["coinAmount"] = accountHeader.coinBalance
        avax["tokenAmount"] = "0"
        avax["isToken"] = false
        avax["fiatAmount"] = "$" + accountHeader.coinValue
        avax["imagePath"] = "qrc:/img/avax_logo.png"
        assetListModel.append(avax)
      }
    for (var token in tokens) {
      var asset = ({})
      asset["assetName"] = tokens[token]["symbol"]
      asset["coinAmount"] = tokens[token]["coinWorth"]
      asset["tokenAmount"] = tokens[token]["balance"]
      asset["isToken"] = true
      asset["fiatAmount"] = "$" + tokens[token]["value"]
      // AVME image is stored in the binary.
      if (tokens[token]["symbol"] == "AVME") {
        asset["imagePath"] = "qrc:/img/avme_logo.png"
      } else {
        asset["imagePath"] = "file:" + QmlSystem.getARC20TokenImage(token)
      }
      assetListModel.append(asset)
    }
  }

  Connections {
    target: QmlSystem
      function onAccountTokenBalancesUpdated() {
        reloadAssets()
      }
  }
  implicitWidth: 550
  implicitHeight: 600
  focus: true
  clip: true
  spacing: 10
  boundsBehavior: Flickable.StopAtBounds
  model: ListModel {
        id: assetListModel
  }
  // Delegate (structure for each item in the list)
  delegate: Component {
    id: listDelegate
    Item {
      id: listItem
      readonly property string itemAssetName: assetName
      readonly property string itemCoinAmount: coinAmount
      readonly property string itemTokenAmount: tokenAmount
      readonly property bool itemIsToken: isToken
      readonly property string itemFiatAmount: fiatAmount
      readonly property string itemImagePath: imagePath
      width: assetList.width
      height: assetList.height * 0.3

      Rectangle {
        id: assetRectangle
        width: parent.width
        height: parent.height
        radius: 5
        color: "#1D1827"
        Column {
          anchors.fill: parent
          anchors.margins: 10
          spacing: 10

          Image {
            id: listAssetImage
            height: 48
            antialiasing: true
            smooth: true
            fillMode: Image.PreserveAspectFit
            source: imagePath
          }
          Text {
            id: listAssetAmount
            color: "white"
            font.pixelSize: 18.0
            font.bold: true
            text: ((isToken) ? itemTokenAmount : itemCoinAmount) + " " + itemAssetName
          }
          Text {
            id: listAssetFiatAmount
            color: "white"
            font.pixelSize: 14.0
            text: itemFiatAmount
          }
          Text {
            id: listAssetCoinAmount
            color: "white"
            font.pixelSize: 14.0
            text: (isToken) ? itemCoinAmount + " AVAX" : ""
          }
        }
        // TODO: Clickable chart
      }
    }
  }
}


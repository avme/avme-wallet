/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtCharts 2.9

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
    var assetList = ([])
    var tokens = accountHeader.tokenList
    // AVAX is a obligatory asset, but it is not inside tokenList
    var avax = ({})
    // Don't fill the list if there is missing information
    if (!accountHeader.coinBalance || !accountHeader.tokensLoading) { return }
    
    avax["assetAddress"] = "null"
    avax["assetName"] = "AVAX"
    avax["coinAmount"] = accountHeader.coinBalance
    avax["tokenAmount"] = "0"
    avax["isToken"] = false
    avax["fiatAmount"] = "$" + accountHeader.coinValue
    avax["imagePath"] = "qrc:/img/avax_logo.png"
    avax["priceChart"] = accountHeader.coinPriceChart
    avax["USDPrice"] = accountHeader.coinPrice
    assetList.push(avax)

    for (var token in tokens) {
      var asset = ({})
      asset["assetAddress"] = token
      asset["assetName"] = tokens[token]["symbol"]
      asset["coinAmount"] = tokens[token]["coinWorth"]
      asset["tokenAmount"] = tokens[token]["balance"]
      asset["isToken"] = true
      asset["fiatAmount"] = "$" + tokens[token]["value"]
      asset["priceChart"] = tokens[token]["chartData"]
      asset["USDPrice"] = tokens[token]["USDprice"]
      // AVME image is stored in the binary.
      if (tokens[token]["symbol"] == "AVME") {
        asset["imagePath"] = "qrc:/img/avme_logo.png"
      } else {
        asset["imagePath"] = "file:" + QmlSystem.getARC20TokenImage(token)
      }
      assetList.push(asset)
    }
    assetListModel.clear()
    assetListModel.append(assetList)
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
      id: listDelegateItem
      readonly property string itemAssetAddress: assetAddress
      readonly property string itemAssetName: assetName
      readonly property string itemCoinAmount: coinAmount
      readonly property string itemTokenAmount: tokenAmount
      readonly property bool itemIsToken: isToken
      readonly property string itemFiatAmount: fiatAmount
      readonly property string itemImagePath: imagePath
      readonly property var itemPriceChart: priceChart
      readonly property string itemUSDPrice: USDPrice
      width: assetList.width
      height: assetList.height * 0.3
      visible: false
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
        ChartView {
          id: assetMarketChart
          anchors.right: parent.right
          anchors.rightMargin: parent.width * 0.05
          anchors.verticalCenter: parent.verticalCenter
          height: parent.height * 0.8
          width: parent.width * 0.4
          visible: true
          antialiasing: true
          backgroundColor: "#881D212A"
          legend.visible: false
          margins { right: 0; bottom: 0; left: 0; top: 0 }
          plotArea { 
            height: assetMarketChart.height * 1
            width: assetMarketChart.width * 0.9
          }
          SplineSeries {
            id: marketLine
            property int countX: 1
            property alias minX: marketAxisX.min
            property alias maxX: marketAxisX.max
            property alias minY: marketAxisY.min
            property alias maxY: marketAxisY.max
            axisX: ValueAxis {
              id: marketAxisX
              labelsColor: "#FFFFFF"
              gridLineColor: "#22FFFFFF"
              tickCount: marketLine.countX
              labelsVisible: false
              lineVisible: false
              visible: true
            }
            axisY: ValueAxis {
              id: marketAxisY
              labelsColor: "#FFFFFF"
              gridLineColor: "#22FFFFFF"
              labelsVisible: false
              lineVisible: false
              visible: true
            }
            Component.onCompleted: refresh()
            function refresh() {
              clear()
              var jsonPriceChart = JSON.parse(itemPriceChart)
              var start = 0
              for (var priceData in jsonPriceChart) {
                minY = -1
                maxY = -1
                if (start == 0) {
                  marketLine.maxX = +jsonPriceChart[start]["date"]
                }
                if (start == (jsonPriceChart.length - 1)) {
                  marketLine.minX = +jsonPriceChart[start]["date"]
                }
                minY = (minY == -1 || +jsonPriceChart[start]["priceUSD"] < minY) ? +jsonPriceChart[start]["priceUSD"] : minY
                maxY = (maxY == -1 || +jsonPriceChart[start]["priceUSD"] > maxY) ? +jsonPriceChart[start]["priceUSD"] : maxY
                marketLine.append(+jsonPriceChart[start]["date"], +jsonPriceChart[start]["priceUSD"])
                ++start
              }
              marketLine.minY = (minY - 1 > 0) ? (minY - minY * 0.2) : 0
              marketLine.maxY = maxY + (maxY * 0.3)
              maxY = (+itemUSDPrice > maxY) ? (+itemUSDPrice + (+itemUSDPrice * 0.3)) : maxY
              listDelegateItem.visible = true
              assetMarketChart.visible = true
            }
          }            
        }
      }
    }
  }
}


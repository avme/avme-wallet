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

  Connections {
    target: accountHeader
    // Whatever happens first.
    function onUpdatedBalances() { reloadAssets(); loadingPng.visible = false }
  }

  // TODO: Using this if condition is a workaround, find a better solution
  Component.onCompleted: if (accountHeader.coinRawBalance) { reloadAssets(); loadingPng.visible = false }

  function reloadAssets() {
    // AVAX is obligatory but not a token so it's not in tokenList
    var assetList = ([])
    var tokens = accountHeader.tokenList
    var avax = ({})

    // Address here is WAVAX, for price history
    avax["assetAddress"] = "0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7"
    avax["assetName"] = "AVAX"
    avax["coinAmount"] = accountHeader.coinRawBalance
    avax["tokenAmount"] = "0"
    avax["isToken"] = false
    avax["fiatAmount"] = "$" + accountHeader.coinFiatValue
    avax["imagePath"] = "qrc:/img/avax_logo.png"
    avax["priceChart"] = accountHeader.coinUSDPriceChart
    avax["USDPrice"] = accountHeader.coinUSDPrice
    assetList.push(avax)

    // Populate the token list
    for (var token in tokens) {
      var asset = ({})
      asset["assetAddress"] = token
      asset["assetName"] = tokens[token]["symbol"]
      asset["coinAmount"] = tokens[token]["coinWorth"]
      asset["tokenAmount"] = tokens[token]["rawBalance"]
      asset["isToken"] = true
      asset["fiatAmount"] = "$" + tokens[token]["fiatValue"]
      asset["priceChart"] = tokens[token]["chartData"]
      asset["USDPrice"] = tokens[token]["USDprice"]
      asset["imagePath"] = (tokens[token]["symbol"] == "AVME")
      ? "qrc:/img/avme_logo.png"
      : "file:" + qmlSystem.getARC20TokenImage(token)

      // Account for unknown tokens image
      if (asset["imagePath"] == "file:") {
        asset["imagePath"] = "qrc:img/unknown_token.png"
      }
      assetList.push(asset)
    }

    // Append if loading the list for the first time, update otherwise.
    if (assetListModel.count == 0) {
      assetListModel.append(assetList)
    } else {
      for (var i = 0; i < assetListModel.count; ++i) {
        var listObject = assetListModel.get(i);
        for (var token in assetList) {
          if (assetList[token]["assetAddress"] == listObject.assetAddress) {
            listObject.coinAmount = assetList[token]["coinAmount"]
            listObject.tokenAmount = assetList[token]["tokenAmount"]
            listObject.fiatAmount = assetList[token]["fiatAmount"]
            listObject.USDPrice = assetList[token]["USDprice"]
          }
        }
      }
    }
  }

  implicitWidth: 550
  implicitHeight: 600
  focus: true
  clip: true
  spacing: 10
  boundsBehavior: Flickable.StopAtBounds
  model: ListModel { id: assetListModel }

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
      height: assetList.height * 0.25
      visible: false

      Rectangle {
        id: assetRectangle
        width: parent.width
        height: parent.height
        radius: 5
        color: "#1D1827"

        Column {
          anchors.fill: parent
          width: parent.width
          height: parent.height
          anchors.margins: 10
          spacing: 5

          AVMEAsyncImage {
            id: listAssetImage
            height: 48
            width: 48
            imageSource: imagePath
            Text {
              id: listAssetName
              anchors {
                left: parent.right
                leftMargin: 10
                verticalCenter: parent.verticalCenter
              }
              font.pixelSize: 24.0
              font.bold: true
              color: "white"
              text: itemAssetName
            }
          }
          Text {
            id: listAssetAmount
            color: "white"
            width: parent.width * 0.5
            font.pixelSize: 18.0
            font.bold: true
            elide: Text.ElideRight
            text: (isToken) ? itemTokenAmount : itemCoinAmount
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

        ChartView {
          id: assetMarketChart
          width: parent.width * 0.4
          height: parent.height * 0.8
          anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
          }
          visible: true
          antialiasing: true
          backgroundColor: "white"
          legend.visible: false
          margins { right: 0; bottom: 0; left: 0; top: 0 }
          plotArea {
            width: assetMarketChart.width * 0.999
            height: assetMarketChart.height * 0.99
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
              minY = -1
              maxY = -1
              for (var priceData in jsonPriceChart) {
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
              marketLine.maxY = maxY + (maxY * 0.2)
              maxY = (+itemUSDPrice > maxY) ? (+itemUSDPrice + (+itemUSDPrice * 0.2)) : maxY
              listDelegateItem.visible = true
              assetMarketChart.visible = true
            }
          }
          MouseArea {
            id: assetChartMouseArea
            width: parent.width
            height: parent.height
            hoverEnabled: true
            z: parent.z - 1
            Rectangle {
              id: assetChartMouseAreaRect
              anchors.fill: parent
              visible: false
              color: "#2E2938"
            }
            onEntered: assetChartMouseAreaRect.visible = true
            onExited: assetChartMouseAreaRect.visible = false
            onClicked: {
              pricechartPopup.contractAddress = itemAssetAddress
              pricechartPopup.nameAsset = itemAssetName
              pricechartPopup.currentAssetPrice = itemUSDPrice
              pricechartPopup.open()
            }
          }
        }
      }
    }
  }
}


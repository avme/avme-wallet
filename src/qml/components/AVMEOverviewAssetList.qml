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
  id: overviewAssetList
  property alias assetModel: assetListModel

  function reloadAssets() {
    // AVAX is obligatory but not a token so it's not in tokenList
    var assetList = ([])
    var tokens = accountHeader.tokenList
    var avax = ({})
    // Clear the list if number of tokens has changed
    if (assetListModel.count != (Object.keys(tokens).length + 1)) { // + 1 = AVAX
      assetListModel.clear()
    }

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
    avax["rectColor"] = chartColors[0]
    assetList.push(avax)

    // Populate the token list
    var colorCt = 1 // 0 = AVAX
    for (var token in tokens) {
      var asset = ({})
      asset["assetAddress"] = token
      asset["assetName"] = tokens[token]["symbol"]
      asset["coinAmount"] = (+tokens[token]["rawBalance"] * +tokens[token]["derivedValue"])
      asset["coinAmount"] = asset["coinAmount"].toFixed(18)
      asset["tokenAmount"] = tokens[token]["rawBalance"]
      asset["isToken"] = true
      asset["fiatAmount"] = "$" + tokens[token]["fiatValue"]
      asset["priceChart"] = tokens[token]["chartData"]
      asset["USDPrice"] = tokens[token]["USDprice"]
      asset["imagePath"] = (tokens[token]["symbol"] == "AVME")
      ? "qrc:/img/avme_logo.png"
      : "file:" + qmlSystem.getARC20TokenImage(token)
      if (asset["imagePath"] == "file:") {  // Token image not found
        asset["imagePath"] = "qrc:img/unknown_token.png"
      }
      asset["rectColor"] = chartColors[colorCt]
      asset["isSelected"] = false
      colorCt++
      if (colorCt >= chartColors.length) { colorCt = 0 }
      assetList.push(asset)
    }

    // Append if list is empty, update otherwise
    if (assetListModel.count == 0) {
      assetListModel.append(assetList)
      for (var i = 0; i < assetListModel.count; i++) {
        toggleAsset(assetListModel.get(i).assetAddress, false)
      }
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

  function toggleAsset(address, state) {
    for (var i = 0; i < assetListModel.count; i++) {
      if (address == "AVAX") {
        assetListModel.get(0).isSelected = state
      } else if (assetListModel.get(i).assetAddress == address) {
        assetListModel.get(i).isSelected = state
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

  ScrollBar.vertical: ScrollBar {
    id: scrollbar
    active: true
    visible: (assetListModel.count > 0)
    orientation: Qt.Vertical
    size: overviewAssetList.height / overviewAssetList.contentHeight
    policy: ScrollBar.AlwaysOn
    anchors {
      top: parent.top
      right: parent.right
      bottom: parent.bottom
    }
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
      readonly property string itemRectColor: rectColor
      readonly property bool itemIsSelected: isSelected
      width: overviewAssetList.width
      height: overviewAssetList.height * 0.15
      visible: false

      Rectangle {
        id: assetRectangle
        width: (parent.width - (scrollbar.width * 2))
        height: parent.height
        color: "#1D1827"
        border.width: 3
        border.color: (itemIsSelected) ? "white" : "transparent"
        radius: 5

        Rectangle {
          id: assetColorCode
          width: 5
          height: parent.height
          anchors.left: parent.left
          color: itemRectColor
          radius: 5
          Rectangle {
            width: 2
            height: parent.height
            anchors.right: parent.right
            color: itemRectColor
            radius: 0
          }
        }

        AVMEAsyncImage {
          id: listAssetImage
          width: 48
          height: 48
          anchors {
            left: parent.left
            leftMargin: 15
            verticalCenter: parent.verticalCenter
          }
          loading: false
          imageSource: imagePath
        }

        Column {
          id: listAssetAmountCol
          width: (parent.width * 0.5)
          anchors {
            left: listAssetImage.right
            leftMargin: 10
            verticalCenter: parent.verticalCenter
          }
          spacing: 2

          Text {
            id: listAssetAmount
            font.pixelSize: 16.0
            font.bold: true
            color: "white"
            elide: Text.ElideRight
            text: (
              ((isToken) ? itemTokenAmount : itemCoinAmount)
              + " " + itemAssetName
            )
          }
          Text {
            id: listAssetCoinAmount
            color: "white"
            font.pixelSize: 14.0
            text: (isToken) ? itemCoinAmount + " AVAX" : ""
          }
          Text {
            id: listAssetFiatAmount
            color: "white"
            font.pixelSize: 14.0
            text: itemFiatAmount
          }
        }

        MouseArea {
          id: assetRectMouseArea
          anchors.fill: parent
          hoverEnabled: true
          onEntered: {
            if (itemAssetName == "AVAX") {
              overviewPanel.selectedAsset = "AVAX"
              toggleAsset("AVAX", true)
              accountChart.toggleSlice("AVAX", true)
            } else {
              overviewPanel.selectedAsset = itemAssetAddress
              toggleAsset(itemAssetAddress, true)
              accountChart.toggleSlice(itemAssetAddress, true)
            }
          }
          onExited: {
            overviewPanel.selectedAsset = null
            if (itemAssetName == "AVAX") {
              toggleAsset("AVAX", false)
              accountChart.toggleSlice("AVAX", false)
            } else {
              toggleAsset(itemAssetAddress, false)
              accountChart.toggleSlice(itemAssetAddress, false)
            }
          }
        }

        Rectangle {
          id: assetMarketChartRect
          width: (parent.width * 0.25)
          height: (parent.height * 0.9)
          anchors {
            right: parent.right
            rightMargin: 5
            verticalCenter: parent.verticalCenter
          }
          color: "#0C0716"
          radius: 5

          ChartView {
            id: assetMarketChart
            width: parent.width
            height: parent.height
            visible: true
            antialiasing: true
            legend.visible: false
            margins { right: 0; bottom: 0; left: 0; top: 0 }
            plotArea {
              width: assetMarketChart.width * 0.999
              height: assetMarketChart.height * 0.999
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
                labelsVisible: false
                lineVisible: false
                gridVisible: false
                visible: true
              }
              axisY: ValueAxis {
                id: marketAxisY
                labelsVisible: false
                lineVisible: false
                gridVisible: false
                visible: true
              }
              Component.onCompleted: refresh()
              function refresh() {
                clear()
                var jsonPriceChart = JSON.parse(itemPriceChart)
                var start = 0, newer = 0, older = 0
                minY = -1
                maxY = -1
                for (var priceData in jsonPriceChart) {
                  if (start == 0) {
                    marketLine.maxX = +jsonPriceChart[start]["date"]
                    newer = +jsonPriceChart[start]["priceUSD"]
                  }
                  if (start == (jsonPriceChart.length - 1)) {
                    marketLine.minX = +jsonPriceChart[start]["date"]
                    older = +jsonPriceChart[start]["priceUSD"]
                  }
                  minY = (minY == -1 || +jsonPriceChart[start]["priceUSD"] < minY) ? +jsonPriceChart[start]["priceUSD"] : minY
                  maxY = (maxY == -1 || +jsonPriceChart[start]["priceUSD"] > maxY) ? +jsonPriceChart[start]["priceUSD"] : maxY
                  marketLine.append(+jsonPriceChart[start]["date"], +jsonPriceChart[start]["priceUSD"])
                  ++start
                }
                marketLine.minY = (minY - 1 > 0) ? (minY - minY * 0.2) : 0
                marketLine.maxY = maxY + (maxY * 0.2)
                if (newer > older) {
                  marketLine.color = "green"
                } else if (newer < older) {
                  marketLine.color = "red"
                } else {
                  marketLine.color = "deepskyblue"
                }
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
                radius: 5
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
}


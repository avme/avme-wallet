/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtCharts 2.2

import "qrc:/qml/components"

AVMEPopup {
  id: pricechartPopup
  widthPct: 0.8
  heightPct: 0.75
  property string contractAddress
  property string nameAsset
  property string currentAssetPrice

  Connections {
    target: chartPeriod
    function onActivated(index) { updateChart(index) }
  }

  Connections {
    // Change index to select 1 Month and reload the chart
    target: pricechartPopup
    function onOpened() { chartPeriod.currentIndex = 1; updateChart(1) }
  }

  function updateChart(index) {
    //console.log(index)
    var days = 0
    if (index == 0) { days = 8 }
    else if (index == 1) { days = 31 }
    else if (index == 2) { days = 91 }
    var marketHistory = JSON.parse(QmlApi.getTokenPriceHistory(contractAddress, days))
    marketGraph.clear()
    var minY = -1
    var maxY = -1
    for (var i = 0; i < marketHistory.length; ++i) {
      var obj = marketHistory[i]
      var timestamp = new Date(marketHistory[i]["date"] * 1000)
      var candlestick = Qt.createQmlObject(
        "import QtCharts 2.2; CandlestickSet { timestamp: " + timestamp.getTime() + " }", marketGraph
      )
      var prevObj = null
      var prevTimestamp = null
      if (i != marketHistory.length - 1) {
        prevObj = marketHistory[i+1]
        prevTimestamp = new Date(prevObj["date"] * 1000)
      }
      if (prevTimestamp != null) {
        var timediff = timestamp.getTime() - prevTimestamp.getTime()
        if (timediff > 86400000) {  // diff > 1 day means there are gaps
          while (timediff > 0) {
            var prevCandlestick = Qt.createQmlObject(
              "import QtCharts 2.2; CandlestickSet { timestamp: " + (timediff - 86400000) + " }", marketGraph
            )
            prevCandlestick.open = +obj.priceUSD
            prevCandlestick.high = +obj.priceUSD
            prevCandlestick.low = +obj.priceUSD
            prevCandlestick.close = +obj.priceUSD
            marketGraph.append(prevCandlestick)
            timediff -= 86400000
          }
        }
      }
      // Set candlestick values
      if (i == marketHistory.length - 1) {
        // Oldest candlestick
        candlestick.open = +obj.priceUSD * 0.9
        candlestick.high = Math.max(+obj.priceUSD, +obj.priceUSD)
        candlestick.low = Math.min(+obj.priceUSD, +obj.priceUSD)
        candlestick.close = +obj.priceUSD
      } else {
        // The rest up until the newest
        candlestick.open = +prevObj.priceUSD
        candlestick.high = Math.max(+prevObj.priceUSD, +obj.priceUSD)
        candlestick.low = Math.min(+prevObj.priceUSD, +obj.priceUSD)
        candlestick.close = +obj.priceUSD
      }
      // Set axis limits before inserting
      if (i == 0) {
        marketGraph.maxX = timestamp
        marketGraph.minX = new Date(timestamp.getTime() - (86400000 * days))
      }
      minY = (minY == -1 || +obj.priceUSD < minY) ? +obj.priceUSD : minY
      maxY = (maxY == -1 || +obj.priceUSD > maxY) ? +obj.priceUSD : maxY
      if (candlestick.open == 0) {
        marketGraph.minY = 0
      } else {
        marketGraph.minY = (minY - (minY * 0.1) > 0) ? minY - (minY * 0.1) : 0
      }
      marketGraph.maxY = maxY + (maxY * 0.1)
      // Insert the candlestick into the graph
      marketGraph.append(candlestick)
    }
  }

  ChartView {
    id: popupMarketChart
    width: parent.width * 0.9
    height: parent.height * 0.9
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      margins: 10
    }
    backgroundColor: "#881D212A"
    title: "<b>Historical " + nameAsset + " Prices</b>"
    titleColor: "#FFFFFF"
    titleFont.pixelSize: 14.0
    legend {
      color: "#FFFFFF"
      labelColor: "#FFFFFF"
      alignment: Qt.AlignBottom
      font.pixelSize: 14.0
    }
    margins { right: 0; bottom: 0; left: 0; top: 0 }
    MouseArea {
      id: chartArea
      x: parent.plotArea.x
      y: parent.plotArea.y
      width: parent.plotArea.width
      height: parent.plotArea.height
      hoverEnabled: true
      onEntered: {
        mouseRectX.visible = mouseRectY.visible = true
        mouseLineX.visible = mouseLineY.visible = true
      }
      onExited: {
        mouseRectX.visible = mouseRectY.visible = false
        mouseLineX.visible = mouseLineY.visible = false
      }
      onPositionChanged: {
        var valueXPerPixel = (marketGraph.maxX.getTime() - marketGraph.minX.getTime()) / width
        var valueYPerPixel = (marketGraph.maxY - marketGraph.minY) / height
        var valueX = new Date(marketGraph.minX.getTime() + (mouse.x * valueXPerPixel))
        var valueY = marketGraph.maxY - (mouse.y * valueYPerPixel)
        mouseRectX.info = Qt.formatDate(valueX, "dd/MM")
        mouseRectY.info = valueY.toFixed(3)
        mouseLineX.x = parent.plotArea.x + mouse.x
        mouseLineY.y = parent.plotArea.y + mouse.y
        mouseRectX.x = mouseLineX.x - (mouseRectX.width / 2)
        mouseRectY.y = mouseLineY.y - (mouseRectY.height / 2)
      }
    }

    Rectangle {
      id: mouseRectX
      property string info
      visible: false
      width: 60
      height: 30
      anchors.top: chartArea.bottom
      radius: 5
      color: "#3E4653"
      Text {
        color: "#FFFFFF"
        font.pixelSize: 12.0
        anchors.centerIn: parent
        text: parent.info
      }
    }

    Rectangle {
      id: mouseRectY
      property string info
      visible: false
      width: 60
      height: 30
      anchors.right: chartArea.left
      radius: 5
      color: "#3E4653"
      Text {
        color: "#FFFFFF"
        font.pixelSize: 12.0
        anchors.centerIn: parent
        text: parent.info
      }
    }

    Rectangle {
      id: mouseLineX
      visible: false
      width: 1
      color: "#FFFFFF"
      anchors {
        top: chartArea.top
        bottom: chartArea.bottom
      }
    }

    Rectangle {
      id: mouseLineY
      visible: false
      height: 1
      color: "#FFFFFF"
      anchors {
        left: chartArea.left
        right: chartArea.right
      }
    }

    CandlestickSeries {
      id: marketGraph
      property int countX: 0
      property alias minX: marketAxisX.min
      property alias maxX: marketAxisX.max
      property alias minY: marketAxisY.min
      property alias maxY: marketAxisY.max
      name: "<b>" + nameAsset + " Price (USD)</b>"
      increasingColor: "green"
      decreasingColor: "red"
      bodyOutlineVisible: false
      minimumColumnWidth: 10
      axisX: DateTimeAxis {
        id: marketAxisX
        labelsColor: "#FFFFFF"
        labelsFont.pixelSize: 12.0
        gridLineColor: "#22FFFFFF"
        tickCount: marketGraph.countX
        format: "dd/MM"
      }
      axisY: ValueAxis {
        id: marketAxisY
        labelsColor: "#FFFFFF"
        labelsFont.pixelSize: 12.0
        gridLineColor: "#22FFFFFF"
      }
    }
  }

  ComboBox {
    id: chartPeriod
    anchors {
      bottom: parent.bottom
      left: parent.left
      margins: 20
    }
    model: ["1 Week", "1 Month", "3 Months"]
  }

  AVMEButton {
    id: closeBtn
    anchors {
      bottom: parent.bottom
      right: parent.right
      margins: 20
    }
    text: "Close"
    onClicked: pricechartPopup.close()
  }
}

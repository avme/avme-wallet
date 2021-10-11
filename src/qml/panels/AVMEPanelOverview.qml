/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtCharts 2.2

import "qrc:/qml/components"

// Panel for the Account's balance overview chart.
AVMEPanel {
  id: overviewPanel
  title: "Your Account"
  property var chartColors: [
    // https://sashamaps.net/docs/resources/20-colors
    "#E6194B", // Red
    "#3CB44B", // Green
    "#FFE119", // Yellow
    "#4363D8", // Blue
    "#F58231", // Orange
    "#42D4F4", // Cyan
    "#F032E6", // Magenta
    "#FABED4", // Pink
    "#469990", // Teal
    "#DCBEEF", // Lavender
    "#9A6324", // Brown
    "#FFFAC8", // Beige
    "#800000", // Maroon
    "#AAFFC3", // Mint
    "#0000FF", // Dark Blue because Navy is too dark
    "#A9A9A9", // Grey
  ]

  Connections {
    target: accountHeader
    function onUpdatedBalances() { accountPie.refresh(); loadingPng.visible = false }
  }

  // Only load chart if everything is loaded
  Component.onCompleted: if (accountHeader.coinRawBalance) { accountPie.refresh(); loadingPng.visible = false }

  Rectangle {
    id: accountChartRect
    height: (parent.height * 0.6) - anchors.topMargin
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      topMargin: 60
    }
    color: "transparent"

    ChartView {
      id: accountChart
      anchors.fill: parent
      backgroundColor: "transparent"
      antialiasing: true
      legend.visible: false
      margins { left: 0; right: 0; top: 0; bottom: 0 }

      PieSeries {
        id: accountPie
        size: 0.8
        holeSize: 0.65
        function refresh() {
          clear()
          append("AVAX", accountHeader.coinFiatValue)
          for (var token in accountHeader.tokenList) {
            var sym = accountHeader.tokenList[token].symbol
            var bal = +accountHeader.tokenList[token].fiatValue
            bal = bal.toFixed(2)
            append(sym, bal)
          }
          var colorCt = 0
          for (var i = 0; i < count; i++) {
            at(i).color = chartColors[colorCt]
            colorCt++
            if (colorCt >= chartColors.length) { colorCt = 0 }
            at(i).borderColor = overviewPanel.color.toString()
          }
          accountChartLegendModel.refresh()
        }
      }
      Text {
        id: accountPiePercentageText
        anchors {
          top: parent.top
          topMargin: parent.height * 0.5
          horizontalCenter: parent.horizontalCenter
        }
        font.pixelSize: 18.0
        font.bold: true
        color: "transparent"
      }
      Text {
        id: accountPieValueText
        anchors {
          bottom: parent.bottom
          bottomMargin: parent.height * 0.5
          horizontalCenter: parent.horizontalCenter
        }
        font.pixelSize: 18.0
        font.bold: true
        color: "transparent"
      }
    }
  }

  GridView {
    id: accountChartLegend
    width: parent.width * 0.9
    anchors {
      top: accountChartRect.bottom
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      margins: 20
    }
    clip: true
    cellWidth: width * 0.2
    cellHeight: 40
    delegate: Component {
      id: accountChartLegendDelegate
      Item {
        property int itemId: id
        property string itemLabel: label
        property string itemColor: pieSliceColor
        Rectangle {
          id: accountChartLegendRect
          width: accountChartLegend.cellHeight / 2
          height: accountChartLegend.cellHeight / 2
          anchors.verticalCenter: accountChartLegendMouseArea.verticalCenter
          radius: 5
          color: itemColor
          Text {
            id: accountChartLegendText
            anchors.left: parent.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            color: "#FFFFFF"
            font.pixelSize: 14.0
            font.bold: true
            text: itemLabel
          }
        }
        MouseArea {
          id: accountChartLegendMouseArea
          width: accountChartLegend.cellWidth * 0.9
          height: accountChartLegend.cellHeight * 0.9
          z: parent.z - 1
          hoverEnabled: true
          onEntered: {
            accountPie.at(itemId).exploded = true
            aCLMAR.color = "#22FFFFFF"
            accountPiePercentageText.text = (+accountPie.at(itemId).percentage * 100).toFixed(2) + "%"
            accountPiePercentageText.color = accountPie.at(itemId).color.toString()
            accountPieValueText.text = "$" + accountPie.at(itemId).value
            accountPieValueText.color = accountPie.at(itemId).color.toString()
          }
          onExited: {
            accountPie.at(itemId).exploded = false
            aCLMAR.color = "transparent"
            accountPiePercentageText.text = ""
            accountPieValueText.text = ""
            accountPieValueText.color = "transparent"
          }
          Rectangle { id: aCLMAR; color: "transparent"; anchors.fill: parent; radius: 5 }
        }
      }
    }
    model: ListModel {
      id: accountChartLegendModel
      function refresh() {
        clear()
        for (var i = 0; i < accountPie.count; i++) {
          append({
            id: i, label: accountPie.at(i).label,
            pieSliceColor: accountPie.at(i).color.toString()
          })
        }
      }
    }
  }
  AVMEAsyncImage {
    id: loadingPng
    width: height
    height: (parent.width / 3)
    anchors.centerIn: parent
    imageSource: "qrc:/img/icons/loading.png"
    RotationAnimator {
      target: loadingPng
      from: 0
      to: 360
      duration: 1000
      loops: Animation.Infinite
      easing.type: Easing.InOutQuad
      running: true
    }
  }
}

/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtCharts 2.2

import "qrc:/qml/components"

// Panel for the Account's balance overview chart and detailed asset list.
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

  Row {
    id: accountPanelRow
    anchors {
      top: parent.top
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      topMargin: 80
      bottomMargin: 20
    }
    spacing: 10

    ChartView {
      id: accountChart
      width: (overviewPanel.width * 0.4) - (parent.spacing * 2)
      anchors {
        top: parent.top
        bottom: parent.bottom
      }
      backgroundColor: "transparent"
      antialiasing: true
      legend.visible: false
      margins { left: 0; right: 0; top: 0; bottom: 0 }

      PieSeries {
        id: accountPie
        size: 1.0
        holeSize: 0.9
        onHovered: {
          slice.borderWidth = state
          slice.borderColor = (state) ? "white" : "transparent"
          if (state) {
            accountPieValueText.text = "$" + slice.value + " in " + slice.label
            accountPiePercentageText.text = (+slice.percentage * 100).toFixed(2) + "%"
          } else {
            accountPieValueText.text = "$" + accountHeader.totalFiatBalance
            accountPiePercentageText.text = (
              Object.keys(accountHeader.tokenList).length + 1 // "+ 1" = AVAX
            ) + " Assets"
          }
        }
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
          accountPieValueText.text = "$" + accountHeader.totalFiatBalance
          accountPiePercentageText.text = (
            Object.keys(accountHeader.tokenList).length + 1 // "+ 1" = AVAX
          ) + " Assets"
        }
      }
      Column {
        id: accountPieDataCol
        anchors.centerIn: parent
        spacing: 5

        Text {
          id: accountPieValueText
          anchors.horizontalCenter: parent.horizontalCenter
          font.pixelSize: 24.0
          font.bold: true
          color: "#FFFFFF"
        }
        Text {
          id: accountPiePercentageText
          anchors.horizontalCenter: parent.horizontalCenter
          font.pixelSize: 18.0
          color: "#FFFFFF"
        }
      }
    }

    AVMEOverviewAssetList {
      id: assetList
      width: (overviewPanel.width * 0.6) - (parent.spacing * 2)
      anchors {
        top: parent.top
        bottom: parent.bottom
      }
    }
  }

  AVMEAsyncImage {
    id: loadingPng
    width: parent.width * 0.5
    height: parent.height * 0.5
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

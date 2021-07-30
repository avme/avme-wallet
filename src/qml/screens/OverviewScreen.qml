/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtCharts 2.2

import "qrc:/qml/components"
import "qrc:/qml/panels"

// Screen for showing an overview for the Wallet, Account, etc.
Item {
  antialiasing: true
  id: overviewScreen

  Connections {
    target: accountHeader
    function onUpdatedBalances() { accountPie.refresh() }
  }

  AVMEOverviewBalance {
    id: overviewBalance
    width: (parent.width * 0.5) - (anchors.margins / 2)
    height: parent.height * 0.2
    anchors {
      top: parent.top
      left: parent.left
      margins: 10
    }
  }

  AVMEPanel {
    id: overviewPanel
    width: (parent.width * 0.5) - (anchors.margins / 2)
    height: parent.height * 0.8
    anchors {
      top: overviewBalance.bottom
      bottom: parent.bottom
      left: parent.left
      margins: 10
    }
    title: "Your Account"
    rightRadius: false
    Component.onCompleted: accountPie.refresh()

    Rectangle {
      id: accountChartRect
      anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        topMargin: 60
      }
      height: (parent.height * 0.5) - anchors.topMargin
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
            append("AVAX", accountHeader.coinBalance)
            for (var token in accountHeader.tokenList) {
              var sym = accountHeader.tokenList[token].symbol
              var bal = accountHeader.tokenList[token].balance
              append(sym, bal)
            }
            var baseColor = "#AD00FA"
            for (var i = 0; i < count; i++) {
              at(i).color = baseColor
              at(i).borderColor = overviewPanel.color.toString()
              baseColor = Qt.darker(baseColor, 1.2)
            }
            accountChartLegendModel.refresh()
          }
        }
        Text {
          id: accountPieText
          anchors.centerIn: parent
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
      cellWidth: width / 4
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
              accountPieText.text = (+accountPie.at(itemId).percentage * 100).toFixed(2) + "%"
              accountPieText.color = accountPie.at(itemId).color.toString()
            }
            onExited: {
              accountPie.at(itemId).exploded = false
              aCLMAR.color = "transparent"
              accountPieText.text = ""
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
  }

  AVMEPanel {
    id: assetsPanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
    anchors {
      top: parent.top
      bottom: parent.bottom
      right: parent.right
      margins: 10
    }
    title: "Your Assets"
    leftRadius: false

    Column {
      id: assetsColumn
      anchors {
        top: parent.top
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        topMargin: 80
        bottomMargin: 20
        leftMargin: 20
        rightMargin: 20
      }
      spacing: 10

      AVMEOverviewAssetList {
        id: assetList
        width: parent.width
        height: parent.height
      }
    }
  }
}

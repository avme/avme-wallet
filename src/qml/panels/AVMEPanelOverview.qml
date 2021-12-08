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
  property var selectedAsset
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

  // Only load chart if everything is loaded
  Connections {
    target: accountHeader
    function onUpdatedBalances() { reloadData() }
  }
  Component.onCompleted: if (accountHeader.coinRawBalance) { reloadData() }

  function reloadData() {
    overviewAssetList.reloadAssets()
    accountChart.refresh()
    loadingPng.visible = false
  }

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

    AVMEOverviewPieChart {
      id: accountChart
      width: (overviewPanel.width * 0.4) - (parent.spacing * 2)
      anchors {
        top: parent.top
        bottom: parent.bottom
      }
    }

    AVMEOverviewAssetList {
      id: overviewAssetList
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

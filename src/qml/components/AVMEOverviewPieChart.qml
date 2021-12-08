/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtCharts 2.2

import "qrc:/qml/components"

// Pie chart for the Account's balance overview.
ChartView {
  id: accountChart
  backgroundColor: "transparent"
  antialiasing: true
  legend.visible: false
  margins { left: 0; right: 0; top: 0; bottom: 0 }

  function refresh() {
    // Clear the chart if number of tokens has changed
    if (accountPie.count != (accountHeader.tokenList.length + 1)) { // + 1 = AVAX
      accountPie.clear()
    }
    // Append if chart is empty, update otherwise
    if (accountPie.count == 0) {
      accountPie.append("AVAX", accountHeader.coinFiatValue)
      for (var token in accountHeader.tokenList) {
        var add = token
        var bal = +accountHeader.tokenList[token].fiatValue
        bal = bal.toFixed(2)
        accountPie.append(add, bal)
      }
    } else {
      accountPie.at(0).value = accountHeader.coinFiatValue
      for (var token in accountHeader.tokenList) {
        var add = token
        var bal = +accountHeader.tokenList[token].fiatValue
        bal = bal.toFixed(2)
        if (accountPie.find(add) != null) {
          accountPie.find(add).value = bal
        } else {
          accountPie.remove(accountPie.find(add))
        }
      }
    }
    // Color each slice and list asset accordingly,
    // then gather the rest of the data
    var colorCt = 0 // 0 = AVAX
    for (var i = 0; i < accountPie.count; i++) {
      accountPie.at(i).color = chartColors[colorCt]
      accountPie.at(i).borderWidth = 3
      accountPie.at(i).borderColor = "transparent"
      colorCt++
      if (colorCt >= chartColors.length) { colorCt = 0 }
    }
    accountPieValueText.text = "$" + accountHeader.totalFiatBalance
    accountPiePercentageText.text = (
      Object.keys(accountHeader.tokenList).length + 1 // "+ 1" = AVAX
    ) + " Assets"
    if (overviewPanel.selectedAsset != null) {
      toggleSlice(overviewPanel.selectedAsset, true)
      overviewAssetList.toggleAsset(overviewPanel.selectedAsset, true)
    }
  }

  function toggleSlice(label, state) {
    if (accountPie.find(label) == null) { return }
    accountPie.find(label).borderColor = (state) ? "white" : "transparent"
    if (state) {
      accountPieValueText.text = "$" + accountPie.find(label).value + " in "
        + ((label == "AVAX") ? "AVAX" : accountHeader.tokenList[label].symbol)
      accountPiePercentageText.text = (
        +accountPie.find(label).percentage * 100
      ).toFixed(2) + "%"
    } else {
      accountPieValueText.text = "$" + accountHeader.totalFiatBalance
      accountPiePercentageText.text = (
        Object.keys(accountHeader.tokenList).length + 1 // "+ 1" = AVAX
      ) + " Assets"
    }
  }

  PieSeries {
    id: accountPie
    size: 0.8
    holeSize: 0.7
    onHovered: {
      overviewPanel.selectedAsset = (state) ? slice.label : null
      toggleSlice(slice.label, state)
      overviewAssetList.toggleAsset(slice.label, state)
    }
  }

  Column {
    id: accountPieDataCol
    anchors.centerIn: parent
    spacing: 5

    Text {
      id: accountPieValueText
      anchors.horizontalCenter: parent.horizontalCenter
      font.pixelSize: 16.0
      font.bold: true
      color: "#FFFFFF"
    }
    Text {
      id: accountPiePercentageText
      anchors.horizontalCenter: parent.horizontalCenter
      font.pixelSize: 14.0
      color: "#FFFFFF"
    }
  }
}

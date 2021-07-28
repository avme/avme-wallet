/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9

import "qrc:/qml/components"

Rectangle {
  color: "#1D1827"
  radius: 5

  Column {
    id: balanceColumn
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.topMargin: parent.height * 0.025
    anchors.leftMargin: parent.width * 0.025
    width: parent.width * 0.45
    height: parent.height * 0.95
    spacing: parent.height * 0.02

    AVMEOverviewBalance {
      id: overviewBalance
      width: parent.width
    }

    Rectangle {
      id: balanceChartRectangle
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width
      height: (parent.height - overviewBalance.height) - parent.height * 0.02
      color: "#0F0C18"
      radius: 5
      Column {
        id: balanceChartColumn
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.025
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: parent.height * 0.05
        height: parent.height * 0.95
        width: parent.width * 0.8
        Text {
          id: accountTitle
          anchors.horizontalCenter: parent.horizontalCenter
          text: "YOUR ACCOUNT"
          color: "white"
          font.pixelSize: 16.0
          font.bold: true
          Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            anchors.topMargin: parent.height * 0.35
            id: titleDivisorRectangle
            color: "white"
            width: parent.width * 1.2
            height: 1
          }
        }
        // TODO: CHART
      }
    }
  }

  Rectangle {
    id: divisorRectangle
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width * 0.01
    height: parent.height
    color: "#0F0C18"
  }

  Column {
    // DELETE THIS
    ListModel {
      id: assetModel
      ListElement {
        assetName: "AVAX"
        coinAmount: "0.000000000000000000"
        tokenAmount: "0.000000000000000000"
        isToken: false
        fiatAmount: "0.00$"
        imagePath: "qrc:/img/avax_logo.png"
      }
      ListElement {
        assetName: "AVME"
        coinAmount: "0.000000000000000000"
        tokenAmount: "0.000000000000000000"
        isToken: true
        fiatAmount: "0.00$"
        imagePath: "qrc:img/avme_logo.png"
      }
    }
    // END OF DELETE THIS
    id: assetsColumn
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.topMargin: parent.height * 0.025
    anchors.rightMargin: parent.width * 0.025
    width: parent.width * 0.45
    height: parent.height * 0.95
    spacing: parent.height * 0.02
    AVMEOverviewAssetList {
      model: assetModel
      width: parent.width
      height: parent.height
    }
  }
}

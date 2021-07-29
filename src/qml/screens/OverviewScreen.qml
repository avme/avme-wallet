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

    Column {
      id: overviewColumn
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

      Rectangle {
        id: balanceChartRectangle
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: (parent.height - overviewBalance.height) - parent.height * 0.02
        color: "#0F0C18"
        radius: 5
        // TODO: chart here
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
        model: ListModel {
          id: assetModel
          // TODO: real token data here
          ListElement {
            assetName: "AVAX"
            coinAmount: "0.000000000000000000"
            tokenAmount: "0.000000000000000000"
            isToken: false
            fiatAmount: "$0.00"
            imagePath: "qrc:/img/avax_logo.png"
          }
          ListElement {
            assetName: "AVME"
            coinAmount: "0.000000000000000000"
            tokenAmount: "0.000000000000000000"
            isToken: true
            fiatAmount: "$0.00"
            imagePath: "qrc:img/avme_logo.png"
          }
        }
      }
    }
  }
}

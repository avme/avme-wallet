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
  id: overviewScreen

  // Rectangle for the Account's general balances
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

  // Panel with the Account balances chart
  AVMEPanelOverview {
    id: overviewPanel
    width: (parent.width * 0.5) - (anchors.margins / 2)
    anchors {
      top: overviewBalance.bottom
      bottom: parent.bottom
      left: parent.left
      margins: 10
    }
    rightRadius: false
  }

  // Panel with each asset, balances and market data registered in the Account
  AVMEPanelOverviewAssets {
    id: assetsPanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
    anchors {
      top: parent.top
      bottom: parent.bottom
      right: parent.right
      margins: 10
    }
    leftRadius: false
  }
}

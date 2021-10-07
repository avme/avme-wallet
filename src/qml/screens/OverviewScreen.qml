/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtCharts 2.2

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

// Screen for showing a general overview for the chosen Account.
Item {
  id: overviewScreen

  AVMEOverviewBalance {
    id: overviewBalance
    width: (parent.width * 0.5) - (anchors.margins * 2)
    height: (parent.height * 0.15)
    anchors {
      top: parent.top
      left: parent.left
      margins: 10
    }
  }

  AVMEPanelOverview {
    id: overviewPanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
    anchors {
      top: overviewBalance.bottom
      bottom: parent.bottom
      left: parent.left
      margins: 10
    }
  }

  AVMEPanelOverviewAssets {
    id: assetsPanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
    anchors {
      top: parent.top
      bottom: parent.bottom
      right: parent.right
      margins: 10
    }
  }

  AVMEPopupPriceChart {
    id: pricechartPopup
  }
}

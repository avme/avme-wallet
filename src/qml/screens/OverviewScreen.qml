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
  AVMEAccountHeader {
    smooth: true
    id: accountHeader
  }

  AVMEPanelOverview {
    id: accountOverviewPanel
    anchors.top: accountHeader.bottom
    anchors.left: parent.left
    anchors.topMargin: parent.height * 0.025
    anchors.leftMargin: parent.width * 0.025
    height: parent.height * 0.875
    width: parent.width * 0.95
  }
}
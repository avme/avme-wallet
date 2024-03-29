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

  AVMEPanelOverview {
    id: overviewPanel
    anchors.fill: parent
    anchors.margins: 10
  }

  AVMEPopupPriceChart { id: pricechartPopup }
}

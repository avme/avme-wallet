/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtCharts 2.2

import "qrc:/qml/components"

// Panel for showing each asset's details in the Overview.

AVMEPanel {
  id: assetsPanel
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
    }
  }
}

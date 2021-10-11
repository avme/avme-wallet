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

  AVMEOverviewAssetList {
    id: assetList
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
  }

  AVMEAsyncImage {
    id: loadingPng
    width: height
    height: (parent.width / 3)
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

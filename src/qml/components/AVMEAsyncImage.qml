/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

import "qrc:/qml/components"

/**
 * Component for loading images asynchronously.
 * Displays a "loading" icon while the image isn't fully loaded.
 */
Item {
  id: asyncImageItem
  property alias imageSource: asyncImage.source
  property alias imageOpacity: asyncImage.opacity
  property bool loading: true

  Image {
    id: asyncImage
    visible: (!loading)
    asynchronous: true
    width: parent.width
    height: parent.height
    sourceSize.width: width * Screen.devicePixelRatio
    sourceSize.height: height * Screen.devicePixelRatio
    antialiasing: true
    smooth: true
    mipmap: true
    fillMode: Image.PreserveAspectFit
    onStatusChanged: if (asyncImage.status == Image.Ready) loading = false
  }

  Image {
    id: asyncImageLoading
    visible: (loading)
    width: parent.width
    height: parent.height
    sourceSize.width: width * Screen.devicePixelRatio
    sourceSize.height: height * Screen.devicePixelRatio
    antialiasing: true
    smooth: true
    mipmap: true
    source: "qrc:/img/icons/loading.png"
    fillMode: Image.PreserveAspectFit
    RotationAnimator {
      target: asyncImageLoading
      from: 0
      to: 360
      duration: 1000
      loops: Animation.Infinite
      easing.type: Easing.InOutQuad
      running: true
    }
  }
}

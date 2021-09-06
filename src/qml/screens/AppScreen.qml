/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

// Screen for a loaded DApp

Item {
  id: appScreen
  property string folder

  Connections {
    target: qmlSystem
    function onAppLoaded(folderPath) {
      folder = folderPath
      qmlSystem.setLocalScreen(appContent, folder + "/main.qml")
    }
  }

  Component.onDestruction: appContent.source = ""

  function changeScreen(file) {
    qmlSystem.setLocalScreen(appContent, folder + "/" + file)
  }

  Loader {
    id: appContent
    anchors.fill: parent
    antialiasing: true
    smooth: true
    source: ""
  }
}

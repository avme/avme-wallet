/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Panel for accessing DApps.
AVMEPanel {
  id: appsPanel
  title: "Applications"
  property alias selectedApp: appGrid.currentItem
  property var availableApps: null
  property var installedApps: null
  property int downloadRetries: 5

  Component.onCompleted: {
    infoPopup.info = "Downloading app list,<br>please wait..."
    infoPopup.open()
    qmlSystem.downloadAppList()
  }

  Connections {
    target: qmlSystem
    function onAppListDownloaded() {
      infoPopup.close()
      refreshGrid()
    }
    function onAppListDownloadFailed() {
      if (downloadRetries > 0) {
        infoPopup.info = "Download failed, re-trying...<br>"
        + "(" + (downloadRetries) + " tries left)"
        downloadRetries -= 1
        qmlSystem.downloadAppList()
      } else {
        infoPopup.close()
        refreshGrid()
      }
    }
  }

  function refreshGrid() {
    appList.clear()
    availableApps = qmlSystem.loadAppsFromList()
    installedApps = qmlSystem.loadInstalledApps()
    for (var i = 0; i < installedApps.length; i++) {
      if (filterInput.text == "" ||
        apps[i].name.toUpperCase().includes(filterInput.text.toUpperCase())
      ) {
        var matchedApp = null
        for (var j = 0; j < availableApps.length; j++) {
          if (availableApps[j]["folder"] == installedApps[i]["folder"]) {
            matchedApp = availableApps[j]
            break
          }
        }
        installedApps[i]["isUpdated"] = (matchedApp == null || (
          matchedApp["major"] <= installedApps[i]["major"] &&
          matchedApp["minor"] <= installedApps[i]["minor"] &&
          matchedApp["patch"] <= installedApps[i]["patch"]
        ))
        if (installedApps[i]["isUpdated"]) {
          installedApps[i]["nextMajor"] = installedApps[i]["major"]
          installedApps[i]["nextMinor"] = installedApps[i]["minor"]
          installedApps[i]["nextPatch"] = installedApps[i]["patch"]
        } else {
          installedApps[i]["nextMajor"] = matchedApp["major"]
          installedApps[i]["nextMinor"] = matchedApp["minor"]
          installedApps[i]["nextPatch"] = matchedApp["patch"]
        }
        appList.append(installedApps[i]);
      }
    }
  }

  AVMEAppGrid {
    id: appGrid
    anchors {
      top: parent.top
      bottom: bottomRow.top
      left: parent.left
      right: parent.right
      topMargin: 80
      bottomMargin: 20
      leftMargin: 20
      rightMargin: 20
    }
    model: ListModel { id: appList }
  }

  Row {
    id: bottomRow
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      bottomMargin: 20
    }
    spacing: 20

    AVMEButton {
      id: btnAdd
      width: appsPanel.width * 0.2
      text: "Add Application"
      onClicked: appSelectPopup.open()
    }
    AVMEInput {
      id: filterInput
      width: appsPanel.width * 0.4
      placeholder: "Filter by name"
      onTextEdited: refreshGrid()
    }
    AVMEButton {
      id: btnOpenLocal
      visible: (qmlSystem.getConfigValue("devMode") == "true")
      width: appsPanel.width * 0.2
      text: "Open Local App"
      onClicked: loadAppPopup.open()
    }
  }

  // Info popup for downloading the app list
  AVMEPopup {
    id: infoPopup
    property alias info: infoText.text
    widthPct: 0.2
    heightPct: 0.1
    Text {
      id: infoText
      color: "#FFFFFF"
      horizontalAlignment: Text.AlignHCenter
      anchors.centerIn: parent
      font.pixelSize: 14.0
    }
  }
}

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
  property int downloadRetries: 0

  Component.onCompleted: {
    infoPopup.info = "Downloading app list,<br>please wait..."
    infoPopup.open()
    qmlSystem.downloadAppList()
  }

  Connections {
    target: filterComboBox
    function onActivated(index) { refreshGrid() }
  }

  Connections {
    target: qmlSystem
    function onAppListDownloaded() {
      infoPopup.info = "Download complete,<br>reading apps..."
      var apps = qmlSystem.loadAppsFromList()
      for (var i = 0; i < apps.length; i++) {
        appList.append(apps[i]);
      }
      infoPopup.close()
      refreshGrid()
    }
    function onAppListDownloadFailed() {
      if (downloadRetries < 5) {
        infoPopup.info = "Download failed, re-trying...<br>"
        + "(" + (5 - downloadRetries) + " tries left)"
        downloadRetries += 1
        qmlSystem.downloadAppList()
      } else {
        infoPopup.close()
        refreshGrid()
      }
    }
  }

  // TODO: real data here
  function refreshGrid() {
    appList.clear()
    for (var i = 0; i < 5; i++) {
      var obj = {
        "chainId": 41113,
        "folder": "Test-" + (i + 1),
        "name": "Test App " + (i + 1),
        "major": 1,
        "minor": 0,
        "patch": (i + 1),
        "status": i % 3
      }
      var statusOn = (filterComboBox.currentIndex != 0)
      var nameOn = (filterInput.text != "")
      var statusOk = (obj.status == filterComboBox.currentIndex - 1) // 0 = "All"
      var nameOk = (obj.name.toUpperCase().includes(filterInput.text.toUpperCase()))
      if (
        ((statusOn && !nameOn) && statusOk) ||              // Status only
        ((!statusOn && nameOn) && nameOk) ||                // Name only
        ((statusOn && nameOn) && (statusOk && nameOk)) ||   // Both
        (!statusOn && !nameOn)                              // Neither
      ) {
        appList.append(obj)
      }
    }
  }

  AVMEAppGrid {
    id: appGrid
    anchors {
      top: parent.top
      bottom: filterRow.top
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
    id: filterRow
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      bottomMargin: 20
    }
    spacing: 20

    Text {
      id: filterText
      horizontalAlignment: Text.AlignHCenter
      anchors.verticalCenter: filterInput.verticalCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Filters:"
    }

    AVMEInput {
      id: filterInput
      width: appsPanel.width * 0.5
      placeholder: "Name"
      onTextEdited: refreshGrid()
    }
    ComboBox {
      id: filterComboBox
      width: appsPanel.width * 0.25
      model: ["All", "Uninstalled", "Installed", "Needs Update"]
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

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
    function onActivated(index) {}  // TODO: filter by status
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
    }
    function onAppListDownloadFailed() {
      if (downloadRetries < 5) {
        infoPopup.info = "Download failed, re-trying...<br>"
        + "(" + (5 - downloadRetries) + " tries left)"
        downloadRetries += 1
        qmlSystem.downloadAppList()
      } else {
        infoPopup.close()
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
    // TODO: real data here
    model: ListModel {
      id: appList
      ListElement {
        chainId: 41113
        folder: "Test-1"
        name: "Test App 1"
        major: 1
        minor: 0
        patch: 2
        status: 0
      }
      ListElement {
        chainId: 41113
        folder: "Test-2"
        name: "Test Application No. 2"
        major: 3
        minor: 14
        patch: 159
        status: 1
      }
      ListElement {
        chainId: 41113
        folder: "Test-3"
        name: "AVME Test Application Number 3"
        major: 2
        minor: 1
        patch: 0
        status: 2
      }
      ListElement {
        chainId: 41113
        folder: "Test-4"
        name: "AVME Wallet Test Application Number Four"
        major: 0
        minor: 1
        patch: 5
        status: 1
      }
      ListElement {
        chainId: 41113
        folder: "Test-5"
        name: "AVME Wallet Test Application Number Five And Knuckles GOTY Edition"
        major: 5
        minor: 5
        patch: 5
        status: 0
      }
    }
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

    // TODO: the actual filters
    AVMEInput {
      id: filterInput
      width: appsPanel.width * 0.5
      placeholder: "Name"
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

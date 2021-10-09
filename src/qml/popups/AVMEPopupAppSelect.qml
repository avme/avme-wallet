/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Popup for selecting a DApp from the list in the repo.
AVMEPopup {
  id: appSelectPopup
  widthPct: 0.5
  heightPct: 1.0
  property var apps: null
  property alias appList: appList
  property alias installBtn: btnInstall
  property alias infoTimer: infoTimer

  onAboutToShow: {
    apps = qmlSystem.loadAppsFromList()
    refreshList("")
    filterInput.text = ""
    filterInput.forceActiveFocus()
  }
  onAboutToHide: {
    appModel.clear()
    apps = null
    filterInput.text = ""
  }

  function refreshList(filter) {
    appModel.clear()
    for (var i = 0; i < apps.length; i++) {
      if (filter == "" || apps[i]["name"].toUpperCase().includes(filter.toUpperCase())) {
        appModel.append(apps[i])
      }
    }
    appModel.sortByName()
    appList.currentIndex = -1
  }

  function handleInstall() {
    if (!qmlSystem.appIsInstalled(appList.currentItem.itemFolder)) {
      var app = ({})
      app["chainId"] = appList.currentItem.itemChainId
      app["folder"] = appList.currentItem.itemFolder
      app["name"] = appList.currentItem.itemName
      app["major"] = appList.currentItem.itemMajor
      app["minor"] = appList.currentItem.itemMinor
      app["patch"] = appList.currentItem.itemPatch
      infoPopup.info = "Downloading app, please wait..."
      infoPopup.open()
      appSelectPopup.close()
      qmlSystem.installApp(app)
    } else {
      infoTimer.start()
    }
  }

  Column {
    id: items
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 20

    // Enter/Return key override
    Keys.onPressed: {
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        if (btnInstall.enabled) { handleInstall() }
      }
    }

    Text {
      id: info
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: (!infoTimer.running)
      ? "Choose an application from the list."
      : "Application already installed, please try another."
      Timer { id: infoTimer; interval: 2000 }
    }

    Rectangle {
      id: listRect
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width * 0.9)
      height: (parent.height * 0.65)
      radius: 5
      color: "#16141F"

      AVMEAppList {
        id: appList
        width: parent.width
        height: (parent.height * 0.85)
        anchors.horizontalCenter: parent.horizontalCenter
        model: ListModel {
          id: appModel
          function sortByName() {
            for (var i = 0; i < count; i++) {
              for (var j = 0; j < i; j++) {
                if (get(i).name < get(j).name) { move(i, j, 1) }
              }
            }
          }
        }
      }
    }

    AVMEInput {
      id: filterInput
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      label: "Filter by name"
      onTextEdited: appSelectPopup.refreshList(filterInput.text)
    }

    AVMEButton {
      id: btnInstall
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (appList.currentItem != null)
      text: "Install Application"
      onClicked: handleInstall()
    }

    AVMEButton {
      id: btnClose
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Close"
      onClicked: appSelectPopup.close()
    }
  }
}

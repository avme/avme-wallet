/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

// Screen for accessing DApps.
Item {
  id: applicationsScreen

  Connections {
    target: qmlSystem
    function onAppInstalled(success) {
      infoPopup.close()
      if (success) {
        appsPanel.refreshGrid()
      } else {
        installFailPopup.open()
      }
    }
  }

  AVMEPanelApps {
    id: appsPanel
    width: (parent.width * 0.7)
    anchors {
      top: parent.top
      left: parent.left
      bottom: parent.bottom
      margins: 10
    }
  }

  AVMEPanelAppDetails {
    id: appDetailsPanel
    width: (parent.width * 0.3)
    anchors {
      top: parent.top
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
  }

  // Info popup for download statuses
  AVMEPopup {
    id: infoPopup
    property alias info: infoText.text
    widthPct: 0.3
    heightPct: 0.1
    Text {
      id: infoText
      color: "#FFFFFF"
      horizontalAlignment: Text.AlignHCenter
      anchors.centerIn: parent
      font.pixelSize: 14.0
    }
  }

  // Popup for selecting a DApp from the repo
  AVMEPopupAppSelect { id: appSelectPopup }

  // Popup for loading a local application (for developers)
  AVMEPopupLoadApp {
    id: loadAppPopup
    widthPct: 0.5
    heightPct: 0.35
    loadBtn.onClicked: loadLocalApp()
    function loadLocalApp() {
      qmlSystem.setScreen(content, "qml/screens/AppScreen.qml")
      qmlSystem.appLoaded(folder)
    }
  }

  // Popup for warning about application install failure
  AVMEPopupInfo {
    id: installFailPopup; icon: "qrc:/img/warn.png"
    info: "DApp install failed.<br>Please try again."
  }

  // Popup for confirming app uninstallation
  AVMEPopupYesNo {
    id: confirmUninstallAppPopup
    widthPct: 0.5
    heightPct: 0.25
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to remove this DApp?"
    yesBtn.onClicked: {
      var app = ({})
      app["chainId"] = appsPanel.selectedApp.itemChainId
      app["folder"] = appsPanel.selectedApp.itemFolder
      app["name"] = appsPanel.selectedApp.itemName
      app["major"] = appsPanel.selectedApp.itemMajor
      app["minor"] = appsPanel.selectedApp.itemMinor
      app["patch"] = appsPanel.selectedApp.itemPatch
      qmlSystem.uninstallApp(app)
      confirmUninstallAppPopup.close()
      appsPanel.refreshGrid()
    }
    noBtn.onClicked: {
      confirmUninstallAppPopup.close()
    }
  }
}

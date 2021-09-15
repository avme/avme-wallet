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

  // Popup for loading a local application (for developers)
  AVMEPopupLoadApp {
    id: loadAppPopup
    widthPct: 0.4
    heightPct: 0.4
    loadBtn.onClicked: loadLocalApp()
    function loadLocalApp() {
      qmlSystem.setScreen(content, "qml/screens/AppScreen.qml")
      qmlSystem.appLoaded(folder)
    }
  }

  // Popup for selecting a DApp from the repo
  AVMEPopupAppSelect {
    id: appSelectPopup
    installBtn.onClicked: {
      var app = ({})
      app["chainId"] = appList.currentItem.itemChainId
      app["folder"] = appList.currentItem.itemFolder
      app["name"] = appList.currentItem.itemName
      app["major"] = appList.currentItem.itemMajor
      app["minor"] = appList.currentItem.itemMinor
      app["patch"] = appList.currentItem.itemPatch
      qmlSystem.installApp(app)
      appSelectPopup.close()
      appsPanel.refreshGrid()
    }
  }

  // Popup for confirming app uninstallation
  AVMEPopupYesNo {
    id: confirmUninstallAppPopup
    widthPct: 0.4
    heightPct: 0.25
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to uninstall this application?"
    yesBtn.onClicked: {
      qmlSystem.uninstallApp(appsPanel.selectedApp.itemFolder)
      confirmUninstallAppPopup.close()
      appsPanel.refreshGrid()
    }
    noBtn.onClicked: {
      confirmUninstallAppPopup.close()
    }
  }
}

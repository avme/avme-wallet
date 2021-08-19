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
    width: (parent.width * 0.6)
    anchors {
      top: parent.top
      left: parent.left
      bottom: parent.bottom
      margins: 10
    }
  }

  AVMEPanelAppDetails {
    id: appDetailsPanel
    width: (parent.width * 0.4)
    anchors {
      top: parent.top
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
  }

  // Popup for confirming app uninstallation
  AVMEPopupYesNo {
    id: confirmUninstallAppPopup
    widthPct: 0.4
    heightPct: 0.25
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to uninstall this application?"
    // TODO
    yesBtn.onClicked: {
      confirmUninstallAppPopup.close()
    }
    noBtn.onClicked: {
      confirmUninstallAppPopup.close()
    }
  }
}

/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Panel for showing a given DApp's details.
AVMEPanel {
  id: appDetailsPanel
  title: "Application Details"

  Text {
    visible: (appsPanel.selectedApp == null)
    anchors.centerIn: parent
    horizontalAlignment: Text.AlignHCenter
    color: "#FFFFFF"
    font.pixelSize: 24.0
    text: "No applications<br>selected."
  }

  Column {
    visible: (appsPanel.selectedApp != null)
    anchors.centerIn: parent
    spacing: 20

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 20

      Image {
        id: appIcon
        height: 128
        antialiasing: true
        smooth: true
        fillMode: Image.PreserveAspectFit
        //source: "https://raw.githubusercontent.com"
        //+ "/avme/avme-wallet-applications/main/apps"
        //+ appsPanel.selectedApp.itemFolder + "/icon.png"
        source: "qrc:/img/unknown_token.png"  // TODO
      }
    }

    Text {
      id: appName
      anchors.horizontalCenter: parent.horizontalCenter
      width: (appDetailsPanel.width * 0.9)
      height: 40
      horizontalAlignment: Text.AlignHCenter
      wrapMode: Text.WordWrap
      elide: Text.ElideRight
      color: "#FFFFFF"
      font.pixelSize: 14.0
      font.bold: true
      text: ((appsPanel.selectedApp != null) ? appsPanel.selectedApp.itemName : "")
    }
    Text {
      id: appVersion
      anchors.horizontalCenter: parent.horizontalCenter
      width: (appDetailsPanel.width * 0.9)
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      // TODO: *installed* app version when status > 0 (for comparison with updates)
      text: "<b>Version:</b> " + ((appsPanel.selectedApp != null)
      ? appsPanel.selectedApp.itemMajor + "."
      + appsPanel.selectedApp.itemMinor + "."
      + appsPanel.selectedApp.itemPatch
      : "")
    }
    Text {
      id: appStatus
      anchors.horizontalCenter: parent.horizontalCenter
      width: (appDetailsPanel.width * 0.9)
      horizontalAlignment: Text.AlignHCenter
      font.pixelSize: 14.0
      color: {
        if (appsPanel.selectedApp == null) {
          color: "#FFFFFF"
        } else if (appsPanel.selectedApp.itemStatus == 0) {
          color: "red"
        } else if (appsPanel.selectedApp.itemStatus == 1) {
          color: "green"
        } else if (appsPanel.selectedApp.itemStatus == 2) {
          color: "yellow"
        }
      }
      text: {
        if (appsPanel.selectedApp == null) {
          text: ""
        } else if (appsPanel.selectedApp.itemStatus == 0) {
          text: "<b>Status:</b> Uninstalled"
        } else if (appsPanel.selectedApp.itemStatus == 1) {
          text: "<b>Status:</b> Installed"
        } else if (appsPanel.selectedApp.itemStatus == 2) {
          text: "<b>Status:</b> Needs Update ("
          + appsPanel.selectedApp.itemMajor + "."
          + appsPanel.selectedApp.itemMinor + "."
          + appsPanel.selectedApp.itemPatch
          + ")"
        }
      }
    }
    AVMEButton {
      id: btnOpen
      width: (appDetailsPanel.width * 0.8)
      anchors.horizontalCenter: parent.horizontalCenter
      visible: (appsPanel.selectedApp != null && appsPanel.selectedApp.itemStatus == 1)
      text: "Open Application"
      onClicked: {} // TODO
    }
    AVMEButton {
      id: btnUpdate
      width: (appDetailsPanel.width * 0.8)
      anchors.horizontalCenter: parent.horizontalCenter
      visible: (appsPanel.selectedApp != null && appsPanel.selectedApp.itemStatus == 2)
      text: "Update Application"
      onClicked: {} // TODO
    }
    AVMEButton {
      id: btnUninstall
      width: (appDetailsPanel.width * 0.8)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Uninstall Application"
      onClicked: confirmUninstallAppPopup.open()
    }
  }

  AVMEButton {
    id: btnOpenLocal
    visible: (qmlSystem.getConfigValue("devMode") == "true")
    width: (appDetailsPanel.width * 0.8)
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 20
    text: "Open Local App"
    onClicked: loadAppPopup.open()
  }
}

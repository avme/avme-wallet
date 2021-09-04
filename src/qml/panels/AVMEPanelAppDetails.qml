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
        source: "qrc:/img/unknown_token.png"  // TODO
        //source: (appsPanel.selectedApp != null) ? appsPanel.selectedApp.itemIcon : ""
      }
    }

    Text {
      id: appName
      anchors.horizontalCenter: parent.horizontalCenter
      width: (appDetailsPanel.width * 0.9)
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 18.0
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
      // TODO: *installed* app version (for comparison with updates)
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
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "<b>Status:</b> "
      // TODO
      // Status would be "Installed", "Not Installed", "Needs Update"
      // if not updating automatically, etc.
      //+ ((tokensPanel.selectedToken != null) ? tokensPanel.selectedToken.itemAVAXPairContract : "")
    }
    AVMEButton {
      id: btnInstall
      width: (appDetailsPanel.width * 0.8)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Install Application"
      onClicked: {} // TODO
    }
    AVMEButton {
      id: btnOpen
      width: (appDetailsPanel.width * 0.8)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Open Application"
      onClicked: {} // TODO
    }
    AVMEButton {
      id: btnUpdate
      width: (appDetailsPanel.width * 0.8)
      anchors.horizontalCenter: parent.horizontalCenter
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
    // TODO: "Open Local App" button when Developer Mode is implemented in Settings
  }

  AVMEButton {
    id: btnOpenLocal
    visible: (qmlSystem.getConfigValue("devMode") == "true")
    width: (appDetailsPanel.width * 0.8)
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 20
    text: "Open Local App"
    onClicked: {} // TODO
  }
}

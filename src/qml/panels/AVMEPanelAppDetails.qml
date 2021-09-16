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
      visible: (appsPanel.selectedApp != null && !appsPanel.selectedApp.itemIsUpdated)
      horizontalAlignment: Text.AlignHCenter
      font.pixelSize: 14.0
      color: "yellow"
      text: "Needs Update -> " + ((appsPanel.selectedApp != null)
      ? appsPanel.selectedApp.itemNextMajor + "."
      + appsPanel.selectedApp.itemNextMinor + "."
      + appsPanel.selectedApp.itemNextPatch
      : "")
    }
    AVMEButton {
      id: btnOpen
      width: (appDetailsPanel.width * 0.8)
      anchors.horizontalCenter: parent.horizontalCenter
      visible: (appsPanel.selectedApp != null && appsPanel.selectedApp.itemIsUpdated)
      text: "Open Application"
      onClicked: {} // TODO
    }
    AVMEButton {
      id: btnUpdate
      width: (appDetailsPanel.width * 0.8)
      anchors.horizontalCenter: parent.horizontalCenter
      visible: (appsPanel.selectedApp != null && !appsPanel.selectedApp.itemIsUpdated)
      text: "Update Application"
      onClicked: {} // TODO
    }
    AVMEButton {
      id: btnUninstall
      width: (appDetailsPanel.width * 0.8)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Remove Application"
      onClicked: confirmUninstallAppPopup.open()
    }
  }
}

/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Panel for accessing DApps.
AVMEPanel {
  id: appsPanel
  title: "Applications"
  property alias selectedApp: appList.currentItem

  Component.onCompleted: {} // TODO: reload apps here probably

  Connections {
    target: filterComboBox
    function onActivated(index) {}  // TODO
  }

  AVMEAppList {
    id: appList
    width: (parent.width * 0.9)
    anchors {
      top: parent.top
      bottom: filterRow.top
      horizontalCenter: parent.horizontalCenter
      topMargin: 80
      bottomMargin: 20
    }
    // TODO: real data here
    model: ListModel {
      id: appModel
      ListElement {
        chainId: 41113
        folder: "Test-1"
        name: "Test App 1"
        major: 1
        minor: 0
        patch: 2
      }
      ListElement {
        chainId: 41113
        folder: "Test-1"
        name: "Test App 2"
        major: 3
        minor: 14
        patch: 159
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
}

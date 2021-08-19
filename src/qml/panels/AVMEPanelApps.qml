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
        devIcon: "qrc:/img/avax_logo.png"
        icon: "qrc:/img/avme_logo.png"
        name: "Test App 1"
        description: "A nice test app numbered as one"
        creator: "MyName Here"
        major: 1
        minor: 0
        patch: 2
      }
      ListElement {
        devIcon: "qrc:/img/pangolin.png"
        icon: "qrc:/img/yieldyak.png"
        name: "Test App 2"
        description: "A pretty long description here about how utterly fantabulous this test app is and the fact it is numero DOS which in Spanish means two"
        creator: "SomeDude WithAVision Inc."
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
      text: "Filter:"
    }

    // TODO: the actual filter
    AVMEInput {
      id: filterInput
      width: appsPanel.width * 0.5
      placeholder: "Creator or name"
    }
  }
}

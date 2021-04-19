/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

import "qrc:/qml/components"

// The main window
ApplicationWindow {
  id: window
  property bool menuToggle: false

  title: "AVME Wallet"
  width: 1280
  height: 720
  minimumWidth: width
  minimumHeight: height
  maximumWidth: width
  maximumHeight: height
  visible: true

  Connections {
    target: System
    onGoToOverview: menuToggle = true
    onHideMenu: menuToggle = false
  }

  // States for menu visibility and loader anchoring
  StateGroup {
    id: menuStates
    states: [
      State {
        name: "menuHide"; when: !menuToggle
        PropertyChanges { target: sideMenu; visible: false }
        AnchorChanges { target: content; anchors.left: parent.left }
      },
      State {
        name: "menuShow"; when: menuToggle
        PropertyChanges { target: sideMenu; visible: true }
        AnchorChanges { target: content; anchors.left: sideMenu.right }
      }
    ]
  }

  // Background w/ logo image
  Rectangle {
    id: bg
    anchors.fill: parent
    color: "#252935"

    Image {
      id: logoBg
      anchors {
        horizontalCenter: parent.horizontalCenter
        horizontalCenterOffset: 400
      }
      width: 1000
      height: 1000
      opacity: 0.15
      antialiasing: true
      smooth: true
      fillMode: Image.PreserveAspectFit
      source: "qrc:/img/avme_logo_hd.png"
    }
  }

  AVMESideMenu {
    id: sideMenu
    width: 80
    anchors {
      left: parent.left
      top: parent.top
      bottom: parent.bottom
    }
  }

  // Dynamic screen loader (used in setScreen(id, screenpath))
  Loader {
    id: content
    anchors {
      right: parent.right
      top: parent.top
      bottom: parent.bottom
    }
    source: "qrc:/qml/screens/StartScreen.qml"
  }
}

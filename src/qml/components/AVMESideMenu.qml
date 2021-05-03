/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Side panel that acts as a "global menu"
Rectangle {
  id: sideMenu
  implicitWidth: 80
  implicitHeight: parent.height
  color: "#1C2029"

  Connections {
    target: System
    function onGoToOverview() { itemSelection.y = itemOverview.y }
  }

  function changeScreen(name) {
    content.active = false
    System.setScreen(content, "qml/screens/" + name + "Screen.qml")
    content.active = true
  }

  Rectangle {
    id: itemSelection
    width: 2
    height: 70
    anchors.right: parent.right
    visible: (y > 0)
    y: 0
    color: "#782D8B"
  }

  Column {
    id: items
    anchors.fill: parent
    spacing: 5

    Image {
      id: logo
      height: 60
      anchors.horizontalCenter: parent.horizontalCenter
      source: "qrc:/img/avme_logo.png"
      fillMode: Image.PreserveAspectFit
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width - 10)
      height: 1
      color: "#4E525D"
    }

    AVMESideMenuItem {
      id: itemOverview
      icon: (itemSelection.y == y) ? "qrc:/img/icons/gridSelect.png" : "qrc:/img/icons/grid.png"
      label: "Overview"
      area.onClicked: {
        itemSelection.y = y
        changeScreen("Overview")
      }
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width - 10)
      height: 1
      color: "#4E525D"
    }

    AVMESideMenuItem {
      id: itemHistory
      icon: (itemSelection.y == y) ? "qrc:/img/icons/inboxesSelect.png" : "qrc:/img/icons/inboxes.png"
      label: "History"
      area.onClicked: {
        itemSelection.y = y
        changeScreen("History")
      }
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width - 10)
      height: 1
      color: "#4E525D"
    }

    AVMESideMenuItem {
      id: itemSend
      icon: (itemSelection.y == y) ? "qrc:/img/icons/directionsSelect.png" : "qrc:/img/icons/directions.png"
      label: "Send"
      area.onClicked: {
        itemSelection.y = y
        changeScreen("Transaction")
      }
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width - 10)
      height: 1
      color: "#4E525D"
    }

    AVMESideMenuItem {
      id: itemExchange
      icon: (itemSelection.y == y) ? "qrc:/img/icons/credit-cardSelect.png" : "qrc:/img/icons/credit-card.png"
      label: "Exchange/<br>Liquidity"
      area.onClicked: {
        itemSelection.y = y
        changeScreen("Exchange")
      }
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width - 10)
      height: 1
      color: "#4E525D"
    }

    AVMESideMenuItem {
      id: itemStaking
      icon: (itemSelection.y == y) ? "qrc:/img/icons/coinSelect.png" : "qrc:/img/icons/coin.png"
      label: "Staking"
      area.onClicked: {
        itemSelection.y = y
        changeScreen("Staking")
      }
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width - 10)
      height: 1
      color: "#4E525D"
    }

    AVMESideMenuItem {
      id: itemSettings
      icon: (itemSelection.y == y) ? "qrc:/img/icons/cogSelect.png" : "qrc:/img/icons/cog.png"
      label: "Settings"
      area.onClicked: {
        itemSelection.y = y
        changeScreen("Settings")
      }
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width - 10)
      height: 1
      color: "#4E525D"
    }

    AVMESideMenuItem {
      id: itemAbout
      icon: "qrc:/img/icons/info.png"
      label: "About"
      area.onClicked: {
        itemSelection.y = y
        changeScreen("About")
      }
    }
  }
}

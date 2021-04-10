import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Side panel that acts as a "global menu"

Drawer {
  id: sideMenu

  width: 80
  height: parent.height
  dragMargin: 0
  edge: Qt.LeftEdge
  position: 1.0
  interactive: false
  visible: true
  modal: false

  background: Rectangle {
    id: bg
    anchors.fill: parent
    color: "#1C2029"
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
      icon: "qrc:/img/icons/grid.png"
      label: "Overview"
      onChangeActiveItem: itemSelection.y = y
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width - 10)
      height: 1
      color: "#4E525D"
    }

    AVMESideMenuItem {
      id: itemSend
      icon: "qrc:/img/icons/coin.png"
      label: "Send/<br>Receive"
      onChangeActiveItem: itemSelection.y = y
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width - 10)
      height: 1
      color: "#4E525D"
    }

    AVMESideMenuItem {
      id: itemExchange
      icon: "qrc:/img/icons/directions.png"
      label: "Exchange"
      onChangeActiveItem: itemSelection.y = y
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width - 10)
      height: 1
      color: "#4E525D"
    }

    AVMESideMenuItem {
      id: itemLiquidity
      icon: "qrc:/img/icons/upload.png"
      label: "Liquidity"
      onChangeActiveItem: itemSelection.y = y
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width - 10)
      height: 1
      color: "#4E525D"
    }

    AVMESideMenuItem {
      id: itemStaking
      icon: "qrc:/img/icons/credit-card.png"
      label: "Staking"
      onChangeActiveItem: itemSelection.y = y
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width - 10)
      height: 1
      color: "#4E525D"
    }

    AVMESideMenuItem {
      id: itemClose
      icon: "qrc:/img/icons/log-out.png"
      label: "Close<br>Wallet"
    }
  }
}

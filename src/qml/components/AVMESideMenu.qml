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
    onWalletLoaded: {}
    onAccountChosen: {
      itemSelection.y = itemOverview.y
    }
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
        System.setScreen(content, "qml/screens/OverviewScreen.qml")
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
      icon: (itemSelection.y == y) ? "qrc:/img/icons/coinSelect.png" : "qrc:/img/icons/coin.png"
      label: "Send/<br>Receive"
      area.onClicked: {
        itemSelection.y = y
        System.setScreen(content, "qml/screens/TransactionScreen.qml")
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
      icon: (itemSelection.y == y) ? "qrc:/img/icons/directionsSelect.png" : "qrc:/img/icons/directions.png"
      label: "Exchange/<br>Liquidity"
      area.onClicked: {
        itemSelection.y = y
        System.setScreen(content, "qml/screens/ExchangeScreen.qml")
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
      icon: (itemSelection.y == y) ? "qrc:/img/icons/credit-cardSelect.png" : "qrc:/img/icons/credit-card.png"
      label: "Staking"
      area.onClicked: {
        itemSelection.y = y
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
      icon: (itemSelection.y == y) ? "qrc:/img/icons/infoSelect.png" : "qrc:/img/icons/info.png"
      label: "About"
      area.onClicked: {
        itemSelection.y = y
      }
    }
  }

  // Yes/No popup for confirming Wallet closure
  AVMEPopupYesNo {
    id: closeWalletPopup
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to close this Wallet?"
    yesBtn.onClicked: {
      closeWalletPopup.close()
      System.stopAllBalanceThreads()
      System.closeWallet()
      console.log("Wallet closed successfully")
      window.menu.visible = false
      System.setScreen(content, "qml/screens/StartScreen.qml")
    }
    noBtn.onClicked: closeWalletPopup.close()
  }
}

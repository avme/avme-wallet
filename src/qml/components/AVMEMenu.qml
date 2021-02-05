import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Side menu with general options for wallet management.

Rectangle {
  id: sideMenu
  width: 200
  color: "#9CE3FD"
  border.width: 2
  border.color: "#7AC1DB"
  anchors {
    left: parent.left
    top: parent.top
    bottom: parent.bottom
  }

  // Header (logo)
  Rectangle {
    id: header
    width: parent.width
    height: 80
    anchors.top: parent.top
    color: "#9A4FAD"

    Image {
      id: logo
      anchors {
        fill: parent
        centerIn: parent
        margins: 10
      }
      fillMode: Image.PreserveAspectFit
      source: "qrc:/img/avme_banner.png"
    }
  }

  // Middle (options)
  Column {
    id: options
    width: parent.width
    spacing: 10
    anchors {
      horizontalCenter: parent.horizontalCenter
      top: header.bottom
      bottom: footer.top
      topMargin: 10
    }

    Rectangle {
      width: parent.width
      height: 40
      color: "#F66986"
      Label {
        anchors.centerIn: parent
        text: "Accounts"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: System.setScreen(content, "qml/screens/AccountsScreen.qml")
      }
    }

    // TODO: settings screen
    Rectangle {
      width: parent.width
      height: 40
      color: "#F66986"
      Label {
        anchors.centerIn: parent
        text: "Settings (WIP)"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: console.log("Clicked Settings")
      }
    }

    Rectangle {
      width: parent.width
      height: 40
      color: "#F66986"
      Label {
        anchors.centerIn: parent
        text: "Close Wallet"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: closeWalletPopup.open()
      }
    }
  }

  // Footer (copyright)
  Text {
    id: footer
    anchors {
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      bottomMargin: 10
    }
    text: "© 2021 AVME"
  }

  // Yes/No popup for confirming Wallet closure
  AVMEPopupYesNo {
    id: closeWalletPopup
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to close this Wallet?"
    yesBtn.onClicked: {
      closeWalletPopup.close()
      console.log("Wallet closed successfully")
      System.setScreen(content, "qml/screens/StartScreen.qml")
    }
    noBtn.onClicked: closeWalletPopup.close()
  }
}

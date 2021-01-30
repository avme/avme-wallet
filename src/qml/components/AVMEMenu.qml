import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
  id: menu
  implicitWidth: 200
  color: "#9CE3FD"
  border.width: 2
  border.color: "#7AC1DB"
  z: 1

  // Header (logo)
  Rectangle {
    id: menuHeader
    width: parent.width
    height: 80
    anchors.top: parent.top
    color: "#9A4FAD"
    Label {
      anchors.centerIn: parent
      text: "[Logo] AVME"
    }
  }

  // Middle (options)
  Column {
    id: menuOptions
    width: parent.width
    spacing: 10
    anchors {
      horizontalCenter: parent.horizontalCenter
      top: menuHeader.bottom
      bottom: menuFooter.top
      topMargin: 10
    }

    Rectangle {
      width: parent.width
      height: 40
      color: "#F66986"
      Label {
        anchors.centerIn: parent
        text: "Wallets"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: System.setScreen(content, "screens/Wallets.qml")
      }
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
        onClicked: System.setScreen(content, "screens/Accounts.qml")
      }
    }

    Rectangle {
      width: parent.width
      height: 40
      color: "#F66986"
      Label {
        anchors.centerIn: parent
        text: "Settings"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: console.log("Clicked Settings")
      }
    }
  }

  // Footer (copyright)
  Rectangle {
    id: menuFooter
    width: parent.width
    height: 80
    anchors.bottom: parent.bottom
    color: "#9A4FAD"
    Label {
      anchors.centerIn: parent
      text: "Copyright 2021 AVME"
    }
  }
}

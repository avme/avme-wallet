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

    Row {
      id: menuHeaderRow
      spacing: 10
      anchors.fill: parent
      anchors.leftMargin: (parent.width / 10) - spacing
      Image {
        id: logo_png
        height: parent.height / 1.5
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: "qrc:/img/avme_logo.png"
      }
      Text {
        id: logo_text
        text: "AVME"
        font.bold: true
        font.pointSize: 24.0
        anchors.verticalCenter: logo_png.verticalCenter
      }
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
        text: "Accounts"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: System.setScreen(content, "qml/screens/AccountsScreen.qml")
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
  Text {
    id: menuFooter
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 10
    text: "© 2021 AVME"
  }
}

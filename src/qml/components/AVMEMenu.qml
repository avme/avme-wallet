import QtQuick 2.9
import QtQuick.Controls 2.2

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

    Row {
      spacing: 10
      anchors.fill: parent
      anchors.leftMargin: (parent.width / 10) - spacing
      Image {
        id: logoPng
        height: parent.height / 1.5
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: "qrc:/img/avme_logo.png"
      }
      Text {
        id: logoText
        anchors.verticalCenter: logoPng.verticalCenter
        font.bold: true
        font.pointSize: 24.0
        text: "AVME"
      }
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

  // Modal for confirming Wallet closure
  Popup {
    id: closeWalletPopup
    width: window.width / 2
    height: window.height / 4
    x: (window.width / 2) - (width / 2)
    y: (window.height / 2) - (height / 2)
    modal: true
    focus: true
    padding: 0  // Remove white borders
    closePolicy: Popup.CloseOnPressOutside

    Rectangle {
      id: popupBg
      anchors.fill: parent
      color: "#9A4FAD"

      // Popup info
      Row {
        id: popupInfo
        anchors {
          horizontalCenter: parent.horizontalCenter
          top: parent.top
          topMargin: parent.height / 6
        }
        spacing: 10

        Image {
          id: popupPng
          height: 50
          anchors.verticalCenter: parent.verticalCenter
          fillMode: Image.PreserveAspectFit
          source: "qrc:/img/warn.png"
        }

        Text {
          id: popupText
          anchors.verticalCenter: popupPng.verticalCenter
          horizontalAlignment: Text.AlignHCenter
          text: "Are you sure you want to close this Wallet?"
        }
      }

      // Popup buttons
      Row {
        id: popupBtns
        anchors {
          horizontalCenter: parent.horizontalCenter
          bottom: parent.bottom
          bottomMargin: parent.height / 6
        }
        spacing: 10

        AVMEButton {
          id: btnNo
          text: "No"
          onClicked: closeWalletPopup.close()
        }
        AVMEButton {
          id: btnYes
          text: "Yes"
          onClicked: {
            closeWalletPopup.close()
            console.log("Wallet closed successfully")
            System.setScreen(content, "qml/screens/StartScreen.qml")
          }
        }
      }
    }
  }
}

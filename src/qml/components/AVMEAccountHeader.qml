/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Header that shows the current Account and options for changing it
Rectangle {
  id: accountHeader
  anchors {
    top: parent.top
    left: parent.left
    right: parent.right
    margins: 10
  }
  height: 50
  color: "#1D212A"
  radius: 10

  Text {
    id: addressText
    anchors {
      verticalCenter: parent.verticalCenter
      left: parent.left
      leftMargin: 10
    }
    color: "#FFFFFF"
    text: (!addressTimer.running) ? System.getTxSenderAccount() : "Copied to clipboard!"
    font.pointSize: 16.0
    Timer { id: addressTimer; interval: 2000 }

    Rectangle {
      id: addressRect
      anchors.fill: parent
      anchors.margins: -10
      color: "#1D212A"
      z: parent.z - 1
      radius: 10
      MouseArea {
        id: addressMouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: (!addressTimer.running)
        onEntered: parent.color = "#3F434C"
        onExited: parent.color = "#1D212A"
        onClicked: {
          parent.color = "#1D212A"
          System.copyToClipboard(System.getTxSenderAccount())
          addressTimer.start()
        }
      }
    }
  }

  AVMEButton {
    id: btnChangeAccount
    width: parent.width * 0.15
    anchors {
      verticalCenter: parent.verticalCenter
      right: btnChangeWallet.left
      rightMargin: 10
    }
    text: "Change Account"
    onClicked: {
      System.hideMenu()
      System.setScreen(content, "qml/screens/AccountsScreen.qml")
    }
  }

  AVMEButton {
    id: btnChangeWallet
    width: parent.width * 0.15
    anchors {
      verticalCenter: parent.verticalCenter
      right: parent.right
      rightMargin: 10
    }
    text: "Change Wallet"
    onClicked: {
      System.hideMenu()
      System.setScreen(content, "qml/screens/StartScreen.qml")
    }
  }

  /*
  AVMEButton {
    id: btnCopyToClipboard
    width: parent.width * 0.2
    anchors {
      verticalCenter: parent.verticalCenter
      right: parent.right
      rightMargin: 10
    }
    enabled: (!btnClipboardTimer.running)
    text: (enabled) ? "Copy to Clipboard" : "Copied!"
    Timer { id: btnClipboardTimer; interval: 2000 }
    onClicked: {
      System.copyToClipboard(System.getTxSenderAccount())
      btnClipboardTimer.start()
    }
  }
  */
}

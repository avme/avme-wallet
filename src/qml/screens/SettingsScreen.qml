/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Screen for showing general settings
Item {
  id: settingsScreen

  AVMEPanel {
    id: settingsPanel
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
    title: "General Settings"

    // Get stored configs
    Component.onCompleted: {
      // Remember password for X minutes
      var storedValue = qmlSystem.getConfigValue("storePass")
      storedValue = (+storedValue >= 0) ? storedValue : "0"
      storePassBox.value = +storedValue

      // Developer Mode checkbox
      var toggled = qmlSystem.getConfigValue("devMode")
      if (toggled == "true") { developerCheck.checked = true }
      else if (toggled == "false") { developerCheck.checked = false }

      // Custom Wallet API inputs
      var walletAPIStr = qmlSystem.getConfigValue("customWalletAPI")
      if (walletAPIStr != "NotFound: ") {
        var walletAPIJson = JSON.parse(walletAPIStr)
        customWalletAPIHost.text = walletAPIJson["host"]
        customWalletAPIPort.text = walletAPIJson["port"]
        customWalletAPITarget.text = walletAPIJson["target"]
      }

      // Custom Websocket API inputs
      var websocketAPIStr = qmlSystem.getConfigValue("customWebsocketAPI")
      if (websocketAPIStr != "NotFound: ") {
        var websocketAPIJson = JSON.parse(websocketAPIStr)
        customWebsocketAPIHost.text = websocketAPIJson["host"]
        customWebsocketAPIPort.text = websocketAPIJson["port"]
        customWebsocketAPITarget.text = websocketAPIJson["target"]
        customWebsocketAPIPluginPort.text = websocketAPIJson["pluginPort"]
      }
    }

    Column {
      id: settingsCol
      anchors {
        top: parent.top
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        topMargin: 80
        bottomMargin: 40
        leftMargin: 40
        rightMargin: 40
      }
      spacing: 30

      Text {
        id: storePassText
        width: settingsCol.width * 0.75
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Remember password after next transaction for (0 = do not remember)"

        AVMESpinbox {
          id: storePassBox
          width: settingsCol.width * 0.15
          anchors {
            verticalCenter: parent.verticalCenter
            left: parent.right
          }
          from: 0
          to: 9999  // ~7 days
          editable: true
          validator: RegExpValidator { regExp: /[0-9]{0,4}/ }
          Rectangle {
            id: storePassRect
            property alias timer: storePassRectTimer
            anchors.fill: parent
            color: "#8858A0C9"
            radius: 5
            visible: storePassRectTimer.running
            Timer { id: storePassRectTimer; interval: 250 }
          }
          Text {
            id: storePassBoxText
            width: settingsCol.width * 0.1
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 10
            }
            font.pixelSize: 14.0
            color: "#FFFFFF"
            verticalAlignment: Text.AlignVCenter
            text: "minutes"
          }
          onValueModified: {
            qmlSystem.resetPass()
            var storedValue = storePassBox.value.toString()
            storedValue = (+storedValue >= 0) ? storedValue : "0"
            qmlSystem.setConfigValue("storePass", storedValue)
            storePassRect.timer.stop()
            storePassRect.timer.start()
          }
        }
      }

      Text {
        id: developerText
        width: settingsCol.width * 0.75
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Enable loading DApps from a local folder (FOR EXPERTS/DEVELOPERS ONLY!)"

        AVMECheckbox {
          id: developerCheck
          checked: false
          width: settingsCol.width * 0.25
          anchors {
            verticalCenter: parent.verticalCenter
            left: parent.right
          }
          text: "Developer Mode"
          onToggled: qmlSystem.setConfigValue("devMode", (checked) ? "true" : "false")
        }
      }

      Text {
        id: customAPIText
        width: settingsCol.width
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Set custom endpoints for: (blank = default)"
      }

      Text {
        id: customWalletAPIText
        width: settingsCol.width * 0.1
        height: customWalletAPIHost.height
        verticalAlignment: Text.AlignVCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Wallet API"

        AVMEInput {
          id: customWalletAPIHost
          width: settingsCol.width * 0.2
          anchors.left: parent.right
          anchors.leftMargin: 10
          label: "Host"
          placeholder: "e.g. api.avme.io"
        }
        AVMEInput {
          id: customWalletAPIPort
          width: settingsCol.width * 0.1
          anchors.left: customWalletAPIHost.right
          anchors.leftMargin: 10
          label: "Port"
          placeholder: "e.g. 443"
          validator: RegExpValidator { regExp: /[0-9]{0,}/ }
        }
        AVMEInput {
          id: customWalletAPITarget
          width: settingsCol.width * 0.2
          anchors.left: customWalletAPIPort.right
          anchors.leftMargin: 10
          label: "Target"
          placeholder: "e.g. /"
        }
        AVMEButton {
          id: customWalletAPISaveBtn
          width: settingsCol.width * 0.1
          anchors.left: customWalletAPITarget.right
          anchors.leftMargin: 10
          text: "Save"
          onClicked: {
            var json = {
              host: customWalletAPIHost.text,
              port: customWalletAPIPort.text,
              target: customWalletAPITarget.text
            }
            qmlSystem.setConfigValue("customWalletAPI", JSON.stringify(json))
          }
        }
      }

      Text {
        id: customWebsocketAPIText
        width: settingsCol.width * 0.1
        height: customWebsocketAPIHost.height
        verticalAlignment: Text.AlignVCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Websocket"

        AVMEInput {
          id: customWebsocketAPIHost
          width: settingsCol.width * 0.2
          anchors.left: parent.right
          anchors.leftMargin: 10
          label: "Host"
          placeholder: "e.g. api.avax.network"
        }
        AVMEInput {
          id: customWebsocketAPIPort
          width: settingsCol.width * 0.1
          anchors.left: customWebsocketAPIHost.right
          anchors.leftMargin: 10
          label: "Port"
          placeholder: "e.g. 443"
          validator: RegExpValidator { regExp: /[0-9]{0,}/ }
        }
        AVMEInput {
          id: customWebsocketAPITarget
          width: settingsCol.width * 0.2
          anchors.left: customWebsocketAPIPort.right
          anchors.leftMargin: 10
          label: "Target"
          placeholder: "e.g. /ext/bc/C/rpc"
        }
        AVMEInput {
          id: customWebsocketAPIPluginPort
          width: settingsCol.width * 0.1
          anchors.left: customWebsocketAPITarget.right
          anchors.leftMargin: 10
          label: "Plugin Port"
          placeholder: "e.g. 4812"
          validator: RegExpValidator { regExp: /[0-9]{0,}/ }
        }
        AVMEButton {
          id: customWebsocketAPISaveBtn
          width: settingsCol.width * 0.2
          anchors.left: customWebsocketAPIPluginPort.right
          anchors.leftMargin: 10
          text: "Save & Reload Server"
          onClicked: {
            var json = {
              host: customWebsocketAPIHost.text,
              port: customWebsocketAPIPort.text,
              target: customWebsocketAPITarget.text,
              pluginPort: customWebsocketAPIPluginPort.text
            }
            qmlSystem.setConfigValue("customWebsocketAPI", JSON.stringify(json))
            // TODO: reload server here
          }
        }
      }
    }
  }
}

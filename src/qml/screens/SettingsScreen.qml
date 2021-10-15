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
      var walletAPIStr = qmlSystem.getConfigValue("walletAPI")
      if (walletAPIStr != "NotFound: ") {
        var walletAPIJson = JSON.parse(walletAPIStr)
        walletAPIHost.text = walletAPIJson["host"]
        walletAPIPort.text = walletAPIJson["port"]
        walletAPITarget.text = walletAPIJson["target"]
      }

      // Custom Websocket API inputs
      var websocketAPIStr = qmlSystem.getConfigValue("websocketAPI")
      if (websocketAPIStr != "NotFound: ") {
        var websocketAPIJson = JSON.parse(websocketAPIStr)
        websocketAPIHost.text = websocketAPIJson["host"]
        websocketAPIPort.text = websocketAPIJson["port"]
        websocketAPITarget.text = websocketAPIJson["target"]
        websocketAPIPluginPort.text = websocketAPIJson["pluginPort"]
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
        id: walletAPIText
        width: settingsCol.width * 0.1
        height: walletAPIHost.height
        verticalAlignment: Text.AlignVCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Wallet API"

        AVMEInput {
          id: walletAPIHost
          width: settingsCol.width * 0.2
          anchors.left: parent.right
          anchors.leftMargin: 10
          label: "Host"
          placeholder: "e.g. api.avme.io"
        }
        AVMEInput {
          id: walletAPIPort
          width: settingsCol.width * 0.1
          anchors.left: walletAPIHost.right
          anchors.leftMargin: 10
          label: "Port"
          placeholder: "e.g. 443"
          validator: RegExpValidator { regExp: /[0-9]{0,}/ }
        }
        AVMEInput {
          id: walletAPITarget
          width: settingsCol.width * 0.2
          anchors.left: walletAPIPort.right
          anchors.leftMargin: 10
          label: "Target"
          placeholder: "e.g. /"
        }
        AVMEButton {
          id: walletAPISaveBtn
          width: settingsCol.width * 0.1
          anchors.left: walletAPITarget.right
          anchors.leftMargin: 10
          text: "Save"
          onClicked: {
            var host = walletAPIHost.text
            var port = walletAPIPort.text
            var target = walletAPITarget.text
            apiCheckPopup.open()
            qmlSystem.testAPI(host, port, target, "walletAPI")
          }
        }
      }

      Text {
        id: websocketAPIText
        width: settingsCol.width * 0.1
        height: websocketAPIHost.height
        verticalAlignment: Text.AlignVCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Websocket"

        AVMEInput {
          id: websocketAPIHost
          width: settingsCol.width * 0.2
          anchors.left: parent.right
          anchors.leftMargin: 10
          label: "Host"
          placeholder: "e.g. api.avax.network"
        }
        AVMEInput {
          id: websocketAPIPort
          width: settingsCol.width * 0.1
          anchors.left: websocketAPIHost.right
          anchors.leftMargin: 10
          label: "Port"
          placeholder: "e.g. 443"
          validator: RegExpValidator { regExp: /[0-9]{0,}/ }
        }
        AVMEInput {
          id: websocketAPITarget
          width: settingsCol.width * 0.2
          anchors.left: websocketAPIPort.right
          anchors.leftMargin: 10
          label: "Target"
          placeholder: "e.g. /ext/bc/C/rpc"
        }
        AVMEInput {
          id: websocketAPIPluginPort
          width: settingsCol.width * 0.1
          anchors.left: websocketAPITarget.right
          anchors.leftMargin: 10
          label: "Plugin Port"
          placeholder: "e.g. 4812"
          validator: RegExpValidator { regExp: /[0-9]{0,}/ }
        }
        AVMEButton {
          id: websocketAPISaveBtn
          width: settingsCol.width * 0.2
          anchors.left: websocketAPIPluginPort.right
          anchors.leftMargin: 10
          text: "Save & Reload Server"
          onClicked: {
            var host = websocketAPIHost.text
            var port = websocketAPIPort.text
            var target = websocketAPITarget.text
            var pluginPort = websocketAPIPluginPort.text
            apiCheckPopup.open()
            qmlSystem.testAPI(host, port, target, "websocketAPI")
          }
        }
      }
    }
  }

  AVMEPopup {
    id: apiCheckPopup
    widthPct: 0.4
    heightPct: 0.5
    onAboutToShow: {
      apiCheckImg.imageSource = "qrc:/img/icons/loading.png"
      apiCheckImgRotate.start()
      apiCheckText.text = "Testing connection to the API..."
      apiCheckCloseBtn.visible = false
    }
    Connections {
      target: qmlSystem
      function onApiReturnedSuccessfully(success, type) {
        apiCheckImgRotate.restart()
        apiCheckImgRotate.stop()
        apiCheckCloseBtn.visible = true
        apiCheckImg.imageSource = "qrc:/img/" + ((success) ? "ok.png" : "no.png")
        apiCheckText.text = (success)
          ? "Connection successful!<br>API is working."
          : "Connection failed.<br>Please check if API details are correct.<br> Errors are logged in your debug.log"
        if (success) {
          if (type == "walletAPI") {
            qmlSystem.setWalletAPI(walletAPIHost.text, walletAPIPort.text, walletAPITarget.text)
          } 
          if (type == "websocketAPI") {
            qmlSystem.setWebSocketAPI(websocketAPIHost.text, websocketAPIPort.text, websocketAPITarget.text, websocketAPIPluginPort.text)
          }
        }
      }
    }

    AVMEAsyncImage {
      id: apiCheckImg
      width: 128
      height: 128
      anchors {
        horizontalCenter: parent.horizontalCenter
        top: parent.top
        topMargin: 30
      }
      loading: false
      RotationAnimator {
        id: apiCheckImgRotate
        target: apiCheckImg
        from: 0
        to: 360
        duration: 1000
        loops: Animation.Infinite
        easing.type: Easing.InOutQuad
        running: false
      }
    }

    Text {
      id: apiCheckText
      anchors {
        horizontalCenter: parent.horizontalCenter
        top: apiCheckImg.bottom
        topMargin: 30
      }
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pointSize: 12.0
    }

    AVMEButton {
      id: apiCheckCloseBtn
      width: parent.width * 0.25
      anchors {
        horizontalCenter: parent.horizontalCenter
        bottom: parent.bottom
        bottomMargin: 30
      }
      text: "Close"
      onClicked: apiCheckPopup.close()
    }
  }
}

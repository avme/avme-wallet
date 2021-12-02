/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Screen for showing general settings
Item {
  id: settingsScreen

  // Get stored configs
  function reloadConfigs() {
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

  AVMEPanel {
    id: settingsPanel
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
    title: "Advanced Settings"

    Component.onCompleted: reloadConfigs()

    Column {
      id: settingsCol
      anchors {
        top: parent.top
        bottom: exportBtnRow.top
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

        AVMEAsyncImage {
          id: storePassAlertImg
          width: 32
          height: 32
          loading: false
          anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
          }
          imageSource: "qrc:/img/icons/alert-f.png"
          MouseArea {
            id: storePassAlertImgMousearea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
              storePassAlertImg.imageSource = "qrc:/img/icons/alert-fSelect.png"
              storePassAlertImgTooltip.visible = true
            }
            onExited: {
              storePassAlertImg.imageSource = "qrc:/img/icons/alert-f.png"
              storePassAlertImgTooltip.visible = false
            }
          }
          ToolTip {
            id: storePassAlertImgTooltip
            background: Rectangle { color: "#1C2029" }
            contentItem: Text {
              font.pixelSize: 12.0
              color: "#FFFFFF"
              text: "Keep in mind your password will be unprotected if you use this!"
            }
          }
        }

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
        width: settingsCol.width * 0.75
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Set custom endpoints for: (blank = default)"

        AVMEButton {
          id: apiSaveBtn
          width: settingsCol.width * 0.25
          anchors {
            verticalCenter: parent.verticalCenter
            left: parent.right
          }
          text: "Save & Reload APIs"
          onClicked: apiCheckPopup.open()
        }
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
      }
    }

    Row {
      id: exportBtnRow
      anchors {
        bottom: parent.bottom
        bottomMargin: 20
        horizontalCenter: parent.horizontalCenter
      }
      spacing: 10

      AVMEButton {
        id: importJSONBtn
        width: settingsPanel.width * 0.25
        text: "Import Settings from JSON"
        onClicked: importDialog.visible = true
      }
      AVMEButton {
        id: exportJSONBtn
        width: settingsPanel.width * 0.25
        text: "Export Settings to JSON"
        onClicked: exportDialog.visible = true
      }
    }
  }

  // Dialogs for importing/exporting configs
  FileDialog {
    id: importDialog
    title: "Choose a file to import"
    onAccepted: {
      configInfoPopup.isImporting = true
      configInfoPopup.success = qmlSystem.importConfigs(
        qmlSystem.cleanPath(importDialog.file.toString())
      )
      if (configInfoPopup.success) { reloadConfigs() }
      configInfoPopup.open()
    }
  }
  FolderDialog {
    id: exportDialog
    title: "Choose a folder to export"
    onAccepted: {
      configInfoPopup.isImporting = false
      configInfoPopup.success = qmlSystem.exportConfigs(
        qmlSystem.cleanPath(exportDialog.folder.toString() + "/configs.json")
      )
      configInfoPopup.open()
    }
  }

  // Info popup for import/export results
  AVMEPopupInfo {
    id: configInfoPopup
    property bool success
    property bool isImporting
    icon: (success) ? "qrc:/img/ok.png" : "qrc:/img/no.png"
    info: (success)
    ? ("Settings successfully " + (isImporting ? "imported" : "exported"))
    : ("Failed to " + (isImporting ? "import" : "export") + " settings, please try again.")
    onAboutToHide: { if (success) apiCheckPopup.open() }
  }

  // Popup for checking the API
  AVMEPopup {
    id: apiCheckPopup
    property bool walletChecked: false
    property bool websocketChecked: false
    property bool walletOK: false
    property bool websocketOK: false
    widthPct: 0.4
    heightPct: 0.55
    onAboutToShow: {
      walletApiCheckImg.imageSource = "qrc:/img/icons/loading.png"
      walletApiCheckImgRotate.start()
      websocketApiCheckImg.imageSource = "qrc:/img/icons/loading.png"
      websocketApiCheckImgRotate.start()
      apiCheckText.text = "Testing connections to the API..."
      apiCheckCloseBtn.visible = false
      walletChecked = websocketChecked = walletOK = websocketOK = false
      checkAPIs()
    }

    function checkAPIs() {
      qmlSystem.testAPI(
        walletAPIHost.text, walletAPIPort.text,
        walletAPITarget.text, "walletAPI"
      )
      qmlSystem.testAPI(
        websocketAPIHost.text, websocketAPIPort.text,
        websocketAPITarget.text, "websocketAPI"
      )
    }

    Connections {
      target: qmlSystem
      function onApiReturnedSuccessfully(success, type) {
        if (type == "walletAPI") {
          apiCheckPopup.walletChecked = true
          walletApiCheckImgRotate.restart()
          walletApiCheckImgRotate.stop()
          walletApiCheckImg.imageSource = "qrc:/img/"
            + ((success) ? "ok.png" : "no.png")
          if (success) {
            apiCheckPopup.walletOK = true
            qmlSystem.setWalletAPI(
              walletAPIHost.text, walletAPIPort.text, walletAPITarget.text
            )
          }
        } else if (type == "websocketAPI") {
          apiCheckPopup.websocketChecked = true
          websocketApiCheckImgRotate.restart()
          websocketApiCheckImgRotate.stop()
          websocketApiCheckImg.imageSource = "qrc:/img/"
            + ((success) ? "ok.png" : "no.png")
          if (success) {
            apiCheckPopup.websocketOK = true
            qmlSystem.setWebSocketAPI(
              websocketAPIHost.text, websocketAPIPort.text,
              websocketAPITarget.text, websocketAPIPluginPort.text
            )
          }
        }
        if (apiCheckPopup.walletChecked && apiCheckPopup.websocketChecked) {
          apiCheckCloseBtn.visible = true
          apiCheckText.text = (apiCheckPopup.walletOK && apiCheckPopup.websocketOK)
          ? "Connections successful!<br>APIs are working."
          : "One or more connections failed.<br>"
          + "Please check if API details are correct.<br>"
          + "Errors are logged in debug.log."
        }
      }
    }

    // Enter/Numpad enter key override
    Item {
      focus: true
      Keys.onPressed: {
        if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
          if (apiCheckCloseBtn.visible) apiCheckPopup.close()
        }
      }
    }

    Row {
      id: apiCheckImgRow
      anchors {
        top: parent.top
        topMargin: 20
        horizontalCenter: parent.horizontalCenter
      }
      spacing: 50

      Rectangle {
        id: walletApiRect
        width: 128
        height: 128
        radius: 128
        color: {
          if (apiCheckPopup.walletChecked && apiCheckPopup.walletOK) {
            color: "#0B5418"
          } else if (apiCheckPopup.walletChecked && !apiCheckPopup.walletOk) {
            color: "#4F1018"
          } else {
            color: "#0B1018"
          }
        }
        AVMEAsyncImage {
          id: walletApiCheckImg
          width: 64
          height: 64
          loading: false
          anchors.centerIn: parent
          RotationAnimator {
            id: walletApiCheckImgRotate
            target: walletApiCheckImg
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
            easing.type: Easing.InOutQuad
            running: false
          }
        }
        Text {
          id: walletApiCheckText
          anchors {
            top: parent.bottom
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
          }
          horizontalAlignment: Text.AlignHCenter
          color: "#FFFFFF"
          font.pointSize: 12.0
          text: "Wallet API"
        }
      }

      Rectangle {
        id: websocketApiRect
        width: 128
        height: 128
        radius: 128
        color: {
          if (apiCheckPopup.websocketChecked && apiCheckPopup.websocketOK) {
            color: "#0B5418"
          } else if (apiCheckPopup.websocketChecked && !apiCheckPopup.websocketOk) {
            color: "#4F1018"
          } else {
            color: "#0B1018"
          }
        }
        AVMEAsyncImage {
          id: websocketApiCheckImg
          width: 64
          height: 64
          loading: false
          anchors.centerIn: parent
          RotationAnimator {
            id: websocketApiCheckImgRotate
            target: websocketApiCheckImg
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
            easing.type: Easing.InOutQuad
            running: false
          }
        }
        Text {
          id: websocketApiCheckText
          anchors {
            top: parent.bottom
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
          }
          horizontalAlignment: Text.AlignHCenter
          color: "#FFFFFF"
          font.pointSize: 12.0
          text: "Websocket API"
        }
      }
    }

    Text {
      id: apiCheckText
      anchors {
        horizontalCenter: parent.horizontalCenter
        top: apiCheckImgRow.bottom
        topMargin: 60
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
        bottomMargin: 20
      }
      text: "Close"
      onClicked: apiCheckPopup.close()
    }
  }
}

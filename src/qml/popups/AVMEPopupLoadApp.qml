/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Popup for loading a local DApp (for developers)
AVMEPopup {
  id: loadAppPopup
  property alias folder: loadAppInput.text
  property alias loadBtn: btnLoad
  property bool appExists

  onAboutToShow: {
    loadAppInput.text = ""
    appExists = false
  }
  onAboutToHide: {
    loadAppInput.text = ""
    appExists = false
  }

  Column {
    id: items
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 20

    // Enter/Numpad enter key override
    Keys.onPressed: {
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        if (btnLoad.enabled) { loadLocalApp() }
      }
    }

    Text {
      id: info
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Enter the path to your DApp's folder."
    }

    Row {
      id: loadAppRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEInput {
        id: loadAppInput
        width: (items.width * 0.9) - (loadAppDialogBtn.width + parent.spacing)
        readOnly: true
        label: "DApp folder"
        placeholder: "Your DApp's folder"
      }
      AVMEButton {
        id: loadAppDialogBtn
        width: (items.width * 0.1)
        height: loadAppInput.height
        text: ""
        onClicked: loadAppDialog.visible = true
        AVMEAsyncImage {
          anchors.fill: parent
          anchors.margins: 5
          loading: false
          imageSource: "qrc:/img/icons/folder.png"
        }
      }
      FolderDialog {
        id: loadAppDialog
        title: "Choose your DApp folder"
        onAccepted: {
          loadAppInput.text = qmlSystem.cleanPath(loadAppDialog.folder)
          appExists = qmlSystem.checkForApp(loadAppInput.text)
        }
      }
    }

    AVMEButton {
      id: btnLoad
      width: (items.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (loadAppInput.text != "" && appExists)
      text: (appExists) ? "Load DApp" : "DApp not found"
    }

    AVMEButton {
      id: btnClose
      width: (items.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Back"
      onClicked: loadAppPopup.close()
    }
  }
}

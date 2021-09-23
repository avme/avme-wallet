/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Screen for managing contacts.
Item {
  id: contactsScreen

  Component.onCompleted: reloadContacts()

  function reloadContacts() {
    contactsModel.clear()
    var contacts = qmlSystem.listWalletContacts()
    for (var i = 0; i < contacts.length; i++) {
      contactsModel.append(contacts[i])
    }
  }

  // The list itself
  Rectangle {
    id: listRect
    width: (parent.width * 0.55) - (anchors.margins * 2)
    height: parent.height
    anchors {
      top: parent.top
      bottom: parent.bottom
      left: parent.left
      margins: 10
    }
    radius: 5
    color: "#4458A0C9"

    // TODO: sort by address
    AVMEContactsList {
      id: contactsList
      anchors.fill: parent
      model: ListModel { id: contactsModel }
    }
  }

  // Contact management panel
  AVMEPanel {
    id: contactsPanel
    width: (parent.width * 0.45) - (anchors.margins * 2)
    height: parent.height
    anchors {
      top: parent.top
      bottom: parent.bottom
      right: parent.right
      margins: 10
    }
    title: "Contact Management"

    Column {
      id: contactsColumn
      anchors {
        top: parent.top
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        topMargin: 80
        bottomMargin: 20
        leftMargin: 40
        rightMargin: 40
      }
      spacing: 20

      Text {
        id: contactAddText
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Add/edit a contact with the following details:"
      }

      AVMEInput {
        id: addAddressInput
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        validator: RegExpValidator { regExp: /0x[0-9a-fA-F]{40}/ }
        label: "Address"
        placeholder: "e.g. 0x123456789ABCDEF..."
      }

      AVMEInput {
        id: addNameInput
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        label: "Name"
        placeholder: "Your contact's name"
      }

      AVMEButton {
        id: addBtn
        width: parent.width
        text: "Save Contact"
        enabled: (addAddressInput.acceptableInput && addNameInput.text != "")
        onClicked: {
          qmlSystem.addContact(addAddressInput.text, addNameInput.text)
          addAddressInput.text = addNameInput.text = ""
          reloadContacts()
        }
      }

      AVMEButton {
        id: copyBtn
        width: parent.width
        text: "Edit Selected Contact"
        enabled: (contactsList.currentItem != null)
        onClicked: {
          addAddressInput.text = contactsList.currentItem.itemAddress
          addNameInput.text = contactsList.currentItem.itemName
        }
      }

      AVMEButton {
        id: removeBtn
        width: parent.width
        text: "Remove Selected Contact"
        enabled: (contactsList.currentItem != null)
        onClicked: {
          qmlSystem.removeContact(contactsList.currentItem.itemAddress)
          reloadContacts()
        }
      }

      Rectangle {
        id: separator1
        color: "#FFFFFF"
        width: (parent.width * 1.1)
        height: 1
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Text {
        id: contactImportExportText
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "You can import or export your contacts<br>from/to a JSON file:"
      }

      AVMEButton {
        id: importBtn
        width: parent.width
        text: "Import Contacts"
        onClicked: importDialog.visible = true
      }

      AVMEButton {
        id: exportBtn
        width: parent.width
        text: "Export Contacts"
        enabled: (contactsList.count > 0)
        onClicked: exportDialog.visible = true
      }
    }
  }

  // Dialogs for importing/exporting contacts
  FileDialog {
    id: importDialog
    title: "Choose a file to import"
    onAccepted: {
      contactInfoPopup.isImporting = true
      contactInfoPopup.result = qmlSystem.importContacts(
        qmlSystem.cleanPath(importDialog.file.toString())
      )
      contactInfoPopup.open()
    }
  }
  FolderDialog {
    id: exportDialog
    title: "Choose a folder to export"
    onAccepted: {
      contactInfoPopup.isImporting = false
      contactInfoPopup.result = qmlSystem.exportContacts(
        qmlSystem.cleanPath(exportDialog.folder.toString() + "/contacts.json")
      )
      contactInfoPopup.open()
    }
  }

  // Info popup for import/export results
  AVMEPopupInfo {
    id: contactInfoPopup
    property int result
    property bool isImporting
    icon: (result > 0) ? "qrc:/img/ok.png" : "qrc:/img/no.png"
    info: (result > 0)
    ? (result + " contacts " + (isImporting ? "imported" : "exported"))
    : ("Failed to " + (isImporting ? "import" : "export") + " contacts, please try again.")
    onAboutToHide: reloadContacts()
  }
}

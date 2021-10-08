/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

/**
 * Popup for choosing a contact.
 */
AVMEPopup {
  id: chooseContactPopup
  widthPct: 0.5
  heightPct: 1.0
  property var contacts: null
  property var chosenContact: ""

  onAboutToShow: {
    contacts = qmlSystem.listWalletContacts()
    refreshList("")
    filterInput.text = chosenContact = ""
    filterInput.forceActiveFocus()
  }
  onAboutToHide: {
    contactsModel.clear()
    contacts = null
    filterInput.text = ""
    if (chosenContact != "") sendPanel.toInput = chosenContact
  }

  function refreshList(filter) {
    contactsModel.clear()
    for (var i = 0; i < contacts.length; i++) {
      var nameMatch = contacts[i]["name"].toUpperCase().includes(filter.toUpperCase())
      if (filter == "" || nameMatch) {
        contactsModel.append(contacts[i])
      }
    }
    contactsModel.sortByAddress()
    contactsList.currentIndex = -1
  }

  Column {
    id: items
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 20

    // Enter/Numpad enter key override
    Keys.onPressed: {
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        if (btnChoose.enabled) {
          chosenContact = contactsList.currentItem.itemAddress
          chooseContactPopup.close()
        }
      }
    }

    Text {
      id: infoLabel
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Choose the contact you want to use."
    }

    Rectangle {
      id: listRect
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width * 0.9)
      height: (parent.height * 0.65)
      radius: 5
      color: "#16141F"

      Column {
        anchors.fill: parent
        spacing: 0
        AVMEContactsPopupList {
          id: contactsList
          width: parent.width
          height: parent.height
          anchors.horizontalCenter: parent.horizontalCenter
          model: ListModel {
            id: contactsModel
            function sortByAddress() {
              for (var i = 0; i < count; i++) {
                for (var j = 0; j < i; j++) {
                  if (get(i).address < get(j).address) { move(i, j, 1) }
                }
              }
            }
          }
        }
      }
    }

    AVMEInput {
      id: filterInput
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      label: "Filter by name"
      onTextEdited: chooseContactPopup.refreshList(filterInput.text)
    }

    AVMEButton {
      id: btnChoose
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (contactsList.currentIndex > -1)
      text: "Select this contact"
      onClicked: {
        chosenContact = contactsList.currentItem.itemAddress
        chooseContactPopup.close()
      }
    }

    AVMEButton {
      id: btnClose
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Close"
      onClicked: chooseContactPopup.close()
    }
  }
}

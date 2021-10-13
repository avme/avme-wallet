/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Popup for showing a list of permitted websites in the websocket server.
AVMEPopup {
  id: websitePermissionPopup

  onAboutToShow: refreshPermissionList()
  onAboutToHide: websitePermissionListModel.clear()

  function refreshPermissionList() {
    var permissionList = JSON.parse(qmlSystem.getWebsitePermissionList())
    websitePermissionListModel.clear()
    for (var websitepermission in permissionList) {
      var permission = ({})
      permission["website"] = websitepermission
      permission["permission"] = permissionList[websitepermission]
      websitePermissionListModel.append(permission)
    }
  }

  Column {
    id: websitePermissionColumn
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 20

    Text {
      id: permissionListHeader
      anchors.horizontalCenter: parent.horizontalCenter
      color: "white"
      font.pixelSize: 14.0
      text: "List of permitted websites"
    }

    Rectangle {
      id: listRect
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width * 0.9)
      height: (parent.height * 0.7)
      radius: 5
      color: "#16141F"
      ListView {
        id: websitePermissionList
        anchors.fill: parent
        spacing: parent.height * 0.01
        boundsBehavior: Flickable.StopAtBounds
        focus: true
        clip: true
        model: ListModel { id: websitePermissionListModel }

        delegate: Component {
          id: websitePermissionDelegate
          Item {
            readonly property string itemWebsite: website
            readonly property bool itemPermission: permission
            id: websitePermissionDelegateItem
            width: websitePermissionList.width
            height: 50
            Rectangle {
              id: delegateRectangle
              anchors.verticalCenter: parent.verticalCenter
              anchors.horizontalCenter: parent.horizontalCenter
              color: "#2E2C3D"
              radius: 5
              height: parent.height
              width: parent.width * 0.9
              Text {
                id: delegateWebsite
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.01
                color: "white"
                font.pixelSize: 14.0
                padding: 5
                elide: Text.ElideRight
                text: itemWebsite
              }
              Text {
                id: delegatePermission
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: parent.width * 0.01
                color: "white"
                font.pixelSize: 14.0
                padding: 5
                elide: Text.ElideRight
                text: itemPermission ? "Allowed" : "Blocked"
              }
            }
          }
        }
      }
    }

    AVMEButton {
      id: btnClearPermission
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Clear Permission List"
      onClicked: {
        qmlSystem.clearWebsitePermissionList()
        refreshPermissionList()
      }
    }

    AVMEButton {
      id: btnClose
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Close"
      onClicked: websitePermissionPopup.close()
    }
  }
}

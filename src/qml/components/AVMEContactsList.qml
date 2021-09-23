/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Custom list for a Wallet's contacts.
 */
ListView {
  id: contactsList
  property color listHighlightColor: "#887AC1EB"
  property color listBgColor: "#58A0C9"
  property color listHoverColor: "#7AC1DB"

  highlight: Rectangle { color: listHighlightColor; radius: 5 }
  highlightMoveDuration: 0
  highlightMoveVelocity: 100000
  highlightResizeDuration: 0
  highlightResizeVelocity: 100000
  focus: true
  clip: true
  boundsBehavior: Flickable.StopAtBounds

  Component.onCompleted: forceActiveFocus()

  // Header (top bar)
  header: Rectangle {
    id: listHeader
    width: parent.width
    height: 30
    radius: 5
    z: 2
    anchors.horizontalCenter: parent.horizontalCenter
    color: listBgColor

    Text {
      id: headerAddress
      anchors.verticalCenter: parent.verticalCenter
      width: (parent.width * 0.6)
      color: "white"
      font.pixelSize: 14.0
      padding: 5
      text: "Address"
    }
    Text {
      id: headerName
      anchors.verticalCenter: parent.verticalCenter
      width: (parent.width * 0.4)
      x: headerAddress.x + headerAddress.width
      color: "white"
      font.pixelSize: 14.0
      padding: 5
      text: "Name"
    }
  }
  headerPositioning: ListView.OverlayHeader // Prevent header scrolling along

  // Delegate (structure for each item in the list)
  delegate: Component {
    id: listDelegate
    Item {
      id: listItem
      readonly property string itemAddress: address
      readonly property string itemName: name
      width: parent.width
      height: 30

      Text {
        id: delegateAddress
        anchors.verticalCenter: parent.verticalCenter
        width: (parent.width * 0.6)
        color: "white"
        font.pixelSize: 14.0
        padding: 5
        elide: Text.ElideRight
        text: itemAddress
      }
      Text {
        id: delegateName
        anchors.verticalCenter: parent.verticalCenter
        width: (parent.width * 0.4)
        x: delegateAddress.x + delegateAddress.width
        color: "white"
        font.pixelSize: 14.0
        padding: 5
        elide: Text.ElideRight
        text: itemName
      }
      MouseArea {
        id: delegateMouseArea
        anchors.fill: parent
        onClicked: {
          contactsList.currentIndex = index
          contactsList.forceActiveFocus()
        }
      }
    }
  }
}

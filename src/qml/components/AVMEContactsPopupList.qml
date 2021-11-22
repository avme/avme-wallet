/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * List of contacts to be selected.
 */
ListView {
  id: contactSelectList
  property color listHighlightColor: "#9400F6"
  property color listBgColor: "#16141F"
  property color listHoverColor: "#2E2C3D"

  implicitWidth: 500
  implicitHeight: 500
  highlightMoveDuration: 0
  highlightMoveVelocity: 100000
  highlightResizeDuration: 0
  highlightResizeVelocity: 100000
  spacing: parent.height * 0.015
  topMargin: 10
  bottomMargin: 10
  focus: true
  clip: true
  boundsBehavior: Flickable.StopAtBounds

  ScrollBar.vertical: ScrollBar {
    id: scrollbar
    active: true
    orientation: Qt.Vertical
    size: contactSelectList.height / contactSelectList.contentHeight
    policy: ScrollBar.AlwaysOn
    anchors {
      top: parent.top
      right: parent.right
      bottom: parent.bottom
    }
  }

  delegate: Component {
    id: contactSelectDelegate
    Item {
      id: contactSelectItem
      readonly property string itemAddress: address
      readonly property string itemName: name
      width: contactSelectList.width
      height: 40

      Rectangle {
        id: delegateRectangle
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: (contactSelectList.currentIndex == index) ? "#9400F6" : "#2E2C3D"
        radius: 5
        height: parent.height
        width: parent.width * 0.9
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
          x: delegateAddress.width
          color: "white"
          font.pixelSize: 14.0
          padding: 5
          elide: Text.ElideRight
          text: itemName
        }
      }
      MouseArea {
        id: delegateMouseArea
        anchors.fill: parent
        onClicked: {
          contactSelectList.currentIndex = index
          contactSelectList.forceActiveFocus()
        }
      }
    }
  }
}

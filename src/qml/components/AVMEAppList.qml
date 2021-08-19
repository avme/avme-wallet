/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

// ListView for DApps.
ListView {
  id: appList
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

  delegate: Component {
    id: listDelegate
    Item {
      id: listItem
      readonly property string itemDevIcon: devIcon
      readonly property string itemIcon: icon
      readonly property string itemName: name
      readonly property string itemDescription: description
      readonly property string itemCreator: creator
      readonly property int itemMajor: major
      readonly property int itemMinor: minor
      readonly property int itemPatch: patch
      width: appList.width
      height: 50

      Rectangle {
        id: delegateRectangle
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: (appList.currentIndex == index) ? "#9400F6" : "#2E2C3D"
        radius: 5
        height: parent.height
        width: parent.width * 0.9

        Image {
          id: delegateIcon
          anchors.verticalCenter: parent.verticalCenter
          width: parent.height * 0.9
          height: width
          antialiasing: true
          smooth: true
          fillMode: Image.PreserveAspectFit
          source: itemIcon
        }
        Text {
          id: delegateCreator
          anchors.verticalCenter: parent.verticalCenter
          width: (parent.width * 0.4)
          x: delegateIcon.width
          color: "white"
          font.pixelSize: 14.0
          padding: 5
          elide: Text.ElideRight
          text: itemCreator
        }
        Text {
          id: delegateName
          anchors.verticalCenter: parent.verticalCenter
          anchors.right: parent.right
          anchors.rightMargin: parent.width * 0.05
          width: parent.width * 0.4
          color: "white"
          font.pixelSize: 14.0
          elide: Text.ElideRight
          text: itemName
        }
      }
      MouseArea {
        id: delegateMouseArea
        anchors.fill: parent
        onClicked: appList.currentIndex = index
      }
    }
  }
}

/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * List of DApps to be selected.
 */
ListView {
  id: appSelectList
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
    id: appSelectDelegate
    Item {
      id: appSelectItem
      readonly property string itemChainId: chainId
      readonly property string itemFolder: folder
      readonly property string itemName: name
      readonly property int itemMajor: major
      readonly property int itemMinor: minor
      readonly property int itemPatch: patch
      width: appSelectList.width
      height: 50

      Rectangle {
        id: delegateRectangle
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: (appSelectList.currentIndex == index) ? "#9400F6" : "#2E2C3D"
        radius: 5
        height: parent.height
        width: parent.width * 0.9
        AVMEAsyncImage {
          id: delegateImage
          anchors.verticalCenter: parent.verticalCenter
          width: parent.height * 0.9
          height: width
          imageSource: "qrc:/img/unknown_token.png" // TODO
        }
        Text {
          id: delegateName
          anchors.verticalCenter: parent.verticalCenter
          width: (parent.width * 0.7)
          x: delegateImage.width
          color: "white"
          font.pixelSize: 14.0
          padding: 5
          elide: Text.ElideRight
          text: itemName
        }
        Text {
          id: delegateVersion
          anchors.verticalCenter: parent.verticalCenter
          width: (parent.width * 0.2)
          x: delegateImage.width + delegateName.width
          color: "white"
          font.pixelSize: 14.0
          padding: 5
          elide: Text.ElideRight
          text: itemMajor + "." + itemMinor + "." + itemPatch
        }
      }
      MouseArea {
        id: delegateMouseArea
        anchors.fill: parent
        onClicked: appSelectList.currentIndex = index
      }
    }
  }
}

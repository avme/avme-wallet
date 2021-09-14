/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

// GridView for DApps.
GridView {
  id: appGrid
  property color listHighlightColor: "#887AC1EB"
  property color listHoveredColor: "#447AC1EB"

  highlight: Rectangle { color: listHighlightColor; radius: 5 }
  highlightMoveDuration: 0
  focus: true
  clip: true
  boundsBehavior: Flickable.StopAtBounds
  cellWidth: 140
  cellHeight: 140

  Component.onCompleted: forceActiveFocus()

  delegate: Component {
    id: gridDelegate
    Item {
      id: gridItem
      readonly property string itemChainId: chainId
      readonly property string itemFolder: folder
      readonly property string itemName: name
      readonly property int itemMajor: major
      readonly property int itemMinor: minor
      readonly property int itemPatch: patch
      width: appGrid.cellWidth - 10
      height: appGrid.cellHeight - 10
      Rectangle { id: gridItemBg; anchors.fill: parent; radius: 5; color: "transparent" }

      Column {
        anchors.centerIn: parent
        spacing: 10
        AVMEAsyncImage {
          id: appImage
          width: 64
          height: 64
          anchors.horizontalCenter: parent.horizontalCenter
          imageSource: "https://raw.githubusercontent.com"
          + "/avme/avme-wallet-applications/main/apps"
          + itemFolder + "/icon.png"
          //imageSource: "qrc:/img/unknown_token.png" // TODO
        }
        Text {
          id: appName
          width: gridItem.width * 0.9
          height: gridItem.height - appImage.height - parent.spacing
          anchors.horizontalCenter: parent.horizontalCenter
          color: "#FFFFFF"
          font.pixelSize: 12.0
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          wrapMode: Text.WordWrap
          text: itemName
        }
        // TODO: status (installed, uninstalled, needs update)
      }
      MouseArea {
        id: delegateMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: gridItemBg.color = listHoveredColor
        onExited: gridItemBg.color = "transparent"
        onClicked: appGrid.currentIndex = index
      }
    }
  }
}

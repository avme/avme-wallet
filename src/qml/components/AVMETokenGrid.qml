/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Custom grid view for managing tokens.
 */
GridView {
  id: tokenGrid
  property color listHighlightColor: "#887AC1EB"
  property color listHoveredColor: "#447AC1EB"

  highlight: Rectangle { color: listHighlightColor; radius: 5 }
  highlightMoveDuration: 0
  focus: true
  clip: true
  boundsBehavior: Flickable.StopAtBounds
  cellWidth: 120
  cellHeight: 120

  delegate: Component {
    id: gridDelegate
    Item {
      id: gridItem
      // TODO: image
      readonly property string itemAddress: address
      readonly property string itemSymbol: symbol
      readonly property string itemName: name
      readonly property int itemDecimals: decimals
      readonly property string itemAVAXPairContract: avaxPairContract
      width: tokenGrid.cellWidth - 10
      height: tokenGrid.cellHeight - 10
      Rectangle { id: gridItemBg; anchors.fill: parent; radius: 5; color: "transparent" }
      Column {
        anchors.centerIn: parent
        spacing: 10
        Image {
          id: tokenImage
          width: 64
          height: 64
          anchors.horizontalCenter: parent.horizontalCenter
          antialiasing: true
          smooth: true
          source: ""  // TODO: image
        }
        Text {
          id: tokenSymbol
          anchors.horizontalCenter: parent.horizontalCenter
          color: "#FFFFFF"
          font.pixelSize: 18.0
          text: itemSymbol
        }
      }
      MouseArea {
        id: delegateMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: gridItemBg.color = listHoveredColor
        onExited: gridItemBg.color = "transparent"
        onClicked: tokenGrid.currentIndex = index
      }
    }
  }
}

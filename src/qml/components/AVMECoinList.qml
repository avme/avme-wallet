/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * List of coins to be selected.
 */
ListView {
  id: coinSelectList
  property color listHighlightColor: "#9400F6"
  property color listBgColor: "#16141F"
  property color listHoverColor: "#2E2C3D"
  signal grabFocus()

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
    id: coinSelectDelegate
    Item {
      id: coinSelectItem
      readonly property string itemSymbol: symbol
      readonly property string itemName: name
      readonly property string itemDecimals: decimals
      width: coinSelectList.width
      height: 50

      Rectangle {
        id: delegateRectangle
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: {
          if (coinSelectList.currentIndex == index) {
            color: "#9400F6"
          } else {
            color: "#2E2C3D"
          }
        }
        radius: 5
        height: parent.height
        width: parent.width * 0.9
        Image {
          id: delegateImage
          anchors.verticalCenter: parent.verticalCenter
          width: 48
          height: 48
          antialiasing: true
          smooth: true
          fillMode: Image.PreserveAspectFit
          source: (itemSymbol == "AVAX") ? "qrc:/img/avax_logo.png" : "qrc:/img/unknown_token.png"
        }
        Text {
          id: delegateSymbol
          anchors.verticalCenter: parent.verticalCenter
          width: (parent.width * 0.2)
          x: delegateImage.width
          color: "white"
          font.pixelSize: 14.0
          padding: 5
          elide: Text.ElideRight
          text: itemSymbol
        }
      }
      MouseArea {
        id: delegateMouseArea
        anchors.fill: parent
        onClicked: {
          coinSelectList.currentIndex = index
          grabFocus()
        }
      }
    }
  }
}

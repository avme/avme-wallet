/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * List of ARC20 tokens to be selected.
 */
ListView {
  id: tokenSelectList
  property alias tokenModel: tokenSelectModel
  property color listHighlightColor: "#9400F6"
  property color listBgColor: "#16141F"
  property color listHoverColor: "#2E2C3D"
  property int selectedTokens: 0

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

  signal updatedTokenSelection()

  function updateSelectedTokens() {
    selectedTokens = 0
    for (var i = 0; i < tokenSelectModel.count; i++) {
      if (tokenSelectModel.get(i).selected) {
        selectedTokens++
      }
    }
    updatedTokenSelection()
  }

  ScrollBar.vertical: ScrollBar {
    id: scrollbar
    active: true
    orientation: Qt.Vertical
    size: tokenSelectList.height / tokenSelectList.contentHeight
    policy: ScrollBar.AlwaysOn
    anchors {
      top: parent.top
      right: parent.right
      bottom: parent.bottom
    }
  }

  model: ListModel {
    id: tokenSelectModel
    function selectToken(address) {
      for (var i = 0; i < count; i++) {
        if (get(i).address == address) {
          get(i).selected = !get(i).selected
          tokenSelectList.updateSelectedTokens()
          break
        }
      }
    }
    function allTokensSelected() {
      for (var i = 0; i < count; i++) {
        if (!get(i).selected) return false
      }
      return true
    }
    function selectAllTokens() {
      var check = allTokensSelected()
      for (var i = 0; i < count; i++) {
        get(i).selected = !check
      }
      tokenSelectList.updateSelectedTokens()
    }
    function sortBySymbol() {
      for (var i = 0; i < count; i++) {
        for (var j = 0; j < i; j++) {
          if (get(i).symbol < get(j).symbol) { move(i, j, 1) }
        }
      }
    }
  }

  delegate: Component {
    id: tokenSelectDelegate
    Item {
      id: tokenSelectItem
      readonly property string itemIcon: icon
      readonly property string itemAddress: address
      readonly property string itemSymbol: symbol
      readonly property string itemName: name
      readonly property string itemDecimals: decimals
      readonly property string itemBalance: balance
      property bool itemSelected: selected
      width: tokenSelectList.width
      height: 50

      AVMECheckbox {
        id: delegateCheckbox
        anchors {
          left: parent.left
          leftMargin: 20
          verticalCenter: parent.verticalCenter
        }
        checked: itemSelected
        onClicked: tokenSelectModel.selectToken(itemAddress)
      }

      Rectangle {
        id: delegateRectangle
        anchors {
          left: delegateCheckbox.right
          verticalCenter: parent.verticalCenter
        }
        color: {
          if (tokenSelectList.currentIndex == index) {
            color: "#9400F6"
          } else if (itemSelected) {
            color: "#0993A2"
          } else {
            color: "#2E2C3D"
          }
        }
        radius: 5
        height: parent.height
        width: parent.width * 0.8
        AVMEAsyncImage {
          id: delegateImage
          anchors.verticalCenter: parent.verticalCenter
          width: parent.height * 0.9
          height: width
          imageSource: {
            var avmeAddress = qmlSystem.getContract("AVME")
            if (itemAddress == avmeAddress) {
              imageSource: "qrc:/img/avme_logo.png"
            } else if (itemIcon && itemIcon != "") {
              imageSource: itemIcon
            } else {
              var img = qmlSystem.getARC20TokenImage(itemAddress)
              imageSource: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
            }
          }
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
        Text {
          id: delegateName
          anchors.verticalCenter: parent.verticalCenter
          width: (parent.width * 0.7)
          x: delegateImage.width + delegateSymbol.width
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
            tokenSelectList.currentIndex = index
            tokenSelectList.forceActiveFocus()
          }
        }
      }
    }
  }
}

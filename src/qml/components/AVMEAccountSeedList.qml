/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Custom list for the Accounts generated with a BIP39 seed.
 * Requires a ListModel with the following items:
 * - "idx": the Account's index on the list
 * - "account": the Account's actual address
 * - "balance": the Account's balance in <coin-name>
 */
ListView {
  id: accountSeedList
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
    size: (accountSeedList.height / accountSeedList.contentHeight)
    policy: (accountSeedList.count > 0) ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    anchors {
      top: parent.top
      right: parent.right
      bottom: parent.bottom
    }
  }

  // Delegate (structure for each item in the list)
  delegate: Component {
    id: listDelegate
    Item {
      id: listItem
      readonly property string itemIndex: idx
      readonly property string itemAccount: account
      readonly property string itemBalance: balance
      width: accountSeedList.width
      height: 30

      Rectangle {
        id: delegateRectangle
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: {
          if (accountSeedList.currentIndex == index) {
            color: "#9400F6"
          } else {
            color: "#2E2C3D"
          }
        }
        radius: 5
        height: parent.height
        width: parent.width * 0.9
        Text {
          id: delegateIndex
          anchors.verticalCenter: parent.verticalCenter
          width: (parent.width * 0.2)
          color: "white"
          font.pixelSize: 14.0
          padding: 5
          elide: Text.ElideRight
          text: itemIndex
        }
        Text {
          id: delegateAccount
          anchors.verticalCenter: parent.verticalCenter
          width: (parent.width * 0.5)
          x: delegateIndex.width
          color: "white"
          font.pixelSize: 14.0
          padding: 5
          elide: Text.ElideMiddle
          text: itemAccount
        }
        Text {
          id: delegateBalance
          anchors.verticalCenter: parent.verticalCenter
          width: (parent.width * 0.3)
          x: delegateIndex.width + delegateAccount.width
          color: "white"
          font.pixelSize: 14.0
          padding: 5
          elide: Text.ElideRight
          text: itemBalance
        }
      }
      MouseArea {
        id: delegateMouseArea
        anchors.fill: parent
        onClicked: {
          accountSeedList.currentIndex = index
          accountSeedList.forceActiveFocus()
        }
      }
    }
  }
}

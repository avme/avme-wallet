/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Custom list for a wallet's addresses and amounts.
 * Requires a ListModel with the following items:
 * - "account": the account's actual address
 * - "name": the account's name/label
 * - "coinAmount": the account's amount in <coin-name>
 * - "tokenAmount": the account's amount in <token-name>
 * - "freeLPAmount": the account's free amount in <liquidity-token>
 * - "lockedLPAmount": the account's locked amount in <liquidity-token>
 */
ListView {
  id: walletList
  property color listHighlightColor: "#887AC1EB"
  property color listBgColor: "#58A0C9"
  property color listHoverColor: "#7AC1DB"

  highlight: Rectangle { color: listHighlightColor; radius: 5 }
  implicitWidth: 500
  implicitHeight: 500
  highlightMoveDuration: 0
  highlightMoveVelocity: 100000
  highlightResizeDuration: 0
  highlightResizeVelocity: 100000
  focus: true
  clip: true
  boundsBehavior: Flickable.StopAtBounds

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
      id: headerAccount
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 6
      color: "white"
      padding: 5
      text: "Account"
      font.pixelSize: 12.0
    }
    Text {
      id: headerName
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 6
      x: headerAccount.x + headerAccount.width
      color: "white"
      padding: 5
      text: "Name"
      font.pixelSize: 12.0
    }
    Text {
      id: headerCoinBalance
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 6
      x: headerName.x + headerName.width
      color: "white"
      padding: 5
      text: "Coin Balance"
      font.pixelSize: 12.0
    }
    Text {
      id: headerTokenBalance
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 6
      x: headerCoinBalance.x + headerCoinBalance.width
      color: "white"
      padding: 5
      text: "Token Balance"
      font.pixelSize: 12.0
    }
    Text {
      id: headerLPFreeBalance
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 6
      x: headerTokenBalance.x + headerTokenBalance.width
      color: "white"
      padding: 5
      text: "Free LP Balance"
      font.pixelSize: 12.0
    }
    Text {
      id: headerLPLockedBalance
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 6
      x: headerLPFreeBalance.x + headerLPFreeBalance.width
      color: "white"
      padding: 5
      text: "Locked LP Balance"
      font.pixelSize: 12.0
    }
  }
  headerPositioning: ListView.OverlayHeader // Prevent header scrolling along

  // Delegate (structure for each item in the list)
  delegate: Component {
    id: listDelegate
    Item {
      id: listItem
      readonly property string itemAccount: account
      readonly property string itemName: name
      readonly property string itemCoinAmount: coinAmount
      readonly property string itemTokenAmount: tokenAmount
      readonly property string itemFreeLPAmount: freeLPAmount
      readonly property string itemLockedLPAmount: lockedLPAmount
      width: parent.width
      height: 30

      Text {
        id: delegateAccount
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 6
        color: "white"
        padding: 5
        elide: Text.ElideRight
        text: itemAccount
        font.pixelSize: 12.0
      }
      Text {
        id: delegateName
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 6
        x: delegateAccount.x + delegateAccount.width
        color: "white"
        padding: 5
        elide: Text.ElideRight
        text: itemName
        font.pixelSize: 12.0
      }
      Text {
        id: delegateCoinBalance
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 6
        x: delegateName.x + delegateName.width
        color: "white"
        padding: 5
        elide: Text.ElideRight
        text: (itemCoinAmount) ? itemCoinAmount : "Loading..."
        font.pixelSize: 12.0
      }
      Text {
        id: delegateTokenBalance
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 6
        x: delegateCoinBalance.x + delegateCoinBalance.width
        color: "white"
        padding: 5
        elide: Text.ElideRight
        text: (itemTokenAmount) ? itemTokenAmount : "Loading..."
        font.pixelSize: 12.0
      }
      Text {
        id: delegateLPFreeBalance
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 6
        x: delegateTokenBalance.x + delegateTokenBalance.width
        color: "white"
        padding: 5
        elide: Text.ElideRight
        text: (itemFreeLPAmount) ? itemFreeLPAmount : "Loading..."
        font.pixelSize: 12.0
      }
      Text {
        id: delegateLPTokenBalance
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 6
        x: delegateLPFreeBalance.x + delegateLPFreeBalance.width
        color: "white"
        padding: 5
        elide: Text.ElideRight
        text: (itemLockedLPAmount) ? itemLockedLPAmount : "Loading..."
        font.pixelSize: 12.0
      }
      MouseArea {
        id: delegateMouseArea
        anchors.fill: parent
        onClicked: walletList.currentIndex = index
      }
    }
  }
}

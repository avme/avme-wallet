import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Custom list for the Accounts generated with a BIP39 seed.
 * Requires a ListModel with the following items:
 * - "index": the Account's index on the list
 * - "account": the Account's actual address
 * - "balance": the Account's balance in <coin-name>
 */

ListView {
  id: accountSeedList
  property color listHighlightColor: "#7AC1EB"
  property color listBgColor: "#58A0C9"
  property color listHoverColor: "#7AC1DB"

  highlight: Rectangle { color: listHighlightColor; radius: 5 }
  implicitWidth: 500
  implicitHeight: 500
  highlightMoveDuration: 100
  highlightMoveVelocity: 1000
  highlightResizeDuration: 100
  highlightResizeVelocity: 1000
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
      id: headerIndex
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 8
      color: "white"
      padding: 5
      text: "Index"
    }

    Text {
      id: headerAccount
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 2
      x: headerIndex.width
      color: "white"
      padding: 5
      text: "Account"
    }

    Text {
      id: headerBalance
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 2
      x: headerIndex.width + headerAccount.width
      color: "white"
      padding: 5
      text: "Balance"
    }
  }
  headerPositioning: ListView.OverlayHeader // Prevent header scrolling along

  // Delegate (structure for each item in the list)
  delegate: Component {
    id: listDelegate
    Item {
      id: listItem
      readonly property string itemIndex: index
      readonly property string itemAccount: account
      readonly property string itemBalance: balance
      width: parent.width
      height: 30

      Text {
        id: delegateIndex
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 8
        color: "white"
        padding: 5
        elide: Text.ElideRight
        text: itemIndex
      }
      Text {
        id: delegateAccount
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 2
        x: delegateIndex.width
        color: "white"
        padding: 5
        elide: Text.ElideRight
        text: itemAccount
      }
      Text {
        id: delegateBalance
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 2
        x: delegateIndex.width + delegateAccount.width
        color: "white"
        padding: 5
        elide: Text.ElideRight
        text: itemBalance
      }
      MouseArea {
        id: delegateMouseArea
        anchors.fill: parent
        onClicked: accountSeedList.currentIndex = index
      }
    }
  }
}

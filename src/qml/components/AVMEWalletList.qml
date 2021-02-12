import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Custom list for a wallet's addresses and amounts.
 * Requires a ListModel with the following items:
 * - "account": the account's actual address
 * - "name": the account's name/label
 * - "coinAmount": the account's amount in <coin-name>
 * - "tokenAmount": the account's amount in <token-name>
 */

ListView {
  id: walletList
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
    anchors.horizontalCenter: parent.horizontalCenter
    color: listBgColor

    Text {
      id: headerAccount
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 2
      color: "white"
      padding: 5
      text: "Account"
    }

    Text {
      id: headerName
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 2
      x: headerAccount.width
      color: "white"
      padding: 5
      text: "Name"
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
      width: parent.width
      height: 30

      Text {
        id: delegateAccount
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 2
        color: "white"
        padding: 5
        elide: Text.ElideRight
        text: itemAccount
      }
      Text {
        id: delegateName
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 2
        x: delegateAccount.width
        color: "white"
        padding: 5
        elide: Text.ElideRight
        text: itemName
      }
      MouseArea {
        id: delegateMouseArea
        anchors.fill: parent
        onClicked: walletList.currentIndex = index
      }
    }
  }
}

import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Custom list for an Account's transaction history.
 * Requires a ListModel with the items from the WalletTxData struct.
 * See transactions.h for more info.
 */

ListView {
  id: historyList
  property color listHighlightColor: "#887AC1EB"
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
      id: headerDateTime
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 2
      x: 16 + 5
      color: "white"
      padding: 5
      text: "Timestamp"
    }
    Text {
      id: headerOperation
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 2
      x: headerDateTime.x + headerDateTime.width
      color: "white"
      padding: 5
      text: "Operation"
    }
  }
  headerPositioning: ListView.OverlayHeader // Prevent header scrolling along

  // Delegate (structure for each item in the list)
  delegate: Component {
    id: listDelegate
    Item {
      id: listItem
      readonly property string itemTxLink: txlink
      readonly property string itemOperation: operation
      //readonly property string itemHex: hex
      //readonly property string itemType: type
      //readonly property string itemCode: code
      readonly property string itemFrom: from
      readonly property string itemTo: to
      readonly property string itemTxData: txdata
      //readonly property string itemCreates: creates
      readonly property string itemValue: value
      //readonly property string itemNonce: nonce
      readonly property string itemGas: gas
      readonly property string itemPrice: price
      //readonly property string itemHash: hash
      //readonly property string itemV: v
      //readonly property string itemR: r
      //readonly property string itemS: s
      readonly property string itemDateTime: datetime
      readonly property string itemUnixTime: unixtime
      readonly property bool itemConfirmed: confirmed
      width: parent.width
      height: 30

      Image {
        id: delegateConfirmed
        width: 16
        height: 16
        x: 5
        anchors.verticalCenter: parent.verticalCenter
        source: (itemConfirmed) ? "qrc:/img/ok.png" : "qrc:/img/no.png"
      }
      Text {
        id: delegateDateTime
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 2
        x: delegateConfirmed.x + delegateConfirmed.width
        color: "white"
        padding: 5
        elide: Text.ElideRight
        text: itemDateTime
      }
      Text {
        id: delegateOperation
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 2
        x: delegateDateTime.x + delegateDateTime.width
        color: "white"
        padding: 5
        elide: Text.ElideRight
        text: itemOperation
      }
      MouseArea {
        id: delegateMouseArea
        anchors.fill: parent
        onClicked: historyList.currentIndex = index
      }
    }
  }
}

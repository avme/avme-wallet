import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Custom list for a wallet's addresses and amounts.
 * Requires a ListModel with the following items:
 * - "account": the address
 * - "amount": the account's amount
 */

ListView {
  id: list
  highlight: Rectangle { color: "#7AC1EB"; radius: 5 }
  implicitWidth: 500
  implicitHeight: 500
  highlightMoveDuration: 100
  highlightMoveVelocity: 1000
  highlightResizeDuration: 100
  highlightResizeVelocity: 1000
  focus: true
  clip: true

  header: Rectangle {
    id: listHeader
    color: "#58A0C9"
    width: parent.width
    height: 30
    anchors.horizontalCenter: parent.horizontalCenter
    z: 2

    Row {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 2
      Text {
        text: "Account"; font.pixelSize: 18; color: "white"; padding: 5;
      }
    }
    Row {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 2
      x: parent.width / 2
      Text {
        text: "Amount"; font.pixelSize: 18; color: "white"; padding: 5;
      }
    }
  }
  headerPositioning: ListView.OverlayHeader // Prevent header scrolling along

  delegate: Component {
    id: listDelegate
    Item {
      id: listItem
      width: parent.width
      height: 40
      z: 1
      Row {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 2
        Text { text: account; font.pixelSize: 18; color: "white"; padding: 5; }
      }
      Row {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 2
        x: parent.width / 2
        Text { text: amount; font.pixelSize: 18; color: "white"; padding: 5; }
      }
      MouseArea {
        anchors.fill: parent
        onClicked: list.currentIndex = index
      }
    }
  }
}

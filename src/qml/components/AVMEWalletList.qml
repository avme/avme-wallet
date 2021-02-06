import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Custom list for a wallet's addresses and amounts.
 * Requires a ListModel with the following items:
 * - "name": the account's name/label
 * - "account": the account's actual address
 * - "amount": the account's amount
 */

ListView {
  id: walletList
  highlight: Rectangle { color: "#7AC1EB"; radius: 5 }
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
    anchors.horizontalCenter: parent.horizontalCenter
    color: "#58A0C9"

    Row {
      id: headerNameRow
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 8
      Text {
        text: "Name"; font.pixelSize: 18; color: "white"; padding: 5;
      }
    }
    Row {
      id: headerAccountRow
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 2
      x: headerNameRow.width
      Text {
        text: "Account"; font.pixelSize: 18; color: "white"; padding: 5;
      }
    }
    Row {
      id: headerAmountRow
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width / 4
      x: headerNameRow.width + headerAccountRow.width
      Text {
        text: "Amount"; font.pixelSize: 18; color: "white"; padding: 5;
      }
    }
  }
  headerPositioning: ListView.OverlayHeader // Prevent header scrolling along

  // Delegate (structure for each item in the list)
  delegate: Component {
    id: listDelegate
    Item {
      id: listItem
      readonly property alias listItemName: itemName.text
      readonly property alias listItemAccount: itemAccount.text
      readonly property alias listItemAmount: itemAmount.text
      width: parent.width
      height: 40

      Row {
        id: delegateNameRow
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 8
        Text { id: itemName; text: name; elide: Text.ElideRight; font.pixelSize: 18; color: "white"; padding: 5; }
      }
      Row {
        id: delegateAccountRow
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 2
        x: delegateNameRow.width
        Text { id: itemAccount; text: account; elide: Text.ElideRight; font.pixelSize: 18; color: "white"; padding: 5; }
      }
      Row {
        id: delegateAmountRow
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 4
        x: delegateNameRow.width + delegateAccountRow.width
        Text { id: itemAmount; text: amount; elide: Text.ElideRight; font.pixelSize: 18; color: "white"; padding: 5; }
      }
      MouseArea {
        id: itemMouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
          walletList.currentIndex = index
          if (mouse.button == Qt.RightButton) {
            listItemMenu.open()
          }
        }
      }
      Menu {
        id: listItemMenu
        x: itemMouseArea.mouseX
        y: itemMouseArea.mouseY
        implicitWidth: 250
        implicitHeight: 30
        background: Rectangle { anchors.fill: parent; color: "#58A0B9" }
        MenuItem {
          id: menuItem
          hoverEnabled: true
          background: Rectangle { color: menuItem.hovered ? "#7AC1DB" : "#58A0B9" }
          text: "Copy Address to Clipboard"
          onTriggered: System.copyToClipboard(listItemAccount)
        }
      }
    }
  }
}

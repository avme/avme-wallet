import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

Item {
  AVMEMenu {
    id: sideMenu
    width: 200
    anchors {
      left: parent.left
      top: parent.top
      bottom: parent.bottom
    }
  }

  AVMEWalletList {
    id: walletList
    height: 670
    anchors {
      left: sideMenu.right
      right: parent.right
      top: parent.top
      bottom: parent.bottom
      bottomMargin: 50
    }
    boundsBehavior: Flickable.StopAtBounds
    model: ListModel {
      id: accountsList
      Component.onCompleted: {
        var accList = System.listAccounts("eth")
        for (var i = 0; i < accList.length; i++) {
          accountsList.append(JSON.parse(accList[i]))
        }
      }
    }
  }

  Row {
    id: buttons
    height: 50
    spacing: 5
    width: walletList.width
    anchors.top: walletList.bottom
    anchors.left: sideMenu.right
    anchors.leftMargin: spacing / 2

    AVMEButton {
      id: btnNewAccount
      width: (parent.width / 3) - parent.spacing
      text: "New Account (WIP)"
    }
    AVMEButton {
      id: btnSendETH
      width: (parent.width / 3) - parent.spacing
      text: "Send Transaction (WIP)"
    }
    AVMEButton {
      id: btnEraseAccount
      width: (parent.width / 3) - parent.spacing
      text: "Erase Account (WIP)"
    }
  }
}

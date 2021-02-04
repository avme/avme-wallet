import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Screen for listing Accounts and their general operations

Item {
  id: accountsScreen

  AVMEMenu {
    id: sideMenu
  }

  // Account list
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

  // Account operation buttons
  Row {
    id: buttons
    width: walletList.width
    height: 50
    spacing: 5
    anchors {
      top: walletList.bottom
      left: sideMenu.right
      leftMargin: spacing / 2
    }

    AVMEButton {
      id: btnNewAccount
      width: (parent.width / 3) - parent.spacing
      text: "New Account"
      onClicked: System.setScreen(content, "qml/screens/NewAccountScreen.qml")
    }
    AVMEButton {
      id: btnSendETH
      width: (parent.width / 3) - parent.spacing
      text: "Send Transaction"
      onClicked: {
        System.setTxSenderAccount(walletList.currentItem.listItemAccount)
        System.setTxSenderAmount(walletList.currentItem.listItemAmount)
        System.setScreen(content, "qml/screens/TransactionScreen.qml")
      }
    }
    AVMEButton {
      id: btnEraseAccount
      width: (parent.width / 3) - parent.spacing
      text: "Erase Account"
      onClicked: erasePopup.open()
    }
  }

  // Modal for confirming Account erasure
  Popup {
    id: erasePopup
    width: parent.width / 2
    height: parent.height / 4
    x: (parent.width / 2) - (width / 2)
    y: (parent.height / 2) - (height / 2)
    modal: true
    focus: true
    padding: 0  // Remove white borders
    closePolicy: Popup.CloseOnPressOutside

    // TODO: maybe put a warning icon here
    Rectangle {
      id: popupBg
      anchors.fill: parent
      color: "#9A4FAD"
      Text {
        id: popupText
        anchors {
          horizontalCenter: parent.horizontalCenter
          top: parent.top
          topMargin: parent.height / 4
        }
        text: "Are you sure you want to completely erase this account?"
      }
      Row {
        id: popupBtns
        anchors {
          horizontalCenter: parent.horizontalCenter
          bottom: parent.bottom
          bottomMargin: parent.height / 4
        }
        spacing: 10

        AVMEButton {
          id: btnNo
          text: "No"
          onClicked: erasePopup.close()
        }
        AVMEButton {
          id: btnYes
          text: "Yes"
          onClicked: {
            var acc = walletList.currentItem.listItemAccount
            if (System.eraseAccount(acc)) {
              accountsList.clear()
              console.log("Account erased successfully")
              var accList = System.listAccounts("eth")
              for (var i = 0; i < accList.length; i++) {
                accountsList.append(JSON.parse(accList[i]))
              }
            } else {
              // TODO: show this message on screen with a label
              console.log("Error on erasing Account")
            }
            erasePopup.close()
          }
        }
      }
    }
  }
}

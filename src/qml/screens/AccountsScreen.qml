import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

Item {
  id: accounts_screen

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
      onClicked: erase_popup.open()
    }
  }

  Popup {
    id: erase_popup
    width: parent.width / 2
    height: parent.height / 4
    x: (parent.width / 2) - (width / 2)
    y: (parent.height / 2) - (height / 2)
    modal: true
    focus: true
    padding: 0
    closePolicy: Popup.CloseOnPressOutside

    // TODO: maybe put a warning icon here
    Rectangle {
      id: popup_bg
      anchors.fill: parent
      color: "#9A4FAD"
      Text {
        id: popup_text
        anchors {
          horizontalCenter: parent.horizontalCenter
          top: parent.top
          topMargin: parent.height / 4
        }
        text: "Are you sure you want to completely erase this account?"
      }
      Row {
        id: popup_buttons
        anchors {
          horizontalCenter: parent.horizontalCenter
          bottom: parent.bottom
          bottomMargin: parent.height / 4
        }
        spacing: 10

        AVMEButton {
          id: btn_no
          text: "No"
          onClicked: erase_popup.close()
        }
        AVMEButton {
          id: btn_yes
          text: "Yes"
          onClicked: {
            var acc = walletList.currentItem.listItemAccount
            if (System.eraseAccount(acc)) {
              accountsList.clear()
              console.log("Account erased successfully.")
              var accList = System.listAccounts("eth")
              for (var i = 0; i < accList.length; i++) {
                accountsList.append(JSON.parse(accList[i]))
              }
            } else {
              // TODO: show this message on screen with a label
              console.log("Error on erasing Account.")
            }
            erase_popup.close()
          }
        }
      }
    }
  }
}

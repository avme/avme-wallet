import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Screen for listing Accounts and their general operations

Item {
  id: accountsScreen

  Component.onCompleted: {
    fetchAccountsPopup.open()
    var accList = System.listAccounts("eth")
    for (var i = 0; i < accList.length; i++) {
      accountsList.append(JSON.parse(accList[i]))
    }
    fetchAccountsPopup.close()
  }

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

  // Popup for fetching Accounts
  Popup {
    id: fetchAccountsPopup
    width: window.width / 4
    height: window.height / 8
    x: (window.width / 2) - (width / 2)
    y: (window.height / 2) - (height / 2)
    modal: true
    focus: true
    padding: 0  // Remove white borders
    closePolicy: Popup.NoAutoClose

    Rectangle {
      anchors.fill: parent
      color: "#9A4FAD"
      Text {
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        text: "Fetching Accounts..."
      }
    }
  }

  // Popup for confirming Account erasure
  Popup {
    id: erasePopup
    width: window.width / 2
    height: window.height / 4
    x: (window.width / 2) - (width / 2)
    y: (window.height / 2) - (height / 2)
    modal: true
    focus: true
    padding: 0  // Remove white borders
    closePolicy: Popup.CloseOnPressOutside

    Rectangle {
      id: popupBg
      anchors.fill: parent
      color: "#9A4FAD"

      // Popup info
      Row {
        id: popupInfo
        anchors {
          horizontalCenter: parent.horizontalCenter
          top: parent.top
          topMargin: parent.height / 6
        }
        spacing: 10

        Image {
          id: popupPng
          height: 50
          anchors.verticalCenter: parent.verticalCenter
          fillMode: Image.PreserveAspectFit
          source: "qrc:/img/warn.png"
        }

        Text {
          id: popupText
          anchors.verticalCenter: popupPng.verticalCenter
          horizontalAlignment: Text.AlignHCenter
          text: "Are you sure you want to completely erase this Account?<br>"
          + "All funds on it will be <b>permanently lost</b>."
        }
      }

      // Popup buttons
      Row {
        id: popupBtns
        anchors {
          horizontalCenter: parent.horizontalCenter
          bottom: parent.bottom
          bottomMargin: parent.height / 6
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

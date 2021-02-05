import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Screen for listing Accounts and their general operations

Item {
  id: accountsScreen

  function fetchAccounts() {
    fetchAccountsPopup.open()
    var accList = System.listAccounts("eth")
    for (var i = 0; i < accList.length; i++) {
      accountsList.append(JSON.parse(accList[i]))
    }
    fetchAccountsPopup.close()
  }

  Component.onCompleted: fetchAccounts()

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
  AVMEPopup {
    id: fetchAccountsPopup
    info: "Fetching Accounts..."
  }

  // Info popup for if the Account erasure fails
  AVMEPopupInfo {
    id: eraseFailPopup
    icon: "qrc:/img/warn.png"
    info: "Error on erasing Account. Please try again."
  }

  // Yes/No popup for confirming Account erasure
  AVMEPopupYesNo {
    id: erasePopup
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to completely erase this Account?<br>"
    + "All funds on it will be <b>permanently lost</b>."
    yesBtn.onClicked: {
      var acc = walletList.currentItem.listItemAccount
      if (System.eraseAccount(acc)) {
        accountsList.clear()
        console.log("Account erased successfully")
        erasePopup.close()
        fetchAccounts()
      } else {
        erasePopup.close()
        eraseFailPopup.open()
      }
    }
    noBtn.onClicked: erasePopup.close()
  }
}

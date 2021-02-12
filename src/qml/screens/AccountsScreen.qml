import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Screen for listing Accounts and their general operations

Item {
  id: accountsScreen
  property alias wList: accountRow.accountList
  property bool hasCoin
  property bool hasToken

  function fetchAccounts() {
    var accList = System.listAccounts()
    for (var i = 0; i < accList.length; i++) {
      accountsList.append(JSON.parse(accList[i]))
    }
  }

  Component.onCompleted: {
    // Always default to AVAX & TAEX on first load
    if (System.getCurrentCoin() == "") {
      System.setCurrentCoin("AVAX")
      System.setCurrentCoinDecimals(18)
    }
    if (System.getCurrentToken() == "") {
      System.setCurrentToken("TAEX")
      System.setCurrentTokenDecimals(18)
    }
    hasCoin = (System.getCurrentCoin() != "");
    hasToken = (System.getCurrentToken() != "");
    fetchAccountsPopup.open()
    System.updateScreen()
    //console.log("First load:" + System.getFirstLoad())
    if (System.getFirstLoad()) {
      System.loadWalletAccounts(System.getFirstLoad())
      System.setFirstLoad(false)
    }
    fetchAccounts()
    fetchAccountsPopup.close()
  }

  // Background icon
  Image {
    id: bgIcon
    width: 256
    height: 256
    anchors.centerIn: parent
    fillMode: Image.PreserveAspectFit
    source: "qrc:/img/avme_logo.png"
  }

  // Account list and stats
  Row {
    id: accountRow
    property alias accountList: walletList
    height: parent.height - buttons.height
    spacing: 5
    anchors {
      top: parent.top
      bottom: buttons.top
      left: parent.left
      right: parent.right
      margins: spacing
    }

    Rectangle {
      id: listRect
      width: ((parent.width / 3) * 2) - parent.spacing
      height: parent.height
      radius: 5
      color: "#4458A0C9"

      AVMEWalletList {
        id: walletList
        width: listRect.width
        height: listRect.height
        model: ListModel { id: accountsList }
      }
    }

    Rectangle {
      id: statsRect
      width: (parent.width / 3) - parent.spacing
      height: parent.height
      radius: 5
      color: "#44AB5FBE"

      Text {
        id: balanceCoinLabel
        anchors {
          top: parent.top
          left: parent.left
          right: parent.right
          margins: 20
        }
        text: "Coin Balance"
      }

      Text {
        id: balanceCoinText
        visible: accountsScreen.hasCoin
        anchors {
          top: balanceCoinLabel.bottom
          left: parent.left
          margins: 20
        }
        font.bold: true
        text: (wList.currentItem) ? wList.currentItem.itemCoinAmount : ""
      }

      Text {
        id: balanceCoinType
        visible: accountsScreen.hasCoin
        anchors {
          top: balanceCoinLabel.bottom
          left: balanceCoinText.right
          right: parent.right
          margins: 20
          leftMargin: 10
        }
        text: (wList.currentItem) ? System.getCurrentCoin() : ""
      }

      Text {
        id: balanceTokenLabel
        visible: accountsScreen.hasToken
        anchors {
          top: balanceCoinText.bottom
          left: parent.left
          right: parent.right
          margins: 20
        }
        text: "Token Balance"
      }

      Text {
        id: balanceTokenText
        visible: accountsScreen.hasToken
        anchors {
          top: balanceTokenLabel.bottom
          left: parent.left
          margins: 20
        }
        font.bold: true
        text: (wList.currentItem) ? wList.currentItem.itemTokenAmount : ""
      }

      Text {
        id: balanceTokenType
        visible: accountsScreen.hasToken
        anchors {
          top: balanceTokenLabel.bottom
          left: balanceTokenText.right
          right: parent.right
          margins: 20
          leftMargin: 10
        }
        text: (wList.currentItem) ? System.getCurrentToken() : ""
      }

      Column {
        id: accountOps
        width: parent.width
        spacing: 20
        anchors {
          top: balanceTokenText.bottom
          bottom: parent.bottom
          left: parent.left
          right: parent.right
          margins: 20
        }

        AVMEButton {
          id: btnCopyAccount
          width: parent.width
          text: (!textTimer.running) ? "Copy Account to Clipboard" : "Copied!"
          enabled: !textTimer.running
          Timer { id: textTimer; interval: 2000 }
          onClicked: {
            System.copyToClipboard(wList.currentItem.itemAccount)
            textTimer.start()
          }
        }
        AVMEButton {
          id: btnSendCoinTx
          width: parent.width
          enabled: accountsScreen.hasCoin
          text: "Send Coin Transaction"
          onClicked: {
            System.setTxSenderAccount(wList.currentItem.itemAccount)
            System.setTxSenderCoinAmount(wList.currentItem.itemCoinAmount)
            System.setTxTokenFlag(false)
            System.setScreen(content, "qml/screens/CoinTransactionScreen.qml")
          }
        }
        AVMEButton {
          id: btnSendTokenTx
          width: parent.width
          enabled: accountsScreen.hasToken
          text: "Send Token Transaction"
          onClicked: {
            System.setTxSenderAccount(wList.currentItem.itemAccount)
            System.setTxSenderCoinAmount(wList.currentItem.itemCoinAmount)
            System.setTxSenderTokenAmount(wList.currentItem.itemTokenAmount)
            System.setTxTokenFlag(true)
            System.setScreen(content, "qml/screens/TokenTransactionScreen.qml")
          }
        }
        AVMEButton {
          id: btnTxHistory
          width: parent.width
          text: "Check Transaction History (WIP)"
          onClicked: {

          }
        }
        AVMEButton {
          id: btnViewKey
          width: parent.width
          text: "View Private Key"
          onClicked: {
            viewKeyPopup.account = wList.currentItem.itemAccount
            viewKeyPopup.open()
          }
        }
        AVMEButton {
          id: btnEraseAccount
          width: parent.width
          text: "Erase this Account"
          onClicked: {
            erasePopup.account = wList.currentItem.itemAccount
            erasePopup.open()
          }
        }
      }
    }
  }

  // Buttons for Wallet operations
  Row {
    id: buttons
    width: parent.width
    height: 50
    spacing: 5
    anchors {
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      leftMargin: spacing
    }

    AVMEButton {
      id: btnCloseWallet
      width: (parent.width / 3) - parent.spacing
      anchors.verticalCenter: parent.verticalCenter
      text: "Close Wallet"
      onClicked: closeWalletPopup.open()
    }
    AVMEButton {
      id: btnNewAccount
      width: (parent.width / 3) - parent.spacing
      anchors.verticalCenter: parent.verticalCenter
      text: "Create New Account"
      onClicked: newAccountPopup.open()
    }
    AVMEButton {
      // TODO: add fiat pricing here too when the time comes
      id: btnSendAVAX
      width: (parent.width / 3) - parent.spacing
      anchors.verticalCenter: parent.verticalCenter
      text: "Change Current Coin/Token (WIP)"
      onClicked: {
        
      }
    }
  }

  // Popup for creating a new Account
  Popup {
    id: newAccountPopup
    width: window.width / 2
    height: (window.height / 2) + 50
    x: width / 2
    y: height / 2
    modal: true
    focus: true
    padding: 0  // Remove white borders
    closePolicy: Popup.NoAutoClose
    background: Rectangle { anchors.fill: parent; color: "#9A4FAD" }

    Column {
      id: newAccountCol
      anchors.fill: parent
      spacing: 30
      topPadding: 20

      Text {
        id: info
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Enter the following details to create a new Account."
      }

      // Account name/label
      AVMEInput {
        id: nameInput
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width / 1.5
        label: "Name (optional)"
        placeholder: "Label for your Account"
      }

      // Account passphrase
      AVMEInput {
        id: passInput
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width / 1.5
        echoMode: TextInput.Password
        passwordCharacter: "*"
        label: "Passphrase"
        placeholder: "Passphrase for your Account"
        enabled: !passCheck.checked
      }

      // Account hint
      AVMEInput {
        id: hintInput
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width / 1.5
        label: "Hint (optional)"
        placeholder: "Hint to help you remember the passphrase"
        enabled: !passCheck.checked
      }

      // Checkbox for using Wallet passphrase as the Account passphrase
      CheckBox {
        id: passCheck
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Use wallet passphrase"
        onClicked: {
          if (!passInput.enabled && !hintInput.enabled) {
            // Disabled fields (use master pass)
            passInput.text = ""
            hintInput.text = ""
          }
        }
      }

      // Buttons
      Row {
        id: btnRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AVMEButton {
          id: btnBack
          width: newAccountCol.width / 4
          text: "Back"
          onClicked: newAccountPopup.close()
        }

        AVMEButton {
          id: btnDone
          width: newAccountCol.width / 4
          text: "Done"
          enabled: (passInput.text !== "" || passCheck.checked)
          onClicked: {
            var name = nameInput.text
            var pass = passInput.text
            var hint = hintInput.text
            var usesMasterPass = passCheck.checked
            if (usesMasterPass) {
              pass = System.getWalletPass()
              hint = ""
            }
            try {
              System.createNewAccount(name, pass, hint, passCheck)
              console.log("Account created successfully")
              accountsList.clear()
              nameInput.text = passInput.text = hintInput.text = ""
              newAccountPopup.close()
              fetchAccountsPopup.open()
              System.updateScreen()
              console.log("Reloading Accounts...")
              System.loadWalletAccounts(false)
              fetchAccounts()
              fetchAccountsPopup.close()
            } catch (error) {
              accountFailPopup.open()
              newAccountPopup.close()
            }
          }
        }
      }
    }
  }

  // Popup for viewing the Account's private key
  Popup {
    id: viewKeyPopup
    property string account
    width: (window.width / 2) + 200
    height: (window.height / 2) + 50
    x: (width / 2) - 200
    y: (height / 2) - 50
    modal: true
    focus: true
    padding: 0  // Remove white borders
    closePolicy: Popup.NoAutoClose
    background: Rectangle { anchors.fill: parent; color: "#9A4FAD" }

    Column {
      id: viewKeyCol
      anchors.fill: parent
      spacing: 30
      topPadding: 40

      Text {
        id: warningText
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: "Please authenticate with your Wallet's passphrase to view the key for the Account:<br>"
        + "<b>" + viewKeyPopup.account + "</b>"
        + "<br><br><b>YOU ARE FULLY RESPONSIBLE FOR GUARDING YOUR PRIVATE KEYS."
        + "<br>KEEP THEM AWAY FROM PRYING EYES AND DO NOT SHARE THEM WITH ANYONE."
        + "<br>WE ARE NOT HELD LIABLE FOR ANY FUND LOSSES IF YOU DECIDE TO PROCEED.</b>"
      }

      AVMEInput {
        id: keyPassInput
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width / 3
        echoMode: TextInput.Password
        passwordCharacter: "*"
      }

      TextArea {
        id: keyArea
        property alias timer: keyTextTimer
        width: parent.width - 100
        height: 50
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        readOnly: true
        selectByMouse: true
        selectionColor: "#9CE3FD"
        color: "black"
        background: Rectangle {
          width: parent.width
          height: parent.height
          color: "#782D8B"
        }
        Timer { id: keyTextTimer; interval: 2000; onTriggered: keyArea.text = "" }
      }

      Row {
        id: keyBtnRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AVMEButton {
          id: keyBtnClose
          text: "Close"
          onClicked: {
            viewKeyPopup.account = ""
            keyPassInput.text = ""
            keyArea.text = ""
            viewKeyPopup.close()
          }
        }
        AVMEButton {
          id: keyBtnShow
          text: "Show"
          onClicked: {
            var acc = viewKeyPopup.account
            var pass = keyPassInput.text
            if (System.checkWalletPass(keyPassInput.text)) {
              if (keyArea.timer.running) { keyArea.timer.stop() }
              keyArea.text = System.getPrivateKeys(acc, pass)
            } else {
              keyArea.text = "Wrong password, please try again"
              keyArea.timer.start()
            }
          }
        }
      }
    }
  }

  // Popup for fetching Accounts
  AVMEPopup {
    id: fetchAccountsPopup
    info: "Loading Accounts...<br>This may take a while."
  }

  // Info popup for if the Account creation fails
  AVMEPopupInfo {
    id: accountFailPopup
    icon: "qrc:/img/warn.png"
    info: "Error on Account creation. Please try again."
  }

  // Info popup for if the Account erasure fails
  AVMEPopupInfo {
    id: eraseFailPopup
    icon: "qrc:/img/warn.png"
    info: "Error on erasing Account. Please try again."
  }

  // Yes/No popup for confirming Wallet closure
  AVMEPopupYesNo {
    id: closeWalletPopup
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to close this Wallet?"
    yesBtn.onClicked: {
      closeWalletPopup.close()
      console.log("Wallet closed successfully")
      System.setScreen(content, "qml/screens/StartScreen.qml")
    }
    noBtn.onClicked: closeWalletPopup.close()
  }

  // Yes/No popup for confirming Account erasure
  AVMEPopupYesNo {
    id: erasePopup
    property string account
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to erase this Account?<br>"
    + "<b>" + account + "</b>"
    + "<br>All funds on it will be <b>permanently lost</b>."
    yesBtn.onClicked: {
      var acc = wList.currentItem.itemAccount
      if (System.eraseAccount(acc)) {
        console.log("Account erased successfully")
        accountsList.clear()
        erasePopup.close()
        erasePopup.account = ""
        fetchAccountsPopup.open()
        System.updateScreen()
        console.log("Reloading Accounts...")
        System.loadWalletAccounts(false)
        fetchAccounts()
        fetchAccountsPopup.close()
      } else {
        erasePopup.close()
        erasePopup.account = ""
        eraseFailPopup.open()
      }
    }
    noBtn.onClicked: {
      erasePopup.account = ""
      erasePopup.close()
    }
  }
}

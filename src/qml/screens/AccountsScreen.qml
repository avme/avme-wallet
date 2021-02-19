import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Screen for listing Accounts and their general operations

Item {
  id: accountsScreen
  property bool hasCoin
  property bool hasToken

  Connections {
    target: System

    onRefreshAccountList: {
      console.log("Loading Accounts...")
      System.loadWalletAccounts(System.getFirstLoad())
      if (System.getFirstLoad()) { System.setFirstLoad(false) }
      accountsList.clear()
      fetchAccounts()
      fetchAccountsPopup.close()
    }
    onAccountCreated: {
      console.log("Account created successfully")
      accountDataPopup.setData(data.accId, data.accName, data.accAddress, data.accSeed)
      createAccountPopup.close()
      accountDataPopup.open()
    }
    onAccountsGenerated: {
      importAccountPopup.setAccountListData(data)
      importAccountPopup.seed = seed
      generateAccountsPopup.close()
      importAccountPopup.open()
    }
    onAccountImported: {
      if (success) {
        importSeedAccountPopup.close()
        fetchAccountsPopup.open()
        System.refreshAccounts()
      } else {
        importSeedAccountPopup.close()
        importFailPopup.open()
      }
    }
  }

  function fetchAccounts() {
    var accList = System.listAccounts()
    for (var i = 0; i < accList.length; i++) {
      accountsList.append(JSON.parse(accList[i]))
    }
  }

  Component.onCompleted: {
    // Always default to AVAX & AVME on first load
    if (System.getCurrentCoin() == "") {
      System.setCurrentCoin("AVAX")
      System.setCurrentCoinDecimals(18)
    }
    if (System.getCurrentToken() == "") {
      System.setCurrentToken("AVME")
      System.setCurrentTokenDecimals(18)
    }
    hasCoin = (System.getCurrentCoin() != "");
    hasToken = (System.getCurrentToken() != "");
    fetchAccountsPopup.open()
    System.refreshAccounts()
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

      // TODO: add fiat pricing here too when the time comes
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
        text: (walletList.currentItem) ? walletList.currentItem.itemCoinAmount : ""
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
        text: (walletList.currentItem) ? System.getCurrentCoin() : ""
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
        text: (walletList.currentItem) ? walletList.currentItem.itemTokenAmount : ""
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
        text: (walletList.currentItem) ? System.getCurrentToken() : ""
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
          enabled: (walletList.currentItem && !textTimer.running)
          Timer { id: textTimer; interval: 2000 }
          onClicked: {
            System.copyToClipboard(walletList.currentItem.itemAccount)
            textTimer.start()
          }
        }
        AVMEButton {
          id: btnSendCoinTx
          width: parent.width
          enabled: (walletList.currentItem && accountsScreen.hasCoin)
          text: "Send Coin Transaction"
          onClicked: {
            System.setTxSenderAccount(walletList.currentItem.itemAccount)
            System.setTxSenderCoinAmount(walletList.currentItem.itemCoinAmount)
            System.setTxTokenFlag(false)
            System.setScreen(content, "qml/screens/CoinTransactionScreen.qml")
          }
        }
        AVMEButton {
          id: btnSendTokenTx
          width: parent.width
          enabled: (walletList.currentItem && accountsScreen.hasToken)
          text: "Send Token Transaction"
          onClicked: {
            System.setTxSenderAccount(walletList.currentItem.itemAccount)
            System.setTxSenderCoinAmount(walletList.currentItem.itemCoinAmount)
            System.setTxSenderTokenAmount(walletList.currentItem.itemTokenAmount)
            System.setTxTokenFlag(true)
            System.setScreen(content, "qml/screens/TokenTransactionScreen.qml")
          }
        }
        AVMEButton {
          id: btnTxHistory
          width: parent.width
          enabled: (walletList.currentItem)
          text: "Check Transaction History (WIP)"
          onClicked: {}
        }
        AVMEButton {
          id: btnViewKey
          width: parent.width
          enabled: (walletList.currentItem)
          text: "View Private Key"
          onClicked: {
            viewPrivKeyPopup.account = walletList.currentItem.itemAccount
            viewPrivKeyPopup.open()
          }
        }
        AVMEButton {
          id: btnEraseAccount
          width: parent.width
          enabled: (walletList.currentItem)
          text: "Erase this Account"
          onClicked: {
            erasePopup.account = walletList.currentItem.itemAccount
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
      id: btnImportSeed
      width: (parent.width / 3) - parent.spacing
      anchors.verticalCenter: parent.verticalCenter
      text: "Import Account Seed"
      onClicked: importSeedPopup.open()
    }
  }

  // Popup for creating a new Account
  AVMEPopupNewAccount {
    id: newAccountPopup
    doneBtn.onClicked: {
      if (System.checkWalletPass(pass)) {
        try {
          console.log("Creating new Account...")
          System.createNewAccount(name, pass)
          newAccountPopup.clean()
          newAccountPopup.close()
          createAccountPopup.open()
        } catch (error) {
          newAccountPopup.close()
          accountFailPopup.open()
        }
      } else {
        passInfo.timer.start()
      }
    }
  }

  // Popup for viewing a new Account's data and seed
  AVMEPopupAccountData {
    id: accountDataPopup
    okBtn.onClicked: {
      accountDataPopup.clean()
      accountDataPopup.close()
      fetchAccountsPopup.open()
      System.refreshAccounts()
    }
  }

  // Popup for importing an Account seed
  AVMEPopupImportSeed {
    id: importSeedPopup
    doneBtn.onClicked: {
      if (System.seedIsValid(seed)) {
        console.log("Generating Accounts...")
        System.generateAccountsFromSeed(seed)
        importSeedPopup.clean()
        importSeedPopup.close()
        generateAccountsPopup.open()
      } else {
        errorText.visible = true;
        errorTimer.start();
      }
    }
  }

  // Popup for selecting an Account from a seed list
  AVMEPopupImportAccount {
    id: importAccountPopup
    doneBtn.onClicked: {
      var idx = importAccountPopup.curItem.itemIndex
      var acc = importAccountPopup.curItem.itemAccount
      if (System.accountExists(acc)) {
        importAccountPopup.showErrorMsg()
      } else if (System.checkWalletPass(pass)) {
        importAccountPopup.close()
        importSeedAccountPopup.open()
        System.importAccount(seed, idx, name, pass)
      } else {
        importAccountPopup.close()
      }
    }
  }

  // Popup for viewing the Account's private key
  AVMEPopupViewPrivKey {
    id: viewPrivKeyPopup
    showBtn.onClicked: {
      if (System.checkWalletPass(pass)) {
        viewPrivKeyPopup.showPrivKey()
      } else {
        viewPrivKeyPopup.showErrorMsg()
      }
    }
  }

  // Popup for fetching Accounts
  AVMEPopup {
    id: fetchAccountsPopup
    info: "Loading Accounts...<br>This may take a while."
  }

  // Popup for waiting for a new Account to be created
  AVMEPopup {
    id: createAccountPopup
    info: "Creating a new Account..."
  }

  // Popup for generating Accounts from a seed
  AVMEPopup {
    id: generateAccountsPopup
    info: "Generating up to 10 Accounts..."
  }

  // Popup for waiting for a new Account to be imported
  AVMEPopup {
    id: importSeedAccountPopup
    info: "Importing Account..."
  }

  // Info popup for if the Account creation fails
  AVMEPopupInfo {
    id: accountFailPopup
    icon: "qrc:/img/warn.png"
    info: "Error on Account creation. Please try again."
  }

  // Info popup for if the Account import fails
  AVMEPopupInfo {
    id: importFailPopup
    icon: "qrc:/img/warn.png"
    info: "Error on importing Account. Please try again."
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
    height: window.height / 2
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to erase this Account?<br>"
    + "<b>" + account + "</b>"
    + "<br>All funds on it will be <b>PERMANENTLY LOST</b>."

    Text {
      id: erasePassInfo
      property alias timer: erasePassInfoTimer
      y: (parent.height / 2) - 30
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottomMargin: (parent.height / 2) + 50
      Timer { id: erasePassInfoTimer; interval: 2000 }
      text: (!erasePassInfoTimer.running)
      ? "Please authenticate to confirm the action."
      : "Wrong passphrase, please try again"
    }

    AVMEInput {
      id: erasePassInput
      width: parent.width / 2
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: erasePassInfo.bottom
      anchors.topMargin: 30
      echoMode: TextInput.Password
      passwordCharacter: "*"
      label: "Passphrase"
      placeholder: "Your Wallet's passphrase"
    }

    yesBtn.onClicked: {
      if (System.checkWalletPass(erasePassInput.text)) {
        if (System.eraseAccount(walletList.currentItem.itemAccount)) {
          console.log("Account erased successfully")
          erasePopup.close()
          erasePopup.account = ""
          erasePassInput.text = ""
          fetchAccountsPopup.open()
          System.refreshAccounts()
        } else {
          erasePopup.close()
          erasePopup.account = ""
          erasePassInput.text = ""
          eraseFailPopup.open()
        }
      } else {
        erasePassInfoTimer.start()
      }
    }
    noBtn.onClicked: {
      erasePopup.account = ""
      erasePassInput.text = ""
      erasePopup.close()
    }
  }
}

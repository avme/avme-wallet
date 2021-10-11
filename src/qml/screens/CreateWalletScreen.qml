/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

// Screen for creating/importing a Wallet
Item {
  id: createWalletScreen
  property alias folder: createFolderInput.text
  property alias pass: createPassInput.text
  property alias createBtn: btnCreate
  property alias saveWallet: saveWalletCheck.checked
  property string seed: seedPopup.fullSeed
  property bool walletExists

  Connections {
    target: qmlSystem
    function onWalletCreated(success) {
      if (success) {
        window.infoPopup.info = "Loading Wallet,<br>please wait..."
        if (qmlSystem.isWalletLoaded()) { qmlSystem.closeWallet() }
        qmlSystem.loadWallet(folder, pass)
      } else {
        window.infoPopup.close()
        errorPopup.info = "Could not " + ((seed) ? "import" : "create")
        + " the Wallet.<br>Please try again."
        errorPopup.open()
      }
    }
    function onWalletLoaded(success) {
      window.menu.walletIsLoaded = success
      accountHeader.currentAddress = ""
      if (success) {
        qmlSystem.cleanAndCloseWallet()
        qmlSystem.setLedgerFlag(false)
        qmlSystem.deleteLastWalletPath()
        if (saveWallet) { qmlSystem.saveLastWalletPath() }
        window.infoPopup.info = "Creating an Account<br>for the new Wallet..."
        qmlSystem.createAccount(seed, 0, "default", pass)
      } else {
        window.infoPopup.close()
        errorPopup.info = "Could not load the Wallet.<br>Please try loading it manually."
        errorPopup.open()
      }
    }
    function onAccountCreated(success, data) {
      if (success) {
        window.infoPopup.close()
        qmlSystem.setCurrentAccount(data.accAddress)
        newWalletSeedPopup.showSeed(pass)
        newWalletSeedPopup.open()
      } else {
        window.infoPopup.close()
        errorPopup.info = "Could not create an Account automatically.<br>Please try creating it manually."
        errorPopup.goToAccounts = true
        errorPopup.open()
      }
    }
  }

  Component.onCompleted: {
    createFolderInput.text = qmlSystem.getDefaultWalletPath()
    walletExists = qmlSystem.checkFolderForWallet(createFolderInput.text)
    createPassInput.forceActiveFocus()
  }

  function createWallet() {
    window.infoPopup.info = ((seed) ? "Importing" : "Creating") + " Wallet,<br>please wait..."
    window.infoPopup.open()
    qmlSystem.createWallet(folder, pass, seed)
  }

  AVMEPanel {
    id: createPanel
    width: (parent.width * 0.6)
    height: (parent.height * 0.75)
    anchors.centerIn: parent
    title: ""

    Column {
      id: items
      width: parent.width
      anchors.verticalCenter: parent.verticalCenter
      spacing: 30

      // Enter/Return key override
      Keys.onPressed: {
        if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
          if (createBtn.enabled) { createWallet() }
        }
      }

      Text {
        id: info
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Enter the following details to create a Wallet."
      }

      Row {
        id: createFolderRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AVMEInput {
          id: createFolderInput
          width: (items.width * 0.9) - (createFolderDialogBtn.width + parent.spacing)
          readOnly: true
          label: "Wallet folder"
          placeholder: "Your Wallet's top folder"
        }
        AVMEButton {
          id: createFolderDialogBtn
          width: (items.width * 0.1)
          height: createFolderInput.height
          text: ""
          onClicked: createFolderDialog.visible = true
          AVMEAsyncImage {
            anchors.fill: parent
            anchors.margins: 5
            loading: false
            imageSource: "qrc:/img/icons/folder.png"
          }
        }
        FolderDialog {
          id: createFolderDialog
          title: "Choose your Wallet folder"
          onAccepted: {
            createFolderInput.text = qmlSystem.cleanPath(createFolderDialog.folder)
            walletExists = qmlSystem.checkFolderForWallet(createFolderInput.text)
          }
        }
      }

      Row {
        id: seedRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 5

        Text {
          id: seedLabel
          width: (items.width * 0.9) - (seedBtn.width + parent.spacing)
          height: seedBtn.height * 1.5
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          wrapMode: Text.WordWrap
          elide: Text.ElideRight
          color: "#FFFFFF"
          font.pixelSize: 14.0
          text: (seed != "") ? seed : "No seed is being used"
        }
        AVMEButton {
          id: seedBtn
          width: (items.width * 0.1)
          height: createFolderDialogBtn.height
          anchors.verticalCenter: seedLabel.verticalCenter
          text: ""
          onClicked: seedPopup.open()
          AVMEAsyncImage {
            anchors.fill: parent
            anchors.margins: 5
            loading: false
            imageSource: "qrc:/img/icons/seed.png"
          }
        }
      }

      Row {
        id: createPassRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AVMEInput {
          id: createPassInput
          width: (items.width * 0.9) - (createPassViewBtn.width + parent.spacing)
          echoMode: (createPassViewBtn.view) ? TextInput.Normal : TextInput.Password
          passwordCharacter: "*"
          label: "Passphrase"
          placeholder: "Your Wallet's passphrase"
        }
        AVMEButton {
          id: createPassViewBtn
          property bool view: false
          width: (items.width * 0.1)
          height: createPassInput.height
          text: ""
          onClicked: view = !view
          AVMEAsyncImage {
            anchors.fill: parent
            anchors.margins: 5
            loading: false
            imageSource: (parent.view)
            ? "qrc:/img/icons/eye-f.png" : "qrc:/img/icons/eye-close-f.png"
          }
        }
      }

      Row {
        id: createPassCheckRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AVMEInput {
          id: createPassCheckInput
          width: (items.width * 0.9) - (createPassCheckIcon.width + parent.spacing)
          echoMode: (createPassViewBtn.view) ? TextInput.Normal : TextInput.Password
          passwordCharacter: "*"
          label: "Confirm passphrase"
          placeholder: "Your Wallet's passphrase"
        }

        AVMEAsyncImage {
          id: createPassCheckIcon
          width: (items.width * 0.1)
          height: createPassCheckInput.height
          loading: false
          imageSource: {
            if (createPassInput.text == "" || createPassCheckInput.text == "") {
              imageSource: ""
            } else if (createPassInput.text == createPassCheckInput.text) {
              imageSource: "qrc:/img/ok.png"
            } else {
              imageSource: "qrc:/img/no.png"
            }
          }
        }
      }

      AVMECheckbox {
        id: saveWalletCheck
        checked: false
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Always open this Wallet at startup"
        tooltipText: "Checking this will automatically open this Wallet"
        + "<br>when the program starts, until it is closed manually."
      }

      AVMEButton {
        id: btnCreate
        width: (items.width * 0.9)
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (
          createFolderInput.text != "" && createPassInput.text != ""
          && createPassCheckInput.text != "" && !walletExists
          && createPassInput.text == createPassCheckInput.text
        )
        text: {
          if (walletExists) {
            text: "Wallet exists in given folder"
          } else if (createPassInput.text != createPassCheckInput.text) {
            text: "Passphrases don't match"
          } else {
            text: (seed == "") ? "Create Wallet" : "Import Wallet"
          }
        }
        onClicked: createWallet()
      }
    }
  }

  AVMEPopupSeed { id: seedPopup }
  AVMEPopupInfo { // Overriding default popup actions
    id: errorPopup
    property bool goToAccounts: false
    icon: "qrc:/img/warn.png"
    okBtn.onClicked: {
      errorPopup.close()
      if (goToAccounts) {
        qmlSystem.loadAccounts()
        qmlSystem.startWSServer()
        window.menu.changeScreen("Accounts")
      }
    }
  }
  AVMEPopupNewWalletSeed {
    id: newWalletSeedPopup
    widthPct: 0.9
    heightPct: 0.5
    okBtn.onClicked: {
      newWalletSeedPopup.clean()
      newWalletSeedPopup.close()
      qmlSystem.loadTokenDB()
      qmlSystem.loadHistoryDB(qmlSystem.getCurrentAccount())
      qmlSystem.loadAppDB()
      qmlSystem.loadAddressDB()
      qmlSystem.loadConfigDB()
      qmlSystem.loadPermissionList()
      qmlSystem.loadARC20Tokens()
      accountHeader.getAddress()
      window.menu.changeScreen("Overview")
    }
  }
}

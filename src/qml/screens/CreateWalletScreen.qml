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
  property bool createAndLoad

  Connections {
    target: qmlSystem
    function onWalletCreated(success) {
      createAndLoad = true
      if (success) {
        window.infoPopup.info = "Loading Wallet,<br>please wait..."
        if (qmlSystem.isWalletLoaded()) { qmlSystem.closeWallet() }
        qmlSystem.loadWallet(folder, pass)
      } else {
        window.infoPopup.close()
        errorPopup.info = (seed)
          ? "Error on Wallet importing."
          : "Error on Wallet creation."
        errorPopup.open()
      }
    }
    function onWalletLoaded(success) {
      if (success) {
        qmlSystem.setLedgerFlag(false)
        qmlSystem.deleteLastWalletPath()
        if (saveWallet) { qmlSystem.saveLastWalletPath() }
        window.infoPopup.info = "Creating an Account<br>for the new Wallet..."
        qmlSystem.createAccount(seed, 0, "default", pass)
      } else {
        window.infoPopup.close()
        errorPopup.info = "Error on Wallet loading.<br>Please try loading it manually."
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
        // TODO: this is a silent fail, we should avoid that
        window.infoPopup.close()
        qmlSystem.cleanAndClose()
        qmlSystem.loadAccounts()
        qmlSystem.startWSServer()
        window.menu.changeScreen("Accounts")
        // TODO: also a silent fail in a way, if it fails it should just go straight to the Accounts screen
        //window.infoPopup.close()
        //errorPopup.info = "Error on Account creation."
        //errorPopup.open()
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
    height: (parent.height * 0.8)
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
          Image {
            anchors.fill: parent
            anchors.margins: 5
            source: "qrc:/img/icons/folder.png"
            antialiasing: true
            smooth: true
            fillMode: Image.PreserveAspectFit
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
          Image {
            anchors.fill: parent
            anchors.margins: 5
            source: "qrc:/img/icons/seed.png"
            antialiasing: true
            smooth: true
            fillMode: Image.PreserveAspectFit
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
          Image {
            anchors.fill: parent
            anchors.margins: 5
            source: (parent.view) ? "qrc:/img/icons/eye-f.png" : "qrc:/img/icons/eye-close-f.png"
            antialiasing: true
            smooth: true
            fillMode: Image.PreserveAspectFit
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

        Image {
          id: createPassCheckIcon
          width: (items.width * 0.1)
          height: createPassCheckInput.height
          antialiasing: true
          smooth: true
          fillMode: Image.PreserveAspectFit
          source: {
            if (createPassInput.text == "" || createPassCheckInput.text == "") {
              source: ""
            } else if (createPassInput.text == createPassCheckInput.text) {
              source: "qrc:/img/ok.png"
            } else {
              source: "qrc:/img/no.png"
            }
          }
        }
      }

      CheckBox {
        id: saveWalletCheck
        checked: false
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Always open this Wallet at startup"
        contentItem: Text {
          text: parent.text
          font.pixelSize: 14.0
          color: parent.checked ? "#FFFFFF" : "#888888"
          verticalAlignment: Text.AlignVCenter
          leftPadding: parent.indicator.width + parent.spacing
        }
        ToolTip {
          id: saveWalletTooltip
          visible: parent.hovered
          delay: 500
          text: "Checking this will automatically open this Wallet"
          + "<br>when the program starts, until it is closed manually."
          contentItem: Text {
            font.pixelSize: 12.0
            color: "#FFFFFF"
            text: saveWalletTooltip.text
          }
          background: Rectangle { color: "#1C2029" }
        }
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
  AVMEPopupInfo { id: errorPopup; icon: "qrc:/img/warn.png" }
  AVMEPopupNewWalletSeed {
    id: newWalletSeedPopup
    widthPct: 0.9
    heightPct: 0.5
    okBtn.onClicked: {
      newWalletSeedPopup.clean()
      newWalletSeedPopup.close()
      qmlSystem.cleanAndClose()
      qmlSystem.loadTokenDB()
      qmlSystem.loadHistoryDB(qmlSystem.getCurrentAccount())
      qmlSystem.loadAppDB()
      qmlSystem.loadAddressDB()
      qmlSystem.loadConfigDB()
      qmlSystem.loadARC20Tokens()
      accountHeader.getAddress()
      window.menu.changeScreen("Overview")
    }
  }
}

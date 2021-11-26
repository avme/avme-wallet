/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

import QmlApi 1.0

// Popup for confirming a transaction with user input.
AVMEPopup {
  id: confirmSignPopup
  widthPct: 0.7
  heightPct: 0.6
  property alias pass: passInput.text
  property alias passFocus: passInput.focus
  property alias timer: infoTimer
  property alias okBtn: btnOk
  property alias backBtn: btnBack
  property string address
  property string message
  property bool isWebserver: false
  property bool userHasSigned: false
  property int requestType: 0

  onAboutToShow: {
    if (qmlSystem.getLedgerFlag()) {  // Ledger doesn't need password
      passInfo.visible = passInput.visible = false
      btnOk.enabled = true  // This "workaround" is done due to a confirmTx component
                            // being located on accountHeader
                            // Which is loaded on the wallet
                            // Setting itself enabled to be always the second condition of the
                            // ternary operator.
    } else {
      if (+qmlSystem.getConfigValue("storePass") > 0) { // Set to store pass
        passInput.text = qmlSystem.retrievePass()
        if (passInput.text == "") { // Pass wasn't stored (first time)
          passInfo.visible = passInput.visible = true
          passInput.forceActiveFocus()
        } else {  // Pass was stored
          passInfo.visible = passInput.visible = false
        }
      } else {  // NOT set to store pass
        passInfo.visible = passInput.visible = true
        passInput.forceActiveFocus()
      }
    }
  }
  onAboutToHide: confirmSignPopup.clean()

  Timer { id: ledgerRetryTimer; interval: 125; onTriggered: checkLedger() }

  Connections {
    target: qmlSystem
    function onMessageSigned(signature, webServer) {
      if (isWebserver) {
        if (webServer) {
          userHasSigned = true
          qmlSystem.requestedSignStatus(true, signature)
          confirmSignPopup.close()
        }
      }
    }
  }

  function setData(_address, _message, _requestType) {
    address = _address
    message = _message
    requestType = _requestType
    if (qmlSystem.getLedgerFlag()) {
      checkLedger()
    }
  }

  function checkLedger() {
    var data = qmlSystem.checkForLedger()
    if (data.state) {
      ledgerFailPopup.close()
      ledgerRetryTimer.stop()
    } else {
      ledgerFailPopup.info = data.message
      ledgerFailPopup.open()
      ledgerRetryTimer.start()
    }
  }

  function clean() {
    passInput.text = ""
    if (!userHasSigned) {
      qmlSystem.requestedSignStatus(false, "")
    }
  }

  Column {
    anchors.centerIn: parent
    spacing: 20

    // Enter/Numpad enter key override
    Keys.onPressed: {
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        if (btnOk.enabled) { btnOk.handleConfirm() }
      }
    }

    Text {
      id: summaryHeader
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Sign the following message with the address <br><b>" + address + "</b>:"
    }

    Text {
      id: summaryInfo
      width: (confirmSignPopup.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      wrapMode: Text.WordWrap
      font.bold: true
      font.pixelSize: 14.0
      text: message
    }

    Text {
      id: passInfo
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: (!infoTimer.running)
      ? "Please authenticate to confirm this signature."
      : "Wrong passphrase, please try again."
      Timer { id: infoTimer; interval: 2000 }
    }

    AVMEInput {
      id: passInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: confirmSignPopup.width / 2
      echoMode: TextInput.Password
      passwordCharacter: "*"
      label: "Passphrase"
      placeholder: "Your Wallet's passphrase"
    }

    Row {
      id: btnRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btnBack
        text: "Back"
        onClicked: confirmSignPopup.close()
      }

      AVMEButton {
        id: btnOk
        text: "Ok"
        enabled: (qmlSystem.getLedgerFlag()) ? true : (passInput.text !== "")
        onClicked: handleConfirm()
        function handleConfirm() {
          if (!qmlSystem.checkWalletPass(passInput.text) && !qmlSystem.getLedgerFlag()) {
            infoTimer.start()
          } else {
            // Store the password in memory if prompted by the user and not stored yet
            if (+qmlSystem.getConfigValue("storePass") > 0 && qmlSystem.retrievePass() == "") {
              qmlSystem.storePass(passInput.text)
            }
            // TODO: Sign Message
            qmlSystem.signMessage(address, message, pass, isWebserver, requestType)

          }
        }
      }
    }
  }

  // Info popup for if communication with Ledger fails
  AVMEPopupInfo {
    id: ledgerFailPopup
    widthPct: 0.6
    heightPct: 0.4
    icon: "qrc:/img/warn.png"
    onAboutToHide: ledgerRetryTimer.stop()
    okBtn.text: "Close"
  }
}

/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

import QmlApi 1.0

// Popup for confirming a transaction with user input.
AVMEPopup {
  id: confirmTxPopup
  widthPct: 0.7
  heightPct: 0.6
  property string info
  property string fullInfo: info
    + "<br>Gas Limit: <b> " + gas + "</b>"
    + "<br>Gas Price: <b>" + gasPrice + "</b>"
    + "<br>Fee Cost: <b>"
    + qmlApi.weiToFixedPoint(qmlApi.mul(qmlApi.fixedPointToWei(gasPrice, 9),gas),18)
    + " AVAX</b>"
  property alias pass: passInput.text
  property alias passFocus: passInput.focus
  property alias timer: infoTimer
  property alias okBtn: btnOk
  property alias backBtn: btnBack
  property string from
  property string operation // For usage under history
  property string to
  property string value // Not WEI value!
  property string txData
  property string gas: "0" // gasLimit // Initialize value to not throw bad_lexical_cast when starting the wallet
  property string gasPrice: "0" // GWEI value, dynamic
  property string randomID: ""
  property string failReason: ""
  property bool loadingFees
  property bool automaticGas
  property bool isSameAddress: false

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
  onAboutToHide: confirmTxPopup.clean()

  Timer { id: ledgerRetryTimer; interval: 125; onTriggered: checkLedger() }

  Connections {
    target: qmlApi
    function onApiRequestAnswered(answer, requestID) {
      // randomID is used so it doesn't trigged other popups connections
      if (requestID == "PopupConfirmTxGas_"+randomID) {
        var answerJson = JSON.parse(answer)
        var txStructure = ({});
        txStructure["operation"] = operation
        txStructure["to"] = to
        txStructure["value"] = value
        txStructure["txData"] = txData
        txStructure["gas"] = gas
        txStructure["gasPrice"] = gasPrice
        txStructure["API ANSWER"] = answer
        qmlApi.logToDebug(JSON.stringify(txStructure))

        if (!answerJson[0]["result"]) {
          if (answerJson[0]["error"]["message"].includes("max fee per gas less than block base fee")) {
            calculateGas(true)
          } else {
            failReason = answerJson[0]["error"]["message"];
            transactionFailPopup.open();
            loadingFees = false
          }
        } else {
         gas = qmlApi.floor(qmlApi.mul(qmlApi.parseHex(answerJson[0]["result"], ["uint"]), 1.1))
         loadingFees = false
        }
      }
    }
  }

  function calculateGas(raiseGas) {
    randomID = qmlApi.getRandomID()
    if (raiseGas) {
      gasPrice = qmlApi.sum(gasPrice, 30)
    }
    if (+gasPrice < +accountHeader.gasPrice) {
      gasPrice = qmlApi.sum(accountHeader.gasPrice, 30)
    }
    if (+gasPrice > 1000) {
      gasPrice = 1000
    }
    if (automaticGas) {
      loadingFees = true
      var Params = ({})
      Params["from"] = from
      Params["to"] = to
      Params["gas"] = "0x" + qmlApi.uintToHex(gas, false)
      Params["gasPrice"] = "0x" + qmlApi.uintToHex(qmlApi.fixedPointToWei(gasPrice, 9), false)
      Params["value"] = "0x" + qmlApi.uintToHex(qmlApi.fixedPointToWei(value, 18), false)
      Params["data"] = txData
      qmlApi.buildGetEstimateGasLimitReq(JSON.stringify(Params), "PopupConfirmTxGas_"+randomID)
      qmlApi.doAPIRequests("PopupConfirmTxGas_"+randomID)
    }
    return
  }

  function setData(inputTo, inputValue, inputTxData, inputGas, inputGasPrice, inputAutomaticGas, inputInfo, inputHistoryInfo) {
    from = qmlSystem.getCurrentAccount()
    to = inputTo
    value = inputValue
    txData = inputTxData
    gas = inputGas
    gasPrice = inputGasPrice // Avoid err: max fee per gas less than block base fee:
    info = inputInfo
    operation = inputHistoryInfo
    automaticGas = inputAutomaticGas
    if (!qmlSystem.getLedgerFlag()) {
      calculateGas(false)
    } else {
      checkLedger()
    }
  }

  function checkLedger() {
    var data = qmlSystem.checkForLedger()
    if (data.state) {
      ledgerFailPopup.close()
      ledgerRetryTimer.stop()
      calculateGas(false)
    } else {
      ledgerFailPopup.info = data.message
      ledgerFailPopup.open()
      ledgerRetryTimer.start()
    }
  }

  function clean() {
    passInput.text = ""
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
      id: warningText
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.bold: true
      font.pixelSize: 14.0
      visible: (isSameAddress)
      text: "ATTENTION: receiver Account is the exact same as the sender.<br>"
      + "If this is not what you want, go back now and set another Account as the receiver."
    }

    Text {
      id: summaryInfo
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: fullInfo
    }

    AVMEAsyncImage {
      id: loadingPng
      width: 50
      height: 50
      anchors.horizontalCenter: parent.horizontalCenter
      visible: loadingFees
      imageSource: "qrc:/img/icons/loading.png"
      RotationAnimator {
        target: loadingPng
        from: 0
        to: 360
        duration: 1000
        loops: Animation.Infinite
        easing.type: Easing.InOutQuad
        running: loadingFees
      }
    }

    Text {
      id: passInfo
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: (!infoTimer.running)
      ? "Please authenticate to confirm this transaction."
      : "Wrong passphrase, please try again."
      Timer { id: infoTimer; interval: 2000 }
    }

    AVMEInput {
      id: passInput
      anchors.horizontalCenter: parent.horizontalCenter
      width: confirmTxPopup.width / 2
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
        onClicked: confirmTxPopup.close()
      }

      AVMEButton {
        id: btnOk
        text: "Ok"
        enabled: (qmlSystem.getLedgerFlag()) ? true : (passInput.text !== "" && !loadingFees)
        onClicked: handleConfirm()
        function handleConfirm() {
          if (!qmlSystem.checkWalletPass(passInput.text) && !qmlSystem.getLedgerFlag()) {
            infoTimer.start()
          } else {
            // Store the password in memory if prompted by the user and not stored yet
            if (+qmlSystem.getConfigValue("storePass") > 0 && qmlSystem.retrievePass() == "") {
              qmlSystem.storePass(passInput.text)
            }
            // txStart needs to happen before close, otherwise the password input
            // will be cleaned before being used to start the transaction
            txProgressPopup.txStart(
              operation, from, to, value, txData, gas, gasPrice, passInput.text, randomID
            )
            confirmTxPopup.close()
            txProgressPopup.open()
          }
        } // TODO: add an error handler for insufficient balance (edge case)
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

  AVMEPopupInfo {
    id: transactionFailPopup
    widthPct: 0.8
    heightPct: 0.8
    icon: "qrc:/img/warn.png"
    info: "Transaction likely to fail,<br>please check your input."
    Rectangle {
	  color: "#0f0c18"
      anchors.verticalCenter: parent.verticalCenter
	  anchors.horizontalCenter: parent.horizontalCenter
      radius: 5
      width: parent.width * 0.8
      height: parent.height * 0.33
	  Text {
	  	id: failedTransactionText
		anchors.verticalCenter: parent.verticalCenter
		anchors.horizontalCenter: parent.horizontalCenter
		height: parent.height * 0.9
		width: parent.width * 0.9
		text: "Reason: " + failReason
		horizontalAlignment: Text.AlignHCenter 
		verticalAlignment: Text.AlignVCenter 
      	color: "#FFFFFF"
      	font.pixelSize: 12.0
		wrapMode: Text.Wrap
	  }
    }
    okBtn.text: "Close"
  }
}

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
  widthPct: 0.6
  heightPct: 0.6
  property string info
  property string fullInfo: info
    + "<br>Gas Limit: <b> " + gas + " AVAX</b>"
    + "<br>Gas Price: <b>" + gasPrice + "</b>"
  property alias pass: passInput.text
  property alias passFocus: passInput.focus
  property alias timer: infoTimer
  property alias okBtn: btnOk
  property string from: qmlSystem.getCurrentAccount()
  property string operation // For usage under history
  property string to
  property string value // Not WEI value!
  property string txData
  property string gas // gasLimit
  property string gasPrice // GWEI value, dynamic
  property string randomID: ""
  property bool loadingFees
  property bool automaticGas
  property bool isSameAddress: false
  onAboutToShow: passInput.focus = true
  onAboutToHide: confirmTxPopup.clean()

  Timer { id: ledgerRetryTimer; interval: 125; onTriggered: checkLedger() }

  Connections {
    target: qmlApi
    function onApiRequestAnswered(answer, requestID) {
      // randomID is used so it doesn't trigged other popups connections
      if (requestID == "PopupConfirmTxGas_"+randomID) {
        var answerJson = JSON.parse(answer)
        if (!answerJson[0]["result"]) {
          if (answerJson[0]["error"]["message"].includes("max fee per gas less than block base fee")) {
            calculateGas(true)
          } else {
            var error;
            error["operation"] = operation
            error["to"] = to
            error["value"] = value
            error["txData"] = txData
            error["gas"] = gas
            error["gasPrice"] = gasPrice 
            error["API ERROR"] = answerJson 
            qmlApi.logToDebug(JSON.stringify(logToDebug))
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
    if (+gasPrice > 225) {
      gasPrice = 225
    }
    if (automaticGas) {
      loadingFees = true
      var Params = ({})
      Params["from"] = from
      Params["to"] = to
      Params["gas"] = "0x" + qmlApi.uintToHex(gas)
      Params["gasPrice"] = "0x" + qmlApi.uintToHex(qmlApi.fixedPointToWei(gasPrice, 9))
      Params["value"] = "0x" + qmlApi.uintToHex(qmlApi.fixedPointToWei(value, 18))
      Params["data"] = txData
      qmlApi.buildGetEstimateGasLimitReq(JSON.stringify(Params), "PopupConfirmTxGas_"+randomID)
      qmlApi.doAPIRequests("PopupConfirmTxGas_"+randomID)
    }
    return
  }

  function setData(inputTo, inputValue, inputTxData, inputGas, inputGasPrice, inputAutomaticGas, inputInfo, inputHistoryInfo) {
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

    Image {
      id: loadingPng
      height: 50
      width: 50
      anchors.horizontalCenter: parent.horizontalCenter
      fillMode: Image.PreserveAspectFit
      visible: loadingFees
      source: "qrc:/img/icons/loading.png"
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
      visible: (qmlSystem.getLedgerFlag()) ? false : true
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
      visible: (qmlSystem.getLedgerFlag()) ? false : true
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
        text: "OK"
        enabled: (qmlSystem.getLedgerFlag()) ? true : (passInput.text !== "" && !loadingFees)
        onClicked: {
          if (!qmlSystem.checkWalletPass(passInput.text) && !qmlSystem.getLedgerFlag()) {
            infoTimer.start()
          } else {
            // You have to provide the information before closing the popup
            // Otherwise, the passInput.text will be equal to ""
            qmlSystem.txStart(
              operation, from, to, value, txData, gas, gasPrice, passInput.text
            )
            confirmTxPopup.close()
            txProgressPopup.open()
          }
        }// TODO: ADD A ERROR HANDLER FOR INSUFICIENT BALANCE!!!
      }
    }
  }

  // Info popup for if communication with Ledger fails
  AVMEPopupInfo {
    id: ledgerFailPopup
    icon: "qrc:/img/warn.png"
    onAboutToHide: ledgerRetryTimer.stop()
    okBtn.text: "Close"
  }

  AVMEPopupInfo {
    id: transactionFailPopup
    icon: "qrc:/img/warn.png"
    info: "Transaction Likely to fail, please check your input"
    okBtn.text: "Close"
  }
}

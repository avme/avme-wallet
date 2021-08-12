/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Popup for confirming a transaction with user input.
AVMEPopup {
  id: confirmTxPopup
  widthPct: 0.6
  heightPct: 0.6
  property string info
  property string fullInfo: info + "<br>Gas Limit: <b> " + gas + " AVAX </b>" + "<br> Gas Price: <b>" + gasPrice + "<\b>"
  property alias pass: passInput.text
  property alias passFocus: passInput.focus
  property alias timer: infoTimer
  property alias okBtn: btnOk
  property string from: qmlSystem.getCurrentAccount()
  property string historyInfo
  property string to
  property string value // Not WEI value!
  property string txData
  property string gas // gasLimit
  property string gasPrice // GWEI value, 225
  property bool loadingFees
  property bool automaticGas 
  property bool isSameAddress: false
  onAboutToShow: passInput.focus = true
  onAboutToHide: confirmTxPopup.clean()

  Connections {
    target: qmlApi
      function onApiRequestAnswered(answer, requestID) {
        if (requestID == "PopupConfirmTxGas") {
          var answerJson = JSON.parse(answer)
          gas = Math.round(+qmlApi.uintFromHex(answerJson[0]["result"]) * 1.1)
          loadingFees = false
        }
      }
  }

  function setData(inputTo, inputValue, inputTxData, inputGas, inputGasPrice, automaticGas, inputInfo, inputHistoryInfo) {
    to = inputTo
    value = inputValue
    txData = inputTxData
    gas = inputGas
    gasPrice = inputGasPrice
    info = inputInfo
    historyInfo = inputHistoryInfo
    if (automaticGas) {
      loadingFees = true
      var Params = ({})
      Params["from"] = from
      Params["to"] = inputTo
      Params["gas"] = "0x" + qmlApi.uintToHex(inputGas)
      Params["gasPrice"] = "0x" + qmlApi.uintToHex(+inputGasPrice * 10 * 9)
      Params["value"] = "0x" + qmlApi.uintToHex(qmlApi.fixedPointToWei(inputValue, 18))
      Params["data"] = inputTxData
      qmlApi.buildGetEstimateGasLimitReq(JSON.stringify(Params), "PopupConfirmTxGas")
      qmlApi.doAPIRequests("PopupConfirmTxGas")
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
        text: "OK"
        enabled: (passInput.text !== "" && !loadingFees)
      }
    }
  }
}

/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Popup for showing the progress of a transaction. Has to be opened manually.
AVMEPopup {
  id: txProgressPopup
  widthPct: 0.9
  heightPct: 0.9
  property color popupBgColor: "#1C2029"
  property bool requestedFromWS: false
  property bool alreadyTransmitted: false

  // Store the data in case we need to retry the transaction
  property string operation
  property string from
  property string to
  property string value
  property string txData
  property string gas
  property string gasPrice
  property string pass
  property string nonce
  property string randomID

  Connections {
    target: qmlSystem
    function onTxBuilt(b, randomID_) {
      if (randomID == randomID_) {
        buildPngRotate.stop()
        buildPng.rotation = 0
        if (b) {
          buildText.color = "limegreen"
          buildText.text = "Transaction built!"
          buildPng.imageSource = "qrc:/img/ok.png"
          signText.color = "#FFFFFF"
          signPngRotate.start()
        } else {
          buildText.color = "crimson"
          buildText.text = "Error on building transaction."
          buildPng.imageSource = "qrc:/img/no.png"
          btnClose.visible = true
          btnRetry.visible = false
        }
      }
    }
    function onTxSigned(b, msg, randomID_) {
      if (randomID == randomID_) {
        signPngRotate.stop()
        signPng.rotation = 0
        if (b) {
          signText.color = "limegreen"
          signText.text = msg
          signPng.imageSource = "qrc:/img/ok.png"
          sendText.color = "#FFFFFF"
          sendPngRotate.start()
        } else {
          signText.color = "crimson"
          signText.text = msg
          signPng.imageSource = "qrc:/img/no.png"
          btnClose.visible = true
          btnRetry.visible = false
          qmlApi.logToDebug("Transaction Error: " + msg)
        }
      }
    }
    function onTxSent(b, linkUrl, txid, msg, randomID_) {
      if (randomID == randomID_) {
        sendPngRotate.stop()
        sendPng.rotation = 0
        if (b) {
          btnOpenLink.linkUrl = linkUrl
          sendText.color = "limegreen"
          sendText.text = "Transaction sent!"
          sendPng.imageSource = "qrc:/img/ok.png"
          confirmText.color = "#FFFFFF"
          confirmPngRotate.start()
          btnOpenLink.visible = true
          qmlSystem.checkTransactionFor15s(txid, randomID);
        } else {
          sendText.color = "crimson"
          sendText.text = "Error on sending transaction.<br> " + msg
          sendPng.imageSource = "qrc:/img/no.png"
          btnClose.visible = true
          btnRetry.visible = true
          qmlApi.logToDebug("Transaction Error: " + msg)
        }
      }
    }
    function onTxConfirmed(b, txid, randomID_) {
      if (randomID == randomID_) {
        confirmPngRotate.stop()
        confirmPng.rotation = 0
        if (b) {
          confirmText.color = "limegreen"
          confirmText.text = "Transaction confirmed!"
          confirmPng.imageSource = "qrc:/img/ok.png"
          if (requestedFromWS) {
            qmlSystem.requestedTransactionStatus(true, txid)
            alreadyTransmitted = true
          }
          qmlSystem.updateAccountNonce(from);
        } else {
          confirmText.color = "crimson"
          confirmText.text = "Transaction not confirmed.<br><b>Retrying will attempt a higher fee. (Recommended)</b>"
          confirmPng.imageSource = "qrc:/img/no.png"
          btnRetry.visible = true
        }
        btnClose.visible = true
      }
    }
    function onTxRetry(randomID_) {
    if (randomID == randomID_) {
        sendText.text = "Transaction nonce is too low, or a transaction with"
        + "<br>the same hash was already imported. Retrying..."
      }
      function onLedgerRequired(randomID) {
        if (randomID == randomID_) {
          ledgerStatusPopup.open()
        }
      }
      function onLedgerDone(randomID) {
        if (randomID == randomID_) {
          ledgerStatusPopup.close()
        }
      }
    }
  }

  function resetStatuses() {
    buildText.color = "#FFFFFF"
    signText.color = "#444444"
    sendText.color = "#444444"
    confirmText.color = "#444444"
    buildText.text = "Building transaction..."
    signText.text = "Signing transaction..."
    sendText.text = "Broadcasting transaction..."
    confirmText.text = "Confirming transaction..."
    buildPng.imageSource = "qrc:/img/icons/loading.png"
    signPng.imageSource = "qrc:/img/icons/loading.png"
    sendPng.imageSource = "qrc:/img/icons/loading.png"
    confirmPng.imageSource = "qrc:/img/icons/loading.png"
    buildPngRotate.start()
    btnOpenLink.visible = false
    btnClose.visible = false
    btnRetry.visible = false
  }

  function txStart(
    operation_, from_, to_, value_, txData_, gas_, gasPrice_, pass_, randomID_
  ) {
    operation = operation_
    from = from_
    to = to_
    value = value_
    txData = txData_
    gas = gas_
    gasPrice = gasPrice_
    pass = pass_
    nonce = accountHeader.accountNonce
    // Uncomment to see the data passed to the popup
    // console.log(operation)
    // console.log(from)
    // console.log(to)
    // console.log(value)
    // console.log(txData)
    // console.log(gas)
    // console.log(gasPrice)
    if (+gasPrice > 225) {
      gasPrice = 225
    }
    resetStatuses()
    alreadyTransmitted = false;
    qmlSystem.makeTransaction(
      operation, from, to, value, txData, gas, gasPrice, pass, nonce, randomID
    )
  }

  Column {
    id: items
    anchors {
      centerIn: parent
      margins: 30
    }
    spacing: 20

    // Enter/Numpad enter key override
    Keys.onPressed: {
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        if (btnClose.visible) {
          if (!alreadyTransmitted) {
            // Unlock the mutex if the transaction was not transmitted to the plugin
            console.log("unlocking mutex")
            qmlSystem.requestedTransactionStatus(false, "")
            txProgressPopup.close()
          } else {
            txProgressPopup.close()
          }
        }
      }
    }

    Row {
      id: buildRow
      anchors.horizontalCenter: parent.horizontalCenter
      height: 70
      spacing: 40

      AVMEAsyncImage {
        id: buildPng
        width: 64
        height: 64
        anchors.verticalCenter: buildText.verticalCenter
        loading: false
        imageSource: "qrc:/img/icons/loading.png"
        RotationAnimator {
          id: buildPngRotate
          target: buildPng
          from: 0
          to: 360
          duration: 1000
          loops: Animation.Infinite
          easing.type: Easing.InOutQuad
          running: false
        }
      }

      Text {
        id: buildText
        font.pixelSize: 24.0
        color: "#FFFFFF"
        text: "Building transaction..."
      }
    }

    Row {
      id: signRow
      anchors.horizontalCenter: parent.horizontalCenter
      height: 70
      spacing: 40

      AVMEAsyncImage {
        id: signPng
        width: 64
        height: 64
        anchors.verticalCenter: signText.verticalCenter
        loading: false
        imageSource: "qrc:/img/icons/loading.png"
        RotationAnimator {
          id: signPngRotate
          target: signPng
          from: 0
          to: 360
          duration: 1000
          loops: Animation.Infinite
          easing.type: Easing.InOutQuad
          running: false
        }
      }

      Text {
        id: signText
        font.pixelSize: 24.0
        color: "#444444"
        text: "Signing transaction..."
      }
    }

    Row {
      id: sendRow
      anchors.horizontalCenter: parent.horizontalCenter
      height: 70
      spacing: 40

      AVMEAsyncImage {
        id: sendPng
        width: 64
        height: 64
        anchors.verticalCenter: sendText.verticalCenter
        loading: false
        imageSource: "qrc:/img/icons/loading.png"
        RotationAnimator {
          id: sendPngRotate
          target: sendPng
          from: 0
          to: 360
          duration: 1000
          loops: Animation.Infinite
          easing.type: Easing.InOutQuad
          running: false
        }
      }

      Text {
        id: sendText
        font.pixelSize: 24.0
        color: "#444444"
        text: "Broadcasting transaction..."
      }
    }

    Row {
      id: confirmRow
      anchors.horizontalCenter: parent.horizontalCenter
      height: 70
      spacing: 40

      AVMEAsyncImage {
        id: confirmPng
        width: 64
        height: 64
        anchors.verticalCenter: confirmText.verticalCenter
        loading: false
        imageSource: "qrc:/img/icons/loading.png"
        RotationAnimator {
          id: confirmPngRotate
          target: confirmPng
          from: 0
          to: 360
          duration: 1000
          loops: Animation.Infinite
          easing.type: Easing.InOutQuad
          running: false
        }
      }

      Text {
        id: confirmText
        font.pixelSize: 24.0
        color: "#444444"
        text: "Confirming transaction..."
      }
    }
  }

  AVMEButton {
    id: btnOpenLink
    property string linkUrl
    width: parent.width * 0.5
    anchors {
      bottom: btnClose.top
      horizontalCenter: parent.horizontalCenter
      margins: 20
    }
    text: "Open Transaction in Block Explorer"
    onClicked: Qt.openUrlExternally(linkUrl)
  }

  AVMEButton {
    id: btnRetry
    width: parent.width * 0.25
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      horizontalCenterOffset: -150
      margins: 20
    }
    text: "Retry"
    onClicked: {
      var networkGasPrice = accountHeader.gasPrice
      if (+networkGasPrice > +gasPrice) {
        gasPrice = +networkGasPrice + 25
        if (+gasPrice > 225) gasPrice = 225
      }
      txStart(operation, from, to, value, txData, gas, gasPrice, pass, randomID)
      resetStatuses();
    }
  }

  AVMEButton {
    id: btnClose
    width: parent.width * 0.25
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      horizontalCenterOffset: 150
      margins: 20
    }
    text: "Close"
    onClicked: {
      if (!alreadyTransmitted) {
        // Unlock the mutex if the transaction was not transmitted to the plugin
        console.log("unlocking mutex")
        qmlSystem.requestedTransactionStatus(false, "")
        txProgressPopup.close()
      } else {
        txProgressPopup.close()
      }
    }
  }

  AVMEPopupInfo {
    id: ledgerStatusPopup
    icon: "qrc:/img/warn.png"
    info: "Please confirm the transaction on your device."
    okBtn.text: "Close"
  }
}

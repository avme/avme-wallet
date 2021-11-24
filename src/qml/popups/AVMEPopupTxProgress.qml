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
  heightPct: 0.5
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
          buildText.text = "Built!"
          buildPng.imageSource = "qrc:/img/ok.png"
          buildRect.color = "#0B5418"
          signText.color = "#FFFFFF"
          statusRect.width = statusRow.width * 0.33
          signPngRotate.start()
        } else {
          buildText.color = "crimson"
          buildText.text = "Failed to build."
          buildPng.imageSource = "qrc:/img/no.png"
          buildRect.color = "#4F1018"
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
          signText.text = "Signed!"
          signPng.imageSource = "qrc:/img/ok.png"
          signRect.color = "#0B5418"
          sendText.color = "#FFFFFF"
          statusRect.width = statusRow.width * 0.66
          sendPngRotate.start()
        } else {
          signText.color = "crimson"
          signText.text = "Failed to sign."
          signPng.imageSource = "qrc:/img/no.png"
          signRect.color = "#4F1018"
          btnClose.visible = true
          btnRetry.visible = false
          qmlApi.logToDebug("Transaction Error: " + msg)
          msgText.text = msg
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
          sendText.text = "Sent!"
          sendPng.imageSource = "qrc:/img/ok.png"
          sendRect.color = "#0B5418"
          confirmText.color = "#FFFFFF"
          statusRect.width = statusRow.width
          confirmPngRotate.start()
          btnOpenLink.visible = true
          qmlSystem.checkTransactionFor15s(txid, randomID);
        } else {
          sendText.color = "crimson"
          sendText.text = "Failed to send."
          sendPng.imageSource = "qrc:/img/no.png"
          sendRect.color = "#4F1018"
          btnClose.visible = true
          btnRetry.visible = true
          qmlApi.logToDebug("Transaction Error: " + msg)
          msgText.text = msg
        }
      }
    }
    function onTxConfirmed(b, txid, randomID_) {
      if (randomID == randomID_) {
        confirmPngRotate.stop()
        confirmPng.rotation = 0
        if (b) {
          confirmText.color = "limegreen"
          confirmText.text = "Confirmed!"
          confirmPng.imageSource = "qrc:/img/ok.png"
          confirmRect.color = "#0B5418"
          if (requestedFromWS) {
            qmlSystem.requestedTransactionStatus(true, txid)
            alreadyTransmitted = true
          }
          qmlSystem.updateAccountNonce(from);
          btnClose.autoClose.start()
        } else {
          confirmText.color = "crimson"
          confirmText.text = "Failed to confirm."
          confirmPng.imageSource = "qrc:/img/no.png"
          confirmRect.color = "#4F1018"
          btnRetry.visible = true
          msgText.text = "Retrying will attempt a higher fee (recommended)."
        }
        btnClose.visible = true
      }
    }
    function onTxRetry(randomID_) {
    if (randomID == randomID_) {
        msgText.text = "Transaction nonce is too low, or a transaction with"
        + " the same hash was already imported. Retrying..."
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
    buildRect.color = "#0B1018"
    signRect.color = "#0B1018"
    sendRect.color = "#0B1018"
    confirmRect.color = "#0B1018"
    buildText.text = "Building..."
    signText.text = "Signing..."
    sendText.text = "Broadcasting..."
    confirmText.text = "Confirming..."
    buildPng.imageSource = "qrc:/img/icons/loading.png"
    signPng.imageSource = "qrc:/img/icons/loading.png"
    sendPng.imageSource = "qrc:/img/icons/loading.png"
    confirmPng.imageSource = "qrc:/img/icons/loading.png"
    msgText.text = ""
    statusRect.width = 0
    btnClose.secsToClose = 5
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
    if (+gasPrice > 1000) { gasPrice = 1000 }
    resetStatuses()
    alreadyTransmitted = false;
    qmlSystem.makeTransaction(
      operation, from, to, value, txData, gas, gasPrice, pass, nonce, randomID
    )
  }

  Rectangle {
    id: statusRect
    anchors {
      left: statusRow.left
      verticalCenter: statusRow.verticalCenter
    }
    width: 0
    height: 5
    color: "#0B5418"
    Behavior on width {
      NumberAnimation { duration: 1000; easing.type: Easing.OutExpo }
    }
  }

  Row {
    id: statusRow
    anchors {
      horizontalCenter: parent.horizontalCenter
      verticalCenter: parent.verticalCenter
      verticalCenterOffset: -(parent.height * 0.25)
    }
    spacing: 100

    // Enter/Numpad enter key override
    Keys.onPressed: {
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        if (btnClose.visible) {
          if (!alreadyTransmitted) {
            // Unlock the mutex if the transaction was not transmitted to the plugin
            //console.log("unlocking mutex")
            qmlSystem.requestedTransactionStatus(false, "")
            txProgressPopup.close()
          } else {
            txProgressPopup.close()
          }
        }
      }
    }

    Rectangle {
      id: buildRect
      width: 128
      height: 128
      radius: 128
      color: "#0B1018"
      AVMEAsyncImage {
        id: buildPng
        width: 64
        height: 64
        anchors.centerIn: parent
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
        anchors {
          top: parent.bottom
          horizontalCenter: parent.horizontalCenter
          topMargin: 10
        }
        font.pixelSize: 16.0
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        text: "Building..."
      }
    }

    Rectangle {
      id: signRect
      width: 128
      height: 128
      radius: 128
      color: "#0B1018"
      AVMEAsyncImage {
        id: signPng
        width: 64
        height: 64
        anchors.centerIn: parent
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
        anchors {
          top: parent.bottom
          horizontalCenter: parent.horizontalCenter
          topMargin: 10
        }
        font.pixelSize: 16.0
        horizontalAlignment: Text.AlignHCenter
        color: "#444444"
        text: "Signing..."
      }
    }

    Rectangle {
      id: sendRect
      width: 128
      height: 128
      radius: 128
      color: "#0B1018"
      AVMEAsyncImage {
        id: sendPng
        width: 64
        height: 64
        anchors.centerIn: parent
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
        anchors {
          top: parent.bottom
          horizontalCenter: parent.horizontalCenter
          topMargin: 10
        }
        font.pixelSize: 16.0
        horizontalAlignment: Text.AlignHCenter
        color: "#444444"
        text: "Sending..."
      }
    }

    Rectangle {
      id: confirmRect
      width: 128
      height: 128
      radius: 128
      color: "#0B1018"
      AVMEAsyncImage {
        id: confirmPng
        width: 64
        height: 64
        anchors.centerIn: parent
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
        anchors {
          top: parent.bottom
          horizontalCenter: parent.horizontalCenter
          topMargin: 10
        }
        font.pixelSize: 16.0
        horizontalAlignment: Text.AlignHCenter
        color: "#444444"
        text: "Confirming..."
      }
    }
  }

  Text {
    id: msgText
    anchors {
      bottom: btnRow.top
      horizontalCenter: parent.horizontalCenter
      bottomMargin: 20
    }
    font.pixelSize: 14.0
    horizontalAlignment: Text.AlignHCenter
    elide: Text.ElideRight
    color: "#FFFFFF"
  }

  Row {
    id: btnRow
    anchors {
      horizontalCenter: parent.horizontalCenter
      verticalCenter: parent.verticalCenter
      verticalCenterOffset: (parent.height * 0.35)
    }
    spacing: 20

    AVMEButton {
      id: btnRetry
      width: txProgressPopup.width * 0.2
      text: "Retry"
      onClicked: {
        var networkGasPrice = accountHeader.gasPrice
        if (+networkGasPrice > +gasPrice) {
          gasPrice = +networkGasPrice + 25
          if (+gasPrice > 1000) gasPrice = 1000
        }
        txStart(operation, from, to, value, txData, gas, gasPrice, pass, randomID)
        resetStatuses();
      }
    }

    AVMEButton {
      id: btnOpenLink
      property string linkUrl
      width: txProgressPopup.width * 0.4
      text: "Open Transaction in Block Explorer"
      onClicked: Qt.openUrlExternally(linkUrl)
    }

    AVMEButton {
      id: btnClose
      property alias autoClose: autoCloseTimer
      property var secsToClose: 5
      width: txProgressPopup.width * 0.2
      text: (autoCloseTimer.running) ? "Close (" + secsToClose + ")" : "Close"
      Timer {
        id: autoCloseTimer
        interval: 1000
        repeat: true
        onTriggered: {
          if (btnClose.secsToClose <= 0) {
            stop(); txProgressPopup.close()
          }
          btnClose.secsToClose--
        }
      }
      onClicked: {
        if (autoCloseTimer.running) autoCloseTimer.stop()
        if (!alreadyTransmitted) {
          // Unlock the mutex if the transaction was not transmitted to the plugin
          //console.log("unlocking mutex")
          qmlSystem.requestedTransactionStatus(false, "")
          txProgressPopup.close()
        } else {
          txProgressPopup.close()
        }
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

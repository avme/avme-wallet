/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// TODO: This screen needs a redesign to fit the current design
// Popup for showing the progress of a transaction. Has to be opened manually.
Popup {
  id: txProgressPopup
  property color popupBgColor: "#1C2029"

  Connections {
    target: qmlSystem
    function onTxStart(
      operation, from, to, value, txData, gas, gasPrice, pass
    ) {
      // Uncomment to see the data passed to the popup
      //console.log(operation)
      //console.log(from)
      //console.log(to)
      //console.log(value)
      //console.log(txData)
      //console.log(gas)
      //console.log(gasPrice)
      resetStatuses()
      qmlSystem.makeTransaction(
        operation, from, to, value, txData, gas, gasPrice, pass
      )
    }
    function onTxBuilt(b) {
      buildPngRotate.stop()
      buildPng.rotation = 0
      if (b) {
        buildText.color = "limegreen"
        buildText.text = "Transaction built!"
        buildPng.source = "qrc:/img/ok.png"
        signText.color = "#FFFFFF"
        signPngRotate.start()
      } else {
        buildText.color = "crimson"
        buildText.text = "Error on building transaction."
        buildPng.source = "qrc:/img/no.png"
        btnClose.visible = true
      }
    }
    function onTxSigned(b, msg) {
      signPngRotate.stop()
      signPng.rotation = 0
      if (b) {
        signText.color = "limegreen"
        signText.text = msg
        signPng.source = "qrc:/img/ok.png"
        sendText.color = "#FFFFFF"
        sendPngRotate.start()
      } else {
        signText.color = "crimson"
        signText.text = msg
        signPng.source = "qrc:/img/no.png"
        btnClose.visible = true
      }
    }
    function onTxSent(b, linkUrl) {
      sendPngRotate.stop()
      sendPng.rotation = 0
      if (b) {
        sendText.color = "limegreen"
        sendText.text = "Transaction sent!"
        sendPng.source = "qrc:/img/ok.png"
        if (linkUrl != "") {
          btnOpenLink.linkUrl = linkUrl
          btnOpenLink.visible = true
        }
      } else {
        sendText.color = "crimson"
        sendText.text = "Error on sending transaction."
        sendPng.source = "qrc:/img/no.png"
      }
      btnClose.visible = true
    }
    function onTxRetry() {
      sendText.text = "Transaction nonce is too low, or a transaction with"
      + "<br>the same hash was already imported. Retrying..."
    }

    function onLedgerRequired() {
      ledgerStatusPopup.open()
    }

    function onLedgerDone() {
      ledgerStatusPopup.close()
    }
  }

  function resetStatuses() {
    buildText.color = "#FFFFFF"
    signText.color = "#444444"
    sendText.color = "#444444"
    buildText.text = "Building transaction..."
    signText.text = "Signing transaction..."
    sendText.text = "Broadcasting transaction..."
    buildPng.source = signPng.source = sendPng.source = "qrc:/img/icons/loading.png"
    buildPngRotate.start()
    btnOpenLink.visible = false
    btnClose.visible = false
  }

  width: parent.width * 0.9
  height: parent.height * 0.9
  x: (parent.width * 0.1) / 2
  y: (parent.height * 0.1) / 2
  modal: true
  focus: true
  padding: 0  // Remove white borders
  closePolicy: Popup.NoAutoClose
  background: Rectangle { anchors.fill: parent; color: popupBgColor; radius: 10 }

  Column {
    id: items
    anchors {
      centerIn: parent
      margins: 30
    }
    spacing: 40

    Row {
      id: buildRow
      anchors.horizontalCenter: parent.horizontalCenter
      height: 70
      spacing: 40

      Image {
        id: buildPng
        height: 64
        anchors.verticalCenter: buildText.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: "qrc:/img/icons/loading.png"
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

      Image {
        id: signPng
        height: 64
        anchors.verticalCenter: signText.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: "qrc:/img/icons/loading.png"
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

      Image {
        id: sendPng
        height: 64
        anchors.verticalCenter: sendText.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: "qrc:/img/icons/loading.png"
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
  }

  AVMEButton {
    id: btnOpenLink
    property string linkUrl
    width: parent.width * 0.5
    anchors {
      bottom: btnClose.top
      horizontalCenter: parent.horizontalCenter
      margins: 30
    }
    text: "Open Transaction in Block Explorer"
    onClicked: Qt.openUrlExternally(linkUrl)
  }

  AVMEButton {
    id: btnClose
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      margins: 30
    }
    text: "Close"
    onClicked: {
      txProgressPopup.close()
    }
  }
  AVMEPopupInfo {
    id: ledgerStatusPopup
    icon: "qrc:/img/warn.png"
    info: "Please confirm your transaction on your Device"
    okBtn.text: "Close"
  }
}

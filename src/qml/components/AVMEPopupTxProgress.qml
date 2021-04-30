/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Popup for showing the progress of a transaction. Has to be opened manually.
Popup {
  id: txProgressPopup
  property string opStr
  property string toStr
  property string coinAmountStr
  property string tokenAmountStr
  property string lpAmountStr
  property string gasLimitStr
  property string gasPriceStr
  property color popupBgColor: "#1C2029"

  Connections {
    target: System
    function onTxStart(
      operation, to, coinAmount, tokenAmount, lpAmount, gasLimit, gasPrice, pass
    ) {
      // Uncomment to see the data passed to the popup
      //console.log(operation)
      //console.log(to)
      //console.log(coinAmount)
      //console.log(tokenAmount)
      //console.log(lpAmount)
      //console.log(gasLimit)
      //console.log(gasPrice)
      opStr = operation
      toStr = to
      coinAmountStr = coinAmount
      tokenAmountStr = tokenAmount
      lpAmountStr = lpAmount
      gasLimitStr = gasLimit
      gasPriceStr = gasPrice
      resetStatuses()
      System.makeTransaction(
        operation, to, coinAmount, tokenAmount, lpAmount, gasLimit, gasPrice, pass
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
    function onTxSigned(b) {
      signPngRotate.stop()
      signPng.rotation = 0
      if (b) {
        signText.color = "limegreen"
        signText.text = "Transaction signed!"
        signPng.source = "qrc:/img/ok.png"
        sendText.color = "#FFFFFF"
        sendPngRotate.start()
      } else {
        signText.color = "crimson"
        signText.text = "Error on signing transaction."
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
  }

  function resetStatuses() {
    buildText.color = "#FFFFFF"
    signText.color = "#444444"
    sendText.color = "#444444"
    buildText.text = "Building transaction..."
    signText.text = "Signing transaction..."
    sendText.text = "Broadcasting transaction..."
    buildPng.source = signPng.source = sendPng.source = "qrc:/img/icons/refresh.png"
    buildPngRotate.start()
    btnOpenLink.visible = false
    btnClose.visible = false
  }

  function clean() {
    opStr = toStr = coinAmountStr = tokenAmountStr = lpAmountStr = gasLimitStr = gasPriceStr = ""
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

  Text {
    id: infoText
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      margins: 30
    }
    font.pointSize: 18.0
    color: "#FFFFFF"
    horizontalAlignment: Text.AlignHCenter
    text: {
      switch (opStr) {
        case "Send AVAX":
          text: "Sending <b>" + coinAmountStr + " " + System.getCurrentCoin() + "</b>"
          + "<br>to the address <b>" + toStr + "</b>...";
          break;
        case "Send AVME":
          text: "Sending <b>" + tokenAmountStr + " " + System.getCurrentToken() + "</b>"
          + "<br>to the address <b>" + toStr + "</b>...";
          break;
        case "Approve Exchange":
          text: "Sending approval for exchanging/adding liquidity...";
          break;
        case "Approve Liquidity":
          text: "Sending approval for removing liquidity...";
          break;
        case "Approve Staking":
          text: "Sending approval for staking...";
          break;
        case "Swap AVAX -> AVME":
          text: "Swapping <b>" + coinAmountStr + " " + System.getCurrentCoin() + "</b>..."
          break;
        case "Swap AVME -> AVAX":
          text: "Swapping <b>" + tokenAmountStr + " " + System.getCurrentToken() + "</b>..."
          break;
        case "Add Liquidity":
          text: "Adding <b>" + coinAmountStr + " " + System.getCurrentCoin() + "</b>"
          + "<br>and <b>" + tokenAmountStr + " " + System.getCurrentToken() + "</b>"
          + "<br>to the pool...";
          break;
        case "Remove Liquidity":
          text: "Removing <b>" + lpAmountStr + " LP</b><br>from the pool...";
          break;
        case "Stake LP":
          text: "Staking <b>" + lpAmountStr + " LP</b>...";
          break;
        case "Unstake LP":
          text: "Withdrawing <b>" + lpAmountStr + " LP</b>...";
          break;
        case "Harvest AVME":
          text: "Requesting rewards from the staking pool..."
          break;
        case "Exit Staking":
          text: "Exiting the staking pool..."
          break;
        default:
          text: "";
          break;
      }
    }
  }

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
        source: "qrc:/img/icons/refresh.png"
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
        font.pointSize: 18.0
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
        source: "qrc:/img/icons/refresh.png"
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
        font.pointSize: 18.0
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
        source: "qrc:/img/icons/refresh.png"
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
        font.pointSize: 18.0
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
      txProgressPopup.clean()
      txProgressPopup.close()
      System.goToOverview()
      System.setScreen(content, "qml/screens/OverviewScreen.qml")
    }
  }
}

import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Screen for showing transaction progress and results

Item {
  id: progressScreen

  // Signal connections
  Connections {
    target: System

    onTxStart: System.makeTransaction(pass)
    onTxBuilt: {
      if (b) {
        buildText.color = "limegreen"
        buildText.text = "Transaction built!"
        buildPng.source = "qrc:/img/ok.png"
        signText.color = "black"
        signPng.visible = true
      } else {
        buildText.color = "crimson"
        buildText.text = "Error on building transaction."
        buildPng.source = "qrc:/img/no.png"
        btn.visible = true
      }
    }
    onTxSigned: {
      if (b) {
        signText.color = "limegreen"
        signText.text = "Transaction signed!"
        signPng.source = "qrc:/img/ok.png"
        sendText.color = "black"
        sendPng.visible = true
      } else {
        signText.color = "crimson"
        signText.text = "Error on signing transaction."
        signPng.source = "qrc:/img/no.png"
        btn.visible = true
      }
    }
    onTxSent: {
      if (b) {
        sendText.color = "limegreen"
        sendText.text = "Transaction sent!"
        sendPng.source = "qrc:/img/ok.png"
        if (linkUrl != "") {
          linkText.text = 'Transaction successful! '
          + '<html><style type="text/css"></style>'
          + '<a href="' + linkUrl + '">'
          + 'Link'
          + '</a></html>'
        } else {
          linkText.text = "Transaction failed. Please try again."
        }
        linkText.visible = true
        btn.visible = true
      } else {
        sendText.color = "crimson"
        sendText.text = "Error on sending transaction."
        sendPng.source = "qrc:/img/no.png"
        btn.visible = true
      }
    }
    onTxRetry: {
      sendText.text = "Nonce too low or Tx w/ same hash imported, retrying..."
    }
  }

  Column {
    id: progress
    anchors.fill: parent
    spacing: 30
    topPadding: 50

    // Logo
    Image {
      id: logo
      height: 120
      anchors.horizontalCenter: parent.horizontalCenter
      fillMode: Image.PreserveAspectFit
      source: "qrc:/img/avme_banner.png"
    }

    // Info about transaction
    Text {
      id: infoText
      anchors.horizontalCenter: parent.horizontalCenter
      font.pointSize: 18.0
      color: "black"
      horizontalAlignment: Text.AlignHCenter
      text: {
        if (System.getTxTokenFlag()) {
          text = "Sending <b>"
          + System.getTxReceiverTokenAmount() + " " + System.getCurrentToken()
          + "</b> to address<br><b>" + System.getTxReceiverAccount() + "</b>..."
        } else {
          text = "Sending <b>"
          + System.getTxReceiverCoinAmount() + " " + System.getCurrentCoin()
          + "</b> to address<br><b>" + System.getTxReceiverAccount() + "</b>..."
        }
      }
    }

    // Progress texts
    Row {
      id: buildRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Image {
        id: buildPng
        height: 50
        anchors.verticalCenter: buildText.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: "qrc:/img/wait.png"
        visible: true
      }

      Text {
        id: buildText
        font.pointSize: 14.0
        color: "black"
        text: "Building transaction..."
      }
    }

    Row {
      id: signRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Image {
        id: signPng
        height: 50
        anchors.verticalCenter: signText.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: "qrc:/img/wait.png"
        visible: false
      }

      Text {
        id: signText
        font.pointSize: 14.0
        color: "grey"
        text: "Signing transaction..."
      }
    }

    Row {
      id: sendRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Image {
        id: sendPng
        height: 50
        anchors.verticalCenter: sendText.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: "qrc:/img/wait.png"
        visible: false
      }

      Text {
        id: sendText
        font.pointSize: 14.0
        color: "grey"
        text: "Broadcasting transaction..."
      }
    }

    // Result text w/ link to transaction (or error message)
    Text {
      id: linkText
      anchors.horizontalCenter: parent.horizontalCenter
      visible: false
      text: ""
      onLinkActivated: Qt.openUrlExternally(link)
    }

    // Button to go back to Accounts
    AVMEButton {
      id: btn
      anchors.horizontalCenter: parent.horizontalCenter
      visible: false
      text: "OK"
      onClicked: System.setScreen(content, "qml/screens/StatsScreen.qml")
    }
  }
}

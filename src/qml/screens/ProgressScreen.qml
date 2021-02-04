import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Screen for showing transaction progress and results

Item {
  id: progressScreen

  // Start the transaction process once screen is loaded
  // TODO: transaction is done already before the screen even shows up!
  // Maybe put this in TransactionScreen's popup instead of a separate screen?
  Component.onCompleted: {
    var linkUrl = System.makeTransaction()
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
  }

  // Signal connections
  Connections {
    target: System
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
      }
    }
    onTxSent: {
      if (b) {
        sendText.color = "limegreen"
        sendText.text = "Transaction sent!"
        sendPng.source = "qrc:/img/ok.png"
      } else {
        sendText.color = "crimson"
        sendText.text = "Error on sending transaction."
        sendPng.source = "qrc:/img/no.png"
      }
    }
  }

  Column {
    id: progress
    anchors.fill: parent
    spacing: 30
    topPadding: 50

    // TODO: turn logo into an image (for better/easier scaling)
    Row {
      id: logo
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Image {
        id: logoPng
        source: "qrc:/img/avme_logo.png"
      }

      Text {
        id: logoText
        anchors.verticalCenter: logoPng.verticalCenter
        font.bold: true
        font.pointSize: 72.0
        text: "AVME"
      }
    }

    // Info about transaction
    Text {
      id: infoText
      anchors.horizontalCenter: parent.horizontalCenter
      font.pointSize: 18.0
      color: "black"
      horizontalAlignment: Text.AlignHCenter
      text: "Sending <b>" + System.getTxAmount() + " " + System.getTxLabel()
      + "</b> to address<br><b>" + System.getTxReceiverAccount() + "</b>..."
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
      onClicked: System.setScreen(content, "qml/screens/AccountsScreen.qml")
    }
  }
}

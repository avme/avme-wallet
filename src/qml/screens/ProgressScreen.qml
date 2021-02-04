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
        signText.color = "black"
      } else {
        buildText.color = "crimson"
        buildText.text = "Error on building transaction."
      }
    }
    onTxSigned: {
      if (b) {
        signText.color = "limegreen"
        signText.text = "Transaction signed!"
        sendText.color = "black"
      } else {
        signText.color = "crimson"
        signText.text = "Error on signing transaction."
      }
    }
    onTxSent: {
      if (b) {
        sendText.color = "limegreen"
        sendText.text = "Transaction sent!"
      } else {
        sendText.color = "crimson"
        sendText.text = "Error on sending transaction."
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
    // TODO: put animated icons beside the texts
    Row {
      id: buildRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

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

import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// TODO: transaction is done already before the screen even shows up!
// Maybe put this in TransactionScreen's popup instead of a separate screen?
Item {
  id: progress_screen

  Component.onCompleted: {
    var link_url = System.makeTransaction()
    if (link_url != "") {
      link_text.text = 'Transaction successful! '
      + '<html><style type="text/css"></style>'
      + '<a href="' + link_url + '">'
      + 'Link'
      + '</a></html>'
    } else {
      link_text.text = "Transaction failed. Please try again."
    }
    link_text.visible = true
    btn.visible = true
  }

  Connections {
    target: System
    onTxBuilt: {
      if (b) {
        build_text.color = "limegreen"
        build_text.text = "Transaction built!"
        sign_text.color = "black"
      } else {
        build_text.color = "crimson"
        build_text.text = "Error on building transaction."
      }
    }
    onTxSigned: {
      if (b) {
        sign_text.color = "limegreen"
        sign_text.text = "Transaction signed!"
        send_text.color = "black"
      } else {
        sign_text.color = "crimson"
        sign_text.text = "Error on signing transaction."
      }
    }
    onTxSent: {
      if (b) {
        send_text.color = "limegreen"
        send_text.text = "Transaction sent!"
      } else {
        send_text.color = "crimson"
        send_text.text = "Error on sending transaction."
      }
    }
  }

  Column {
    id: progress
    anchors.fill: parent
    spacing: 30
    topPadding: 50

    Row {
      id: logo
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Image {
        id: logo_png
        source: "qrc:/img/avme_logo.png"
      }

      Text {
        id: logo_text
        text: "AVME"
        font.bold: true
        font.pointSize: 72.0
        anchors.verticalCenter: logo_png.verticalCenter
      }
    }

    // TODO: put animated icons beside the texts
    Row {
      id: info_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: info_text
        font.pointSize: 18.0
        color: "black"
        horizontalAlignment: Text.AlignHCenter
        text: "Sending <b>" + System.getTxAmount() + " " + System.getTxLabel()
        + "</b> to address<br><b>" + System.getTxReceiverAccount() + "</b>..."
      }
    }

    Row {
      id: build_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: build_text
        font.pointSize: 14.0
        color: "black"
        text: "Building transaction..."
      }
    }

    Row {
      id: sign_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: sign_text
        font.pointSize: 14.0
        color: "grey"
        text: "Signing transaction..."
      }
    }

    Row {
      id: send_row
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Text {
        id: send_text
        font.pointSize: 14.0
        color: "grey"
        text: "Broadcasting transaction..."
      }
    }

    Text {
      id: link_text
      anchors.horizontalCenter: parent.horizontalCenter
      visible: false
      text: ""
      onLinkActivated: Qt.openUrlExternally(link)
    }

    AVMEButton {
      id: btn
      anchors.horizontalCenter: parent.horizontalCenter
      visible: false
      text: "OK"
      onClicked: System.setScreen(content, "qml/screens/AccountsScreen.qml")
    }
  }
}

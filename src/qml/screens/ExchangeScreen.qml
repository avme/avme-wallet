import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Screen for exchanging coins/tokens in a given Account

Item {
  id: exchangeScreen
  property bool coinToToken: true

  Text {
    id: info
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      margins: 20
    }
    horizontalAlignment: Text.AlignHCenter
    text: "Exchange currencies in the Account<br><b>" + System.getTxSenderAccount() + "</b>"
    font.pointSize: 18.0
  }

  Rectangle {
    id: fromRect
    width: parent.width * 0.3
    height: parent.height * 0.6
    anchors {
      verticalCenter: parent.verticalCenter
      horizontalCenter: parent.horizontalCenter
      horizontalCenterOffset: -(width / 1.5)
      margins: 20
    }
    color: "#44F66986"
    radius: 5

    Column {
      id: fromItems
      anchors.fill: parent
      spacing: 20
      anchors.topMargin: 20

      Image {
        id: fromLogo
        width: 128
        height: 128
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        source: "qrc:/img/avax_logo.png"
      }

      Text {
        id: fromTotalAmount
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: "Total " + System.getCurrentCoin() + ":<br><b>" + System.getTxSenderCoinAmount() + "</b>"
      }

      AVMEInput {
        id: fromInput
        width: parent.width * 0.8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        enabled: coinToToken
        validator: RegExpValidator { regExp: System.createCoinRegExp() }
        label: "Amount"
        placeholder: "Fixed point amount (e.g. 0.5)"
      }

      AVMEButton {
        id: fromAllBtn
        width: parent.width * 0.8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        enabled: coinToToken
        text: "Max Amount"
        onClicked: fromInput.text = System.getTxSenderCoinAmount() // TODO: check if gas price/limit have to be taken into consideration
      }

      AVMEButton {
        id: fromExchangeBtn
        width: parent.width * 0.8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        enabled: (coinToToken && fromInput.text != "")
        text: "Exchange"
        onClicked: {} // TODO
      }
    }
  }

  Text {
    id: switchText
    anchors.centerIn: parent
    font.pointSize: 60.0
    text: (coinToToken) ? ">" : "<"
  }

  Rectangle {
    id: toRect
    width: parent.width * 0.3
    height: parent.height * 0.6
    anchors {
      verticalCenter: parent.verticalCenter
      horizontalCenter: parent.horizontalCenter
      horizontalCenterOffset: width / 1.5
      margins: 20
    }
    color: "#44F66986"
    radius: 5

    Column {
      id: toItems
      anchors.fill: parent
      spacing: 20
      anchors.topMargin: 20

      Image {
        id: toLogo
        width: 128
        height: 128
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        source: "qrc:/img/avme_logo.png"
      }

      Text {
        id: toTotalAmount
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: "Total " + System.getCurrentToken() + ":<br><b>" + System.getTxSenderTokenAmount() + "</b>"
      }

      AVMEInput {
        id: toInput
        width: parent.width * 0.8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        enabled: !coinToToken
        validator: RegExpValidator { regExp: System.createTokenRegExp() }
        label: "Amount"
        placeholder: "Fixed point amount (e.g. 0.5)"
      }

      AVMEButton {
        id: toAllBtn
        width: parent.width * 0.8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        enabled: !coinToToken
        text: "Max Amount"
        onClicked: toInput.text = System.getTxSenderTokenAmount() // TODO: check if gas price/limit have to be taken into consideration
      }

      AVMEButton {
        id: toExchangeBtn
        width: parent.width * 0.8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        enabled: (!coinToToken && toInput.text != "")
        text: "Exchange"
        onClicked: {} // TODO
      }
    }
  }

  AVMEButton {
    id: btnSwitch
    width: parent.width / 6
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      horizontalCenterOffset: -(width / 1.5)
      margins: 20
    }
    text: "Switch From/To"
    onClicked: {
      coinToToken = !coinToToken
      if (!coinToToken) fromInput.text = ""
      if (coinToToken) toInput.text = ""
    }
  }

  AVMEButton {
    id: btnBack
    width: parent.width / 6
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      horizontalCenterOffset: width / 1.5
      margins: 20
    }
    text: "Back"
    onClicked: System.setScreen(content, "qml/screens/StatsScreen.qml")
  }
}

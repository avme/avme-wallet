import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Screen for exchanging coins/tokens in a given Account

Item {
  id: exchangeScreen
  property bool coinToToken: true
  property string allowance
  property string lowerToken
  property string lowerReserves
  property string higherToken
  property string higherReserves

  Connections {
    target: System
    onReservesUpdated: {
      lowerToken = lowerName
      lowerReserves = lowerAmount
      higherToken = higherName
      higherReserves = higherAmount
    }
  }

  Timer {
    id: reloadReservesTimer
    interval: 5000
    repeat: true
    onTriggered: {
      System.updateExchangeReserves(System.getCurrentCoin(), System.getCurrentToken())
      calculateAmountOut()
    }
  }

  function calculateAmountOut() {
    var amountIn = (coinToToken) ? fromInput.text : toInput.text
    var amountName = (coinToToken) ? System.getCurrentCoin() : System.getCurrentToken()
    var amountOut = ""
    if (amountName == lowerToken) {
      amountOut = System.calculateExchangeAmount(amountIn, lowerReserves, higherReserves)
    } else if (amountName == higherToken) {
      amountOut = System.calculateExchangeAmount(amountIn, higherReserves, lowerReserves)
    }
    if (coinToToken) {
      toInput.text = amountOut
    } else {
      fromInput.text = amountOut
    }
  }

  Component.onCompleted: {
    allowance = System.getExchangeAllowance()
    System.updateExchangeReserves(System.getCurrentCoin(), System.getCurrentToken())
    reloadReservesTimer.start()
    console.log("Allowed: " + allowance)
  }

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
        onTextEdited: calculateAmountOut()
      }

      AVMEButton {
        id: fromAllBtn
        width: parent.width * 0.8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        enabled: coinToToken
        text: "Max Amount"
        onClicked: {
          fromInput.text = System.getTxSenderCoinAmount()
          calculateAmountOut()
        }
      }

      AVMEButton {
        id: fromExchangeBtn
        width: parent.width * 0.8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        enabled: (coinToToken && fromInput.text != "")
        text: "Exchange"
        onClicked: {
          System.setTxGasLimit("180000")
          System.setTxGasPrice(System.getAutomaticFee())
          var noCoinFunds = System.hasInsufficientCoinFunds(
            System.getTxSenderCoinAmount(),
            System.calculateTransactionCost(
              fromInput.text, System.getTxGasLimit(), System.getTxGasPrice()
            )
          )
          if (noCoinFunds) {
            fundsPopup.open()
          } else {
            var fromLabel = System.getCurrentCoin()
            var toLabel = System.getCurrentToken()
            var toAmount = System.queryExchangeAmount(fromInput.text, fromLabel, toLabel)
            confirmExchangePopup.setTxData(
              fromInput.text, toAmount, fromLabel, toLabel,
              System.getTxGasLimit(), System.getTxGasPrice()
            )
            System.setTxTokenFlag(false)
            confirmExchangePopup.open()
          }
        }
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
        onTextEdited: calculateAmountOut()
      }

      AVMEButton {
        id: toAllBtn
        width: parent.width * 0.8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        enabled: !coinToToken
        text: "Max Amount"
        onClicked: {
          toInput.text = System.getTxSenderTokenAmount()
          calculateAmountOut()
        }
      }

      AVMEButton {
        id: toExchangeBtn
        width: parent.width * 0.8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        enabled: (!coinToToken && toInput.text != "")
        text: "Exchange"
        onClicked: {
          System.setTxGasLimit("180000")
          System.setTxGasPrice(System.getAutomaticFee())
          if (System.isExchangeAllowed(toInput.text, allowance)) {
            var noCoinFunds = System.hasInsufficientCoinFunds(
              System.getTxSenderCoinAmount(),
              System.calculateTransactionCost(
                "0", System.getTxGasLimit(), System.getTxGasPrice()
              )
            )
            var noTokenFunds = System.hasInsufficientTokenFunds(
              System.getTxSenderTokenAmount(), toInput.text
            )
            if (noCoinFunds || noTokenFunds) {
              fundsPopup.open()
            } else {
              var fromLabel = System.getCurrentToken()
              var toLabel = System.getCurrentCoin()
              var toAmount = System.queryExchangeAmount(toInput.text, fromLabel, toLabel)
              confirmExchangePopup.setTxData(
                toInput.text, toAmount, fromLabel, toLabel,
                System.getTxGasLimit(), System.getTxGasPrice()
              )
              System.setTxTokenFlag(true)
              confirmExchangePopup.open()
            }
          } else {
            approveExchangePopup.setTxData(System.getTxGasLimit(), System.getTxGasPrice());
            approveExchangePopup.open()
          }
        }
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
      fromInput.text = ""
      toInput.text = ""
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
    onClicked: {
      reloadReservesTimer.stop()
      System.setScreen(content, "qml/screens/StatsScreen.qml")
    }
  }

  // Popup for confirming approval
  AVMEPopupApproveExchange {
    id: approveExchangePopup
    confirmBtn.onClicked: {
      System.setTxOperation("Approve Exchange")
      System.setScreen(content, "qml/screens/ProgressScreen.qml")
      System.txStart(pass)
    }
  }

  // Popup for confirming the exchange operation
  AVMEPopupConfirmExchange {
    id: confirmExchangePopup
    confirmBtn.onClicked: {
      System.setTxReceiverCoinAmount(fromInput.text)
      System.setTxReceiverTokenAmount(toInput.text)
      if (System.getTxTokenFlag()) {
        System.setTxOperation("Swap AVME -> AVAX")
      } else {
        System.setTxOperation("Swap AVAX -> AVME")
      }
      confirmExchangePopup.close()
      System.setScreen(content, "qml/screens/ProgressScreen.qml")
      System.txStart(pass)
    }
  }

  // Popup for warning about insufficient funds
  AVMEPopupInfo {
    id: fundsPopup
    icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your transaction values."
  }
}

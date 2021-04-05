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
    onExchangeDataUpdated: {
      lowerToken = lowerTokenName
      lowerReserves = lowerTokenReserves
      higherToken = higherTokenName
      higherReserves = higherTokenReserves
    }
    onAllowancesUpdated: allowance = exchangeAllowance
  }

  Timer {
    id: reloadExchangeDataTimer
    interval: 5000
    repeat: true
    onTriggered: {
      System.updateExchangeData(System.getCurrentCoin(), System.getCurrentToken())
      calculateExchangeAmountOut()
    }
  }

  function calculateExchangeAmountOut() {
    var amountIn = swapInput.text
    var amountName = (coinToToken) ? System.getCurrentCoin() : System.getCurrentToken()
    var amountOut = ""
    if (amountName == lowerToken) {
      amountOut = System.calculateExchangeAmount(amountIn, lowerReserves, higherReserves)
    } else if (amountName == higherToken) {
      amountOut = System.calculateExchangeAmount(amountIn, higherReserves, lowerReserves)
    }
    swapEstimateInput.text = amountOut
  }

  Component.onCompleted: {
    System.getAllowances()
    System.updateExchangeData(System.getCurrentCoin(), System.getCurrentToken())
    calculateExchangeAmountOut()
    reloadExchangeDataTimer.start()
  }

  Text {
    id: info
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      margins: 20
    }
    horizontalAlignment: Text.AlignHCenter
    text: "Exchange currencies for the Account<br><b>" + System.getTxSenderAccount() + "</b>"
    font.pointSize: 18.0
  }

  Rectangle {
    id: swapRect
    width: parent.width * 0.5
    height: parent.height * 0.75
    anchors {
      top: info.bottom
      horizontalCenter: parent.horizontalCenter
      margins: 20
    }
    color: "#44F66986"
    radius: 5

    Column {
      id: swapItems
      anchors.fill: parent
      spacing: 30
      anchors.topMargin: 20

      Row {
        id: swapLogos
        height: 64
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20

        Image {
          id: fromLogo
          width: 64
          height: 64
          anchors.margins: 20
          source: (coinToToken) ? "qrc:/img/avax_logo.png" : "qrc:/img/avme_logo.png"
        }

        Text {
          id: swapOrder
          font.pointSize: 42.0
          text: " -> "
        }

        Image {
          id: toLogo
          width: 64
          height: 64
          anchors.margins: 20
          source: (!coinToToken) ? "qrc:/img/avax_logo.png" : "qrc:/img/avme_logo.png"
        }
      }

      Text {
        id: walletBalances
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: "Total " + System.getCurrentCoin() + " in wallet: <b>"
        + System.getTxSenderCoinAmount() + "</b><br>"
        + "Total " + System.getCurrentToken() + " in wallet: <b>"
        + System.getTxSenderTokenAmount() + "</b>"
      }

      AVMEInput {
        id: swapInput
        width: parent.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        validator: RegExpValidator {
          regExp: (coinToToken) ? System.createCoinRegExp() : System.createTokenRegExp()
        }
        label: (coinToToken)
        ? "Amount of " + System.getCurrentCoin() + " to swap"
        : "Amount of " + System.getCurrentToken() + " to swap"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: calculateExchangeAmountOut()
      }

      AVMEInput {
        id: swapEstimateInput
        width: parent.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        readOnly: true
        validator: RegExpValidator {
          regExp: (!coinToToken) ? System.createCoinRegExp() : System.createTokenRegExp()
        }
        label: (!coinToToken)
        ? "Estimated return in " + System.getCurrentCoin()
        : "Estimated return in " + System.getCurrentToken()
      }

      AVMEButton {
        id: swapSwitchBtn
        width: swapRect.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Switch Order"
        onClicked: {
          coinToToken = !coinToToken
          swapInput.text = ""
          swapEstimateInput.text = ""
          calculateExchangeAmountOut()
        }
      }

      AVMEButton {
        id: swapAllBtn
        width: swapRect.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Max Amount"
        onClicked: {
          swapInput.text = (coinToToken)  // TODO: include fees in calculation
            ? System.getTxSenderCoinAmount() : System.getTxSenderTokenAmount()
          calculateExchangeAmountOut()
        }
      }

      AVMEButton {
        id: swapBtn
        width: swapRect.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (allowance != "" && swapInput.text != "")
        text: {
          if (allowance == "") {
            text: "Checking approval..."
          } else if (System.isApproved(swapInput.text, allowance)) {
            text: "Make Swap"
          } else {
            text: "Approve"
          }
        }
        onClicked: {
          System.setTxGasLimit("180000")
          System.setTxGasPrice(System.getAutomaticFee())
          if (!System.isApproved(swapInput.text, allowance)) {
            approveExchangePopup.setTxData(System.getTxGasLimit(), System.getTxGasPrice())
            approveExchangePopup.open()
            return
          }

          if (coinToToken) {
            var noCoinFunds = System.hasInsufficientCoinFunds(
              System.getTxSenderCoinAmount(),
              System.calculateTransactionCost(
                swapInput.text, System.getTxGasLimit(), System.getTxGasPrice()
              )
            )
            if (noCoinFunds) { fundsPopup.open(); return; }
          } else {
            var noCoinFunds = System.hasInsufficientCoinFunds(
              System.getTxSenderCoinAmount(),
              System.calculateTransactionCost(
                "0", System.getTxGasLimit(), System.getTxGasPrice()
              )
            )
            var noTokenFunds = System.hasInsufficientTokenFunds(
              System.getTxSenderTokenAmount(), swapInput.text
            )
            if (noCoinFunds || noTokenFunds) { fundsPopup.open(); return; }
          }

          var fromLabel = (coinToToken) ? System.getCurrentCoin() : System.getCurrentToken()
          var toLabel = (!coinToToken) ? System.getCurrentCoin() : System.getCurrentToken()
          var toAmount = System.queryExchangeAmount(swapInput.text, fromLabel, toLabel)
          confirmExchangePopup.setTxData(
            swapInput.text, toAmount, fromLabel, toLabel,
            System.getTxGasLimit(), System.getTxGasPrice()
          )
          System.setTxTokenFlag(!coinToToken)
          confirmExchangePopup.open()
        }
      }
    }
  }

  AVMEButton {
    id: btnBack
    width: parent.width / 6
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      margins: 20
    }
    text: "Back"
    onClicked: {
      reloadExchangeDataTimer.stop()
      System.setScreen(content, "qml/screens/StatsScreen.qml")
    }
  }

  // Popup for confirming approval
  AVMEPopupApprove {
    id: approveExchangePopup
    confirmBtn.onClicked: {
      if (System.checkWalletPass(pass)) {
        System.setTxOperation("Approve Exchange")
        System.setScreen(content, "qml/screens/ProgressScreen.qml")
        System.txStart(pass)
      } else {
        approveExchangePopup.showErrorMsg()
      }
    }
  }

  // Popup for confirming the exchange operation
  AVMEPopupConfirmExchange {
    id: confirmExchangePopup
    confirmBtn.onClicked: {
      if (System.checkWalletPass(pass)) {
        if (System.getTxTokenFlag()) {
          System.setTxReceiverTokenAmount(swapInput.text)
          System.setTxReceiverCoinAmount(swapEstimateInput.text)
          System.setTxOperation("Swap AVME -> AVAX")
        } else {
          System.setTxReceiverCoinAmount(swapInput.text)
          System.setTxReceiverTokenAmount(swapEstimateInput.text)
          System.setTxOperation("Swap AVAX -> AVME")
        }
        confirmExchangePopup.close()
        System.setScreen(content, "qml/screens/ProgressScreen.qml")
        System.txStart(pass)
      } else {
        confirmExchangePopup.showErrorMsg()
      }
    }
  }

  // Popup for warning about insufficient funds
  AVMEPopupInfo {
    id: fundsPopup
    icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your transaction values."
  }
}

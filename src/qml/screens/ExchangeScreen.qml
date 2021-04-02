import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Screen for exchanging coins/tokens in a given Account

Item {
  id: exchangeScreen
  property bool coinToToken: true
  property string allowance
  property string liquidity
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
      liquidity = totalPoolLiquidity
    }
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
    allowance = System.getExchangeAllowance()
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
    text: "Exchange operations for the Account<br><b>" + System.getTxSenderAccount() + "</b>"
    font.pointSize: 18.0
  }

  Rectangle {
    id: walletBalancesRect
    width: parent.width * 0.45
    height: parent.height * 0.1
    anchors {
      top: info.bottom
      left: parent.left
      margins: 20
    }
    radius: 5
    color: "#44F66986"

    Column {
      id: walletBalancesColumn
      anchors.centerIn: parent
      anchors.margins: 10

      Text {
        id: walletCoinBalance
        horizontalAlignment: Text.AlignHCenter
        text: "Total " + System.getCurrentCoin() + " in wallet: <b>"
        + System.getTxSenderCoinAmount() + "</b>"
      }
      Text {
        id: walletTokenBalance
        horizontalAlignment: Text.AlignHCenter
        text: "Total " + System.getCurrentToken() + " in wallet: <b>"
        + System.getTxSenderTokenAmount() + "</b>"
      }
      Text {
        id: walletLPBalance
        horizontalAlignment: Text.AlignHCenter
        text: "Total LP in wallet: <b>"
        + System.getTxSenderLPFreeAmount() + "</b>"
      }
    }
  }

  Rectangle {
    id: poolBalancesRect
    width: parent.width * 0.45
    height: parent.height * 0.1
    anchors {
      top: info.bottom
      right: parent.right
      margins: 20
    }
    radius: 5
    color: "#44F66986"

    Column {
      id: poolBalancesColumn
      anchors.centerIn: parent
      anchors.margins: 10

      Text {
        id: poolCoinBalance
        horizontalAlignment: Text.AlignHCenter
        text: "Total " + System.getCurrentCoin() + " in pool: <b>"
        + System.weiToFixedPoint(
          ((System.getCurrentCoin() == lowerToken) ? lowerReserves : higherReserves),
          System.getCurrentCoinDecimals()
        )
      }

      Text {
        id: poolTokenBalance
        horizontalAlignment: Text.AlignHCenter
        text: "Total " + System.getCurrentToken() + " in pool: <b>"
        + System.weiToFixedPoint(
          ((System.getCurrentToken() == lowerToken) ? lowerReserves : higherReserves),
          System.getCurrentTokenDecimals()
        )
      }

      Text {
        id: poolLiquidityBalance
        horizontalAlignment: Text.AlignHCenter
        text: "Total LP in pool: <b>" + System.weiToFixedPoint(liquidity, 18)
      }
    }
  }

  Rectangle {
    id: swapRect
    width: parent.width * 0.45
    height: parent.height * 0.6
    anchors {
      top: walletBalancesRect.bottom
      left: parent.left
      margins: 20
    }
    color: "#44F66986"
    radius: 5

    Column {
      id: swapItems
      anchors.fill: parent
      spacing: 30
      anchors.topMargin: 20

      Text {
        id: swapTitle
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 14.0
        text: "Swap"
      }

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

      Row {
        id: swapBtnRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20

        AVMEButton {
          id: swapSwitchBtn
          width: swapRect.width * 0.4
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
          width: swapRect.width * 0.4
          text: "Max Amount"
          onClicked: {
            swapInput.text = (coinToToken)  // TODO: include fees in calculation
              ? System.getTxSenderCoinAmount() : System.getTxSenderTokenAmount()
            calculateExchangeAmountOut()
          }
        }
      }

      AVMEButton {
        id: swapBtn
        width: swapRect.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (swapInput.text != "")
        text: "Make Swap"
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

  Rectangle {
    id: liquidityRect
    width: parent.width * 0.45
    height: parent.height * 0.6
    anchors {
      top: poolBalancesRect.bottom
      right: parent.right
      margins: 20
    }
    color: "#44F66986"
    radius: 5

    Column {
      id: liquidityItems
      anchors.fill: parent
      spacing: 30
      anchors.topMargin: 20

      Text {
        id: liquidityTitle
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 14.0
        text: "Liquidity"
      }

      Image {
        id: liquidityLogo
        width: 64
        height: 64
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        source: "qrc:/img/pangolin.png"
      }

      AVMEInput {
        id: liquidityCoinInput
        width: parent.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        validator: RegExpValidator { regExp: System.createCoinRegExp() }
        label: "Amount of " + System.getCurrentCoin()
        placeholder: "Fixed point amount (e.g. 0.5)"
      }

      AVMEInput {
        id: liquidityTokenInput
        width: parent.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        validator: RegExpValidator { regExp: System.createTokenRegExp() }
        label: "Amount of " + System.getCurrentToken()
        placeholder: "Fixed point amount (e.g. 0.5)"
      }

      Row {
        id: liquidityAmountBtnRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        spacing: 20

        AVMEButton {
          id: liquidityMaxCoinBtn
          width: liquidityRect.width * 0.4
          text: "Max " + System.getCurrentCoin() + " Amount"
          onClicked: {
            liquidityCoinInput.text = System.getTxSenderCoinAmount()  // TODO: include fees in calculation
          }
        }

        AVMEButton {
          id: liquidityMaxTokenBtn
          width: liquidityRect.width * 0.4
          text: "Max " + System.getCurrentToken() + " Amount"
          onClicked: {
            liquidityTokenInput.text = System.getTxSenderTokenAmount()
          }
        }
      }

      Row {
        id: liquidityBtnRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        spacing: 20

        AVMEButton {
          id: liquidityAddBtn
          width: liquidityRect.width * 0.4
          enabled: (liquidityCoinInput.text != "" && liquidityTokenInput.text != "")
          text: "Add to Pool"
          onClicked: {} // TODO
        }

        AVMEButton {
          id: liquidityRemoveBtn
          width: liquidityRect.width * 0.4
          enabled: (liquidityCoinInput.text != "" && liquidityTokenInput.text != "")
          text: "Remove from Pool"
          onClicked: {} // TODO
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

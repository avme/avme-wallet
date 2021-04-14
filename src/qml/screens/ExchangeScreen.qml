import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Screen for exchanging coins/tokens in a given Account

Item {
  id: exchangeScreen
  property bool coinToToken: true
  property bool addToPool: true
  property string allowance
  property string addAllowance
  property string removeAllowance
  property string lowerToken
  property string lowerReserves
  property string higherToken
  property string higherReserves
  property string swapEstimate
  property string liquidity
  property string userLowerReserves
  property string userHigherReserves
  property string userLPSharePercentage
  property string removeLowerEstimate
  property string removeHigherEstimate
  property string removeLPEstimate

  Connections {
    target: System

    onAllowancesUpdated: {
      allowance = exchangeAllowance
      addAllowance = exchangeAllowance
      removeAllowance = liquidityAllowance
    }
    onExchangeDataUpdated: {
      lowerToken = lowerTokenName
      lowerReserves = lowerTokenReserves
      higherToken = higherTokenName
      higherReserves = higherTokenReserves
    }
    onLiquidityDataUpdated: {
      lowerToken = lowerTokenName
      lowerReserves = lowerTokenReserves
      higherToken = higherTokenName
      higherReserves = higherTokenReserves
      liquidity = totalLiquidity
      var userShares = System.calculatePoolShares(
        lowerReserves, higherReserves, liquidity
      )
      userLowerReserves = userShares.lower
      userHigherReserves = userShares.higher
      userLPSharePercentage = userShares.liquidity
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

  Timer {
    id: reloadLiquidityDataTimer
    interval: 5000
    repeat: true
    onTriggered: {
      System.updateLiquidityData(System.getCurrentCoin(), System.getCurrentToken())
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
    swapEstimate = amountOut
  }

  function calculateAddLiquidityAmount(isCoinToToken) {
    var amountIn = (isCoinToToken) ? liquidityCoinInput.text : liquidityTokenInput.text
    var amountName = (isCoinToToken) ? System.getCurrentCoin() : System.getCurrentToken()
    var amountOut = ""
    if (amountName == lowerToken) {
      amountOut = System.calculateAddLiquidityAmount(amountIn, lowerReserves, higherReserves)
    } else if (amountName == higherToken) {
      amountOut = System.calculateAddLiquidityAmount(amountIn, higherReserves, lowerReserves)
    }
    if (isCoinToToken) {
      liquidityTokenInput.text = amountOut
    } else {
      liquidityCoinInput.text = amountOut
    }
  }

  Component.onCompleted: {
    System.getAllowances()
    System.updateExchangeData(System.getCurrentCoin(), System.getCurrentToken())
    System.updateLiquidityData(System.getCurrentCoin(), System.getCurrentToken())
    calculateExchangeAmountOut()
    reloadExchangeDataTimer.start()
    reloadLiquidityDataTimer.start()
  }

  // Panel for the exchange operations
  // TODO: calculate price impact and other missing stuff from Pangolin
  AVMEPanel {
    id: exchangePanel
    width: (parent.width * 0.45)
    height: (parent.height * 0.85)
    anchors {
      left: parent.left
      verticalCenter: parent.verticalCenter
      margins: 40
    }
    title: "Exchange Details"

    Column {
      id: exchangeDetailsColumn
      anchors {
        top: parent.header.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: 20
      }
      spacing: 30

      Text {
        id: exchangeHeader
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.bold: true
        font.pointSize: 18.0
        text: (coinToToken) ? "Swap AVAX -> AVME" : "Swap AVME -> AVAX"
      }

      Row {
        id: swapLogos
        height: 64
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20

        Image {
          id: coinLogo
          width: 64
          height: 64
          antialiasing: true
          smooth: true
          anchors.margins: 20
          source: (coinToToken) ? "qrc:/img/avax_logo.png" : "qrc:/img/avme_logo.png"
          fillMode: Image.PreserveAspectFit
        }

        Text {
          id: swapOrder
          anchors.verticalCenter: parent.verticalCenter
          color: "#FFFFFF"
          font.pointSize: 42.0
          text: " -> "
        }

        Image {
          id: tokenLogo
          width: 64
          height: 64
          antialiasing: true
          smooth: true
          anchors.margins: 20
          source: (!coinToToken) ? "qrc:/img/avax_logo.png" : "qrc:/img/avme_logo.png"
          fillMode: Image.PreserveAspectFit
        }
      }

      AVMEButton {
        id: swapSwitchBtn
        width: (exchangeDetailsColumn.width * 0.5)
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Switch Order"
        onClicked: {
          coinToToken = !coinToToken
          swapInput.text = ""
          swapEstimate = ""
          calculateExchangeAmountOut()
        }
      }

      // TODO: show the total Account balances
      /*
      Text {
        id: walletBalances
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        text: "Total " + System.getCurrentCoin() + " in wallet: <b>"
        + System.getTxSenderCoinAmount() + "</b><br>"
        + "Total " + System.getCurrentToken() + " in wallet: <b>"
        + System.getTxSenderTokenAmount() + "</b>"
      }
      */

      AVMEInput {
        id: swapInput
        width: (parent.width * 0.8)
        enabled: (allowance != "")
        validator: RegExpValidator {
          regExp: (coinToToken) ? System.createCoinRegExp() : System.createTokenRegExp()
        }
        label: "Amount of " + (
          (coinToToken) ? System.getCurrentCoin() : System.getCurrentToken()
        ) + " to swap"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: calculateExchangeAmountOut()

        AVMEButton {
          id: swapAllBtn
          width: (exchangeDetailsColumn.width * 0.2) - anchors.leftMargin
          anchors {
            left: parent.right
            leftMargin: 10
          }
          text: "Max"
          enabled: (allowance != "")
          onClicked: {
            var acc = System.getAccountBalances(System.getTxSenderAccount())
            swapInput.text = (coinToToken)  // TODO: see if gas limit has to be hardcoded
              ? System.getRealMaxAVAXAmount("180000", System.getAutomaticFee())
              : acc.balanceAVME
            calculateExchangeAmountOut()
          }
        }
      }

      Text {
        id: swapEstimateText
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        color: "#FFFFFF"
        font.pointSize: 14.0
        text: "Estimated return in " + (
          (!coinToToken) ? System.getCurrentCoin() : System.getCurrentToken()
        ) + ":<br><b>" + swapEstimate + "</b>"
      }

      AVMEButton {
        id: swapBtn
        width: (parent.width * 0.5)
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (allowance != "" && swapInput.acceptableInput)
        text: {
          if (allowance == "") {
            text: "Checking approval..."
          } else if (System.isApproved(swapInput.text, allowance)) {
            text: "Make Swap"
          } else {
            text: "Approve"
          }
        }
        // TODO
        /*
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
        */
      }
    }
  }

  // Panel for the liquidity operations
  AVMEPanel {
    id: liquidityPanel
    width: (parent.width * 0.45)
    height: (parent.height * 0.85)
    anchors {
      right: parent.right
      verticalCenter: parent.verticalCenter
      margins: 40
    }
    title: "Liquidity Pool Details"

    Column {
      id: liquidityDetailsColumn
      anchors {
        top: parent.header.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: 20
      }
      spacing: 30

      Text {
        id: liquidityHeader
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.bold: true
        font.pointSize: 18.0
        text: (addToPool) ? "Add Liquidity" : "Remove Liquidity"
      }

      Row {
        id: liquidityLogos
        height: 64
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20

        Image {
          id: liquidityCoinLogo
          width: 64
          height: 64
          antialiasing: true
          smooth: true
          anchors.margins: 20
          source: "qrc:/img/avax_logo.png"
        }

        Text {
          id: liquidityCoinArrow
          anchors.verticalCenter: parent.verticalCenter
          color: "#FFFFFF"
          font.pointSize: 42.0
          text: (addToPool) ? " -> " : " <- "
        }

        Image {
          id: liquidityLPLogo
          width: 64
          height: 64
          antialiasing: true
          smooth: true
          anchors.margins: 20
          source: "qrc:/img/pangolin.png"
        }

        Text {
          id: liquidityTokenArrow
          anchors.verticalCenter: parent.verticalCenter
          color: "#FFFFFF"
          font.pointSize: 42.0
          text: (addToPool) ? " <- " : " -> "
        }

        Image {
          id: liquidityTokenLogo
          width: 64
          height: 64
          antialiasing: true
          smooth: true
          anchors.margins: 20
          source: "qrc:/img/avme_logo.png"
        }
      }

      AVMEButton {
        id: liquiditySwitchBtn
        width: parent.width * 0.5
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Switch Order"
        onClicked: {
          addToPool = !addToPool
        }
      }

      AVMEInput {
        id: liquidityCoinInput
        width: (parent.width * 0.8)
        enabled: (addAllowance != "")
        visible: (addToPool)
        validator: RegExpValidator { regExp: System.createCoinRegExp() }
        label: "Amount of " + System.getCurrentCoin() + " to add"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: calculateAddLiquidityAmount(true)

        AVMEButton {
          id: liquidityMaxCoinBtn
          width: (liquidityDetailsColumn.width * 0.2) - anchors.leftMargin
          anchors {
            left: parent.right
            leftMargin: 10
          }
          text: "Max"
          enabled: (addAllowance != "")
          onClicked: {
            liquidityCoinInput.text = System.getRealMaxAVAXAmount(
              "250000", System.getAutomaticFee()
            )  // TODO: see if gas limit has to be hardcoded
            calculateAddLiquidityAmount(true)
          }
        }
      }

      AVMEInput {
        id: liquidityTokenInput
        width: (parent.width * 0.8)
        enabled: (addAllowance != "")
        visible: (addToPool)
        validator: RegExpValidator { regExp: System.createTokenRegExp() }
        label: "Amount of " + System.getCurrentToken() + " to add"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: calculateAddLiquidityAmount(false)

        AVMEButton {
          id: liquidityMaxTokenBtn
          width: (liquidityDetailsColumn.width * 0.2) - anchors.leftMargin
          anchors {
            left: parent.right
            leftMargin: 10
          }
          text: "Max"
          enabled: (addAllowance != "")
          onClicked: {
            var acc = System.getAccountBalances(System.getTxSenderAccount())
            liquidityTokenInput.text = acc.balanceAVME
            calculateAddLiquidityAmount(false)
          }
        }
      }

      Slider {
        id: liquidityLPSlider
        visible: (!addToPool)
        from: 0
        value: 0
        to: 100
        stepSize: 1
        snapMode: Slider.SnapAlways
        width: parent.width * 0.8
        anchors.left: parent.left
        anchors.margins: 20
        enabled: (removeAllowance != "" && lowerReserves != "" && higherReserves != "" && liquidity != "")
        onMoved: {
          var estimates = System.calculateRemoveLiquidityAmount(
            userLowerReserves, userHigherReserves, value
          )
          removeLowerEstimate = estimates.lower
          removeHigherEstimate = estimates.higher
          removeLPEstimate = estimates.lp
        }
        Text {
          id: sliderText
          anchors.left: parent.right
          anchors.leftMargin: 10
          anchors.verticalCenter: parent.verticalCenter
          color: "#FFFFFF"
          font.pointSize: 18.0
          text: parent.value + "%"
        }
      }

      // TODO: "advanced" mode (manual input instead of a slider)
      Row {
        id: sliderBtnRow
        visible: (!addToPool)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20

        AVMEButton {
          id: sliderBtn25
          enabled: (removeAllowance != "" && lowerReserves != "" && higherReserves != "" && liquidity != "")
          width: (liquidityDetailsColumn.width * 0.2)
          text: "25%"
          onClicked: { liquidityLPSlider.value = 25; liquidityLPSlider.moved(); }
        }

        AVMEButton {
          id: sliderBtn50
          enabled: (removeAllowance != "" && lowerReserves != "" && higherReserves != "" && liquidity != "")
          width: (liquidityDetailsColumn.width * 0.2)
          text: "50%"
          onClicked: { liquidityLPSlider.value = 50; liquidityLPSlider.moved(); }
        }

        AVMEButton {
          id: sliderBtn75
          enabled: (removeAllowance != "" && lowerReserves != "" && higherReserves != "" && liquidity != "")
          width: (liquidityDetailsColumn.width * 0.2)
          text: "75%"
          onClicked: { liquidityLPSlider.value = 75; liquidityLPSlider.moved(); }
        }

        AVMEButton {
          id: sliderBtn100
          enabled: (removeAllowance != "" && lowerReserves != "" && higherReserves != "" && liquidity != "")
          width: (liquidityDetailsColumn.width * 0.2)
          text: "100%"
          onClicked: { liquidityLPSlider.value = 100; liquidityLPSlider.moved(); }
        }
      }

      Text {
        id: removeEstimate
        visible: (!addToPool)
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pointSize: 14.0
        text: "Estimated returns:"
        + "<br><b>" + ((removeLPEstimate) ? removeLPEstimate : "0") + " LP"
        + "<br>" + System.weiToFixedPoint(
          ((System.getCurrentCoin() == lowerToken) ? removeLowerEstimate : removeHigherEstimate),
          System.getCurrentCoinDecimals()
        ) + " " + System.getCurrentCoin()
        + "<br>" + System.weiToFixedPoint(
          ((System.getCurrentToken() == lowerToken) ? removeLowerEstimate : removeHigherEstimate),
          System.getCurrentTokenDecimals()
        ) + " " + System.getCurrentToken() + "</b>"
      }

      AVMEButton {
        id: liquidityBtn
        width: (parent.width * 0.5)
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (
          addAllowance != ""
          && liquidityCoinInput.acceptableInput
          && liquidityTokenInput.acceptableInput
        )
        text: {
          if (addAllowance === "") {
            text: "Checking approval..."
          } else if (addToPool && System.isApproved(liquidityTokenInput.text, addAllowance)) {
            text: "Add to the pool"
          } else if (!addToPool && System.isApproved(liquidityTokenInput.text, removeAllowance)) {
            text: "Remove from the pool"
          } else {
            text: "Approve"
          }
        }
        // TODO
        /*
        onClicked: {
          System.setTxGasLimit("250000")
          System.setTxGasPrice(System.getAutomaticFee())
          if (!System.isApproved(liquidityTokenInput.text, addAllowance)) {
            approveExchangePopup.setTxData(System.getTxGasLimit(), System.getTxGasPrice())
            approveExchangePopup.open()
            return
          }

          var noCoinFunds = System.hasInsufficientCoinFunds(
            System.getTxSenderCoinAmount(),
            System.calculateTransactionCost(
              liquidityCoinInput.text, System.getTxGasLimit(), System.getTxGasPrice()
            )
          )
          var noTokenFunds = System.hasInsufficientTokenFunds(
            System.getTxSenderTokenAmount(), liquidityTokenInput.text
          )

          if (noCoinFunds || noTokenFunds) {
            fundsPopup.open()
          } else {
            confirmAddLPPopup.setTxData(
              liquidityCoinInput.text, System.getCurrentCoin(),
              liquidityTokenInput.text, System.getCurrentToken(),
              System.getTxGasLimit(), System.getTxGasPrice()
            )
            confirmAddLPPopup.open()
          }
        }
        */
      }
    }
  }

  /*
  // TODO: remove those
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
          System.setTxReceiverCoinAmount(swapEstimate)
          System.setTxOperation("Swap AVME -> AVAX")
        } else {
          System.setTxReceiverCoinAmount(swapInput.text)
          System.setTxReceiverTokenAmount(swapEstimate)
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
  */
}

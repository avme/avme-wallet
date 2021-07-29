/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Screen for exchanging coins/tokens in a given Account
Item {
  id: exchangeScreen
  property string allowance
  property string swapEstimate
  property double swapImpact
  /*
  Connections {
    target: QmlSystem
    function onAllowancesUpdated(
      exchangeAllowance, liquidityAllowance, stakingAllowance
    ) {
      allowance = exchangeAllowance
      addAllowance = exchangeAllowance
      removeAllowance = liquidityAllowance
    }
    function onExchangeDataUpdated(
      lowerTokenName, lowerTokenReserves, higherTokenName, higherTokenReserves
    ) {
      lowerToken = lowerTokenName
      lowerReserves = lowerTokenReserves
      higherToken = higherTokenName
      higherReserves = higherTokenReserves
    }
    function onLiquidityDataUpdated(
      lowerTokenName, lowerTokenReserves, higherTokenName, higherTokenReserves, totalLiquidity
    ) {
      lowerToken = lowerTokenName
      lowerReserves = lowerTokenReserves
      higherToken = higherTokenName
      higherReserves = higherTokenReserves
      liquidity = totalLiquidity
      var userShares = QmlSystem.calculatePoolShares(
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
      QmlSystem.updateExchangeData("AVAX", "Token") // TODO: token name here
      calculateExchangeAmountOut()
    }
  }

  Timer {
    id: reloadLiquidityDataTimer
    interval: 5000
    repeat: true
    onTriggered: {
      QmlSystem.updateLiquidityData("AVAX", "Token") // TODO: token name here
    }
  }

  function calculateExchangeAmountOut() {
    var amountIn = swapInput.text
    var amountName = (coinToToken) ? "AVAX" : "Token" // TODO: token name here
    var amountOut = ""
    if (amountName == lowerToken) {
      amountOut = QmlSystem.calculateExchangeAmount(amountIn, lowerReserves, higherReserves)
    } else if (amountName == higherToken) {
      amountOut = QmlSystem.calculateExchangeAmount(amountIn, higherReserves, lowerReserves)
    }
    swapEstimate = amountOut
  }

  // For manual input
  function calculateAddLiquidityAmount(fromCoin) {
    var amountIn = (fromCoin) ? liquidityCoinInput.text : liquidityTokenInput.text
    var amountName = (fromCoin) ? "AVAX" : "Token"  // TODO: token name here
    var maxAmountAVAX = QmlSystem.getRealMaxAVAXAmount("250000", QmlSystem.getAutomaticFee())
    var maxAmountAVME = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount()).balanceAVME
    var amountOut, coinAmount, tokenAmount

    // Set the values accordingly
    if (amountName == lowerToken) {
      amountOut = QmlSystem.calculateAddLiquidityAmount(amountIn, lowerReserves, higherReserves)
    } else if (amountName == higherToken) {
      amountOut = QmlSystem.calculateAddLiquidityAmount(amountIn, higherReserves, lowerReserves)
    }
    if (fromCoin) {
      liquidityTokenInput.text = amountOut
    } else {
      liquidityCoinInput.text = amountOut
    }
  }

  // For the Max Amounts button
  function calculateMaxAddLiquidityAmount() {
    var maxAmountAVAX = QmlSystem.getRealMaxAVAXAmount("250000", QmlSystem.getAutomaticFee())
    var maxAmountAVME = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount()).balanceAVME
    var coinAmount, tokenAmount

    // Get the expected amounts for maxed values
    if (lowerToken == "AVAX") {
      tokenAmount = QmlSystem.calculateAddLiquidityAmount(maxAmountAVAX, lowerReserves, higherReserves)
      coinAmount = QmlSystem.calculateAddLiquidityAmount(maxAmountAVME, higherReserves, lowerReserves)
    } else if (lowerToken == "Token") { // TODO: token name here
      coinAmount = QmlSystem.calculateAddLiquidityAmount(maxAmountAVME, lowerReserves, higherReserves)
      tokenAmount = QmlSystem.calculateAddLiquidityAmount(maxAmountAVAX, higherReserves, lowerReserves)
    }

    // Limit the max amount to the lowest the user has.
    // If coinAmount is higher than the user's AVAX balance,
    // then the AVAX user balance is limiting. Same with tokenAmount and AVME.
    if (QmlSystem.firstHigherThanSecond(coinAmount, maxAmountAVAX)) {
      maxAmountAVME = tokenAmount
    }
    if (QmlSystem.firstHigherThanSecond(tokenAmount, maxAmountAVME)) {
      maxAmountAVAX = coinAmount
    }

    // Set the values accordingly
    if (lowerToken == "AVAX") {
      liquidityCoinInput.text = maxAmountAVAX
      liquidityTokenInput.text = QmlSystem.calculateAddLiquidityAmount(
        maxAmountAVAX, lowerReserves, higherReserves
      )
    } else if (lowerToken == "Token") { // TODO: token name here
      liquidityTokenInput.text = maxAmountAVME
      liquidityCoinInput.text = QmlSystem.calculateAddLiquidityAmount(
        maxAmountAVME, lowerReserves, higherReserves
      )
    }
  }

  Component.onCompleted: {
    QmlSystem.getAllowances()
    QmlSystem.updateExchangeData("AVAX", "Token") // TODO: token name here
    QmlSystem.updateLiquidityData("AVAX", "Token") // TODO: token name here
    calculateExchangeAmountOut()
    reloadExchangeDataTimer.start()
    reloadLiquidityDataTimer.start()
  }
  */

  AVMEPanel {
    id: exchangePanel
    width: (parent.width * 0.5)
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      margins: 10
    }
    title: "Exchange Details"

    Column {
      id: exchangeDetailsColumn
      anchors {
        top: parent.top
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        topMargin: 80
        bottomMargin: 20
        leftMargin: 40
        rightMargin: 40
      }
      spacing: 30

      Text {
        id: exchangeHeader
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "You will swap from <b>" + fromAssetPopup.chosenAssetSymbol
        + "</b> to <b>" + toAssetPopup.chosenAssetSymbol + "</b>"
      }

      Row {
        id: swapLogos
        height: 64
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20

        Image {
          id: fromLogo
          height: 48
          antialiasing: true
          smooth: true
          anchors.verticalCenter: parent.verticalCenter
          anchors.margins: 20
          fillMode: Image.PreserveAspectFit
          source: {
            var avmeAddress = QmlSystem.getAVMEAddress()
            if (fromAssetPopup.chosenAssetSymbol == "AVAX") {
              source: "qrc:/img/avax_logo.png"
            } else if (fromAssetPopup.chosenAssetAddress == avmeAddress) {
              source: "qrc:/img/avme_logo.png"
            } else {
              var img = QmlSystem.getARC20TokenImage(fromAssetPopup.chosenAssetAddress)
              source: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
            }
          }
        }

        Text {
          id: swapOrder
          anchors.verticalCenter: parent.verticalCenter
          color: "#FFFFFF"
          font.pixelSize: 48.0
          text: " -> "
        }

        Image {
          id: toLogo
          height: 48
          antialiasing: true
          smooth: true
          anchors.verticalCenter: parent.verticalCenter
          anchors.margins: 20
          fillMode: Image.PreserveAspectFit
          source: {
            var avmeAddress = QmlSystem.getAVMEAddress()
            if (toAssetPopup.chosenAssetSymbol == "AVAX") {
              source: "qrc:/img/avax_logo.png"
            } else if (toAssetPopup.chosenAssetAddress == avmeAddress) {
              source: "qrc:/img/avme_logo.png"
            } else {
              var img = QmlSystem.getARC20TokenImage(toAssetPopup.chosenAssetAddress)
              source: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
            }
          }
        }
      }

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AVMEButton {
          id: btnChangeFrom
          width: (parent.parent.width * 0.5) - (parent.spacing / 2)
          text: "Change From Asset"
          onClicked: fromAssetPopup.open()
        }
        AVMEButton {
          id: btnChangeTo
          width: (parent.parent.width * 0.5) - (parent.spacing / 2)
          text: "Change To Asset"
          onClicked: toAssetPopup.open()
        }
      }

      AVMEInput {
        id: swapInput
        width: (parent.width * 0.8)
        enabled: (allowance != "")
        validator: RegExpValidator {
          regExp: QmlSystem.createTxRegExp(fromAssetPopup.chosenAssetDecimals)
        }
        label: fromAssetPopup.chosenAssetSymbol + " Amount"
        placeholder: "Fixed point amount (e.g. 0.5)"
        /*
        // TODO: this
        onTextEdited: {
          calculateExchangeAmountOut()
          if (coinToToken) {
            swapImpact = QmlSystem.calculateExchangePriceImpact(
              (("AVAX" == lowerToken) ? lowerReserves : higherReserves),
              swapInput.text, 18
            )
          } else {
            swapImpact = QmlSystem.calculateExchangePriceImpact(
              (("Token" == lowerToken) ? lowerReserves : higherReserves),
              swapInput.text, 18  // TODO: token name AND decimals here
            )
          }
        }
        */

        AVMEButton {
          id: swapMaxBtn
          width: (parent.parent.width * 0.2) - anchors.leftMargin
          anchors {
            left: parent.right
            leftMargin: 10
          }
          text: "Max"
          enabled: (allowance != "")
          /*
          // TODO: this
          onClicked: {
            var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
            swapInput.text = (coinToToken)
              ? QmlSystem.getRealMaxAVAXAmount("180000", QmlSystem.getAutomaticFee())
              : acc.balanceAVME
            calculateExchangeAmountOut()
            if (coinToToken) {
              swapImpact = QmlSystem.calculateExchangePriceImpact(
                (("AVAX" == lowerToken) ? lowerReserves : higherReserves),
                swapInput.text, 18
              )
            } else {
              swapImpact = QmlSystem.calculateExchangePriceImpact(
                (("Token" == lowerToken) ? lowerReserves : higherReserves),
                swapInput.text, 18  // TODO: token name AND decimals here
              )
            }
          }
          */
        }
      }

      Text {
        id: swapEstimateText
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Estimated " + toAssetPopup.chosenAssetSymbol + " return:"
        + "<br><b>" + swapEstimate + "</b> "
      }

      /**
       * Impact color metrics are as follows:
       * White  = 0%
       * Green  = 0.01~5%
       * Yellow = 5.01~7.5%
       * Orange = 7.51~10%
       * Red    = 10.01+%
       */
      Text {
        id: swapImpactText
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        color: {
          if (swapImpact == 0.0) {
            color: "#FFFFFF"
          } else if (swapImpact > 0.0 && swapImpact <= 5.0) {
            color: "#44FF44"
          } else if (swapImpact > 5.0 && swapImpact <= 7.5) {
            color: "#FFFF44"
          } else if (swapImpact > 7.5 && swapImpact <= 10.0) {
            color: "#FF8844"
          } else if (swapImpact > 10.0) {
            color: "#FF4444"
          }
        }
        font.pixelSize: 14.0
        text: "Price impact: <b>" + swapImpact + "%</b>"
      }

      CheckBox {
        id: ignoreImpactCheck
        checked: false
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Ignore price impact"
        contentItem: Text {
          text: parent.text
          font.pixelSize: 14.0
          color: parent.checked ? "#FFFFFF" : "#888888"
          verticalAlignment: Text.AlignVCenter
          leftPadding: parent.indicator.width + parent.spacing
        }
      }

      AVMEButton {
        id: swapBtn
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: allowance != "" && (
          !QmlSystem.isApproved(swapInput.text, allowance) || swapInput.acceptableInput
        ) && (swapImpact <= 10.0 || ignoreImpactCheck.checked)
        text: {
          if (allowance == "") {
            text: "Checking approval..."
          } else if (QmlSystem.isApproved(swapInput.text, allowance)) {
            text: (swapImpact <= 10.0 || ignoreImpactCheck.checked)
            ? "Make Swap" : "Price impact too high"
          } else {
            text: "Approve"
          }
        }
        /*
        // TODO: this
        onClicked: {
          if (!QmlSystem.isApproved(swapInput.text, allowance)) {
            QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
            QmlSystem.operationOverride("Approve Exchange", "", "", "")
          } else if (coinToToken) {
            if (QmlSystem.balanceIsZero(swapInput.text, 18)) {
              zeroSwapPopup.open()
            } else {
              if (QmlSystem.hasInsufficientFunds(
                "Coin", QmlSystem.getRealMaxAVAXAmount("180000", QmlSystem.getAutomaticFee()), swapInput.text
              )) {
                fundsPopup.open()
              } else {
                QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
                QmlSystem.operationOverride("Swap AVAX -> AVME", swapInput.text, swapEstimate, "")
              }
            }
          } else {
            var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
            if (QmlSystem.balanceIsZero(swapInput.text, 18)) {
              zeroSwapPopup.open()
            } else {
              if (QmlSystem.hasInsufficientFunds("Token", acc.balanceAVME, swapInput.text)) {
                fundsPopup.open()
              } else {
                QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
                QmlSystem.operationOverride("Swap AVME -> AVAX", swapEstimate, swapInput.text, "")
              }
            }
          }
        }
        */
      }
    }
  }

  // Popups for choosing the asset going "in"/"out".
  // Defaults to "from AVAX to AVME".
  AVMEPopupAssetSelect { id: fromAssetPopup; defaultToAVME: false }
  AVMEPopupAssetSelect { id: toAssetPopup; defaultToAVME: true }

  // Popup for insufficient funds
  AVMEPopupInfo {
    id: fundsPopup
    icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your inputs."
  }
  AVMEPopupInfo {
    id: zeroSwapPopup
    icon: "qrc:/img/warn.png"
    info: "Cannot send swap for 0 value"
  }
}

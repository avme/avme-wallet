/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
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
  property double swapImpact
  property string liquidity
  property string userLowerReserves
  property string userHigherReserves
  property string userLPSharePercentage
  property string removeLowerEstimate
  property string removeHigherEstimate
  property string removeLPEstimate

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
      QmlSystem.updateExchangeData(QmlSystem.getCurrentCoin(), QmlSystem.getCurrentToken())
      calculateExchangeAmountOut()
    }
  }

  Timer {
    id: reloadLiquidityDataTimer
    interval: 5000
    repeat: true
    onTriggered: {
      QmlSystem.updateLiquidityData(QmlSystem.getCurrentCoin(), QmlSystem.getCurrentToken())
    }
  }

  function calculateExchangeAmountOut() {
    var amountIn = swapInput.text
    var amountName = (coinToToken) ? QmlSystem.getCurrentCoin() : QmlSystem.getCurrentToken()
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
    var amountName = (fromCoin) ? QmlSystem.getCurrentCoin() : QmlSystem.getCurrentToken()
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
    if (lowerToken == QmlSystem.getCurrentCoin()) {
      tokenAmount = QmlSystem.calculateAddLiquidityAmount(maxAmountAVAX, lowerReserves, higherReserves)
      coinAmount = QmlSystem.calculateAddLiquidityAmount(maxAmountAVME, higherReserves, lowerReserves)
    } else if (lowerToken == QmlSystem.getCurrentToken()) {
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
    if (lowerToken == QmlSystem.getCurrentCoin()) {
      liquidityCoinInput.text = maxAmountAVAX
      liquidityTokenInput.text = QmlSystem.calculateAddLiquidityAmount(
        maxAmountAVAX, lowerReserves, higherReserves
      )
    } else if (lowerToken == QmlSystem.getCurrentToken()) {
      liquidityTokenInput.text = maxAmountAVME
      liquidityCoinInput.text = QmlSystem.calculateAddLiquidityAmount(
        maxAmountAVME, lowerReserves, higherReserves
      )
    }
  }

  Component.onCompleted: {
    QmlSystem.getAllowances()
    QmlSystem.updateExchangeData(QmlSystem.getCurrentCoin(), QmlSystem.getCurrentToken())
    QmlSystem.updateLiquidityData(QmlSystem.getCurrentCoin(), QmlSystem.getCurrentToken())
    calculateExchangeAmountOut()
    reloadExchangeDataTimer.start()
    reloadLiquidityDataTimer.start()
  }

  AVMEAccountHeader {
    id: accountHeader
  }

  // Panel for the exchange operations
  AVMEPanel {
    id: exchangePanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
    anchors {
      top: accountHeader.bottom
      left: parent.left
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
        font.bold: true
        font.pixelSize: 24.0
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
          font.pixelSize: 48.0
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
          swapImpact = 0
          calculateExchangeAmountOut()
        }
      }

      AVMEInput {
        id: swapInput
        width: (parent.width * 0.8)
        enabled: (allowance != "")
        validator: RegExpValidator {
          regExp: (coinToToken) ? QmlSystem.createCoinRegExp() : QmlSystem.createTokenRegExp()
        }
        label: "Amount of " + (
          (coinToToken) ? QmlSystem.getCurrentCoin() : QmlSystem.getCurrentToken()
        ) + " to swap"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: {
          calculateExchangeAmountOut()
          if (coinToToken) {
            swapImpact = QmlSystem.calculateExchangePriceImpact(
              ((QmlSystem.getCurrentCoin() == lowerToken) ? lowerReserves : higherReserves),
              swapInput.text, QmlSystem.getCurrentCoinDecimals()
            )
          } else {
            swapImpact = QmlSystem.calculateExchangePriceImpact(
              ((QmlSystem.getCurrentToken() == lowerToken) ? lowerReserves : higherReserves),
              swapInput.text, QmlSystem.getCurrentTokenDecimals()
            )
          }
        }

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
            var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
            swapInput.text = (coinToToken)
              ? QmlSystem.getRealMaxAVAXAmount("180000", QmlSystem.getAutomaticFee())
              : acc.balanceAVME
            calculateExchangeAmountOut()
            if (coinToToken) {
              swapImpact = QmlSystem.calculateExchangePriceImpact(
                ((QmlSystem.getCurrentCoin() == lowerToken) ? lowerReserves : higherReserves),
                swapInput.text, QmlSystem.getCurrentCoinDecimals()
              )
            } else {
              swapImpact = QmlSystem.calculateExchangePriceImpact(
                ((QmlSystem.getCurrentToken() == lowerToken) ? lowerReserves : higherReserves),
                swapInput.text, QmlSystem.getCurrentTokenDecimals()
              )
            }
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
        font.pixelSize: 18.0
        text: "Estimated return in " + (
          (!coinToToken) ? QmlSystem.getCurrentCoin() : QmlSystem.getCurrentToken()
        ) + ":<br><b>" + swapEstimate + "</b>"
      }

      Text {
        id: swapImpactText
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        color: {
          if (swapImpact == 0.0) {  // 0% -> white
            color: "#FFFFFF"
          } else if (swapImpact > 0.0 && swapImpact <= 5.0) {  // 0.01-5% -> green
            color: "#44FF44"
          } else if (swapImpact > 5.0 && swapImpact <= 7.5) {  // 5.01-7.5% -> yellow
            color: "#FFFF44"
          } else if (swapImpact > 7.5 && swapImpact <= 10.0) { // 7.51%-10.0% -> orange
            color: "#FF8844"
          } else if (swapImpact > 10.0) {  // 10.1+% -> red
            color: "#FF4444"
          }
        }
        font.pixelSize: 18.0
        text: "Price impact: <b>" + swapImpact + "%</b>"
      }

      CheckBox {
        id: ignoreImpactCheck
        checked: false
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Ignore price impact"
        contentItem: Text {
          text: parent.text
          font.pointSize: 14.0
          color: parent.checked ? "#FFFFFF" : "#888888"
          verticalAlignment: Text.AlignVCenter
          leftPadding: parent.indicator.width + parent.spacing
        }
      }

      AVMEButton {
        id: swapBtn
        width: (parent.width * 0.5)
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
      }
    }
  }

  // Panel for the liquidity operations
  AVMEPanel {
    id: liquidityPanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
    anchors {
      top: accountHeader.bottom
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
    title: "Liquidity Pool Details"

    Column {
      id: liquidityDetailsColumn
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
        id: liquidityHeader
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.bold: true
        font.pixelSize: 24.0
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
          font.pixelSize: 48.0
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
          font.pixelSize: 48.0
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
        text: (addToPool) ? "Switch to Remove" : "Switch to Add"
        onClicked: addToPool = !addToPool
      }

      AVMEInput {
        id: liquidityCoinInput
        width: parent.width
        enabled: (addAllowance != "")
        visible: (addToPool)
        validator: RegExpValidator { regExp: QmlSystem.createCoinRegExp() }
        label: "Amount of " + QmlSystem.getCurrentCoin() + " to add"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: calculateAddLiquidityAmount(true)
      }

      AVMEInput {
        id: liquidityTokenInput
        width: parent.width
        enabled: (addAllowance != "")
        visible: (addToPool)
        validator: RegExpValidator { regExp: QmlSystem.createTokenRegExp() }
        label: "Amount of " + QmlSystem.getCurrentToken() + " to add"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: calculateAddLiquidityAmount(false)
      }

      AVMEButton {
        id: liquidityMaxAddBtn
        width: (parent.width * 0.5)
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Max Amounts"
        enabled: (addAllowance != "")
        visible: (addToPool)
        onClicked: calculateMaxAddLiquidityAmount()
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
          var estimates = QmlSystem.calculateRemoveLiquidityAmount(
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
          color: (parent.enabled) ? "#FFFFFF" : "#444444"
          font.pixelSize: 24.0
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
        font.pixelSize: 18.0
        text: "Estimated returns:"
        + "<br><b>" + ((removeLPEstimate) ? removeLPEstimate : "0") + " LP"
        + "<br>" + QmlSystem.weiToFixedPoint(
          ((QmlSystem.getCurrentCoin() == lowerToken) ? removeLowerEstimate : removeHigherEstimate),
          QmlSystem.getCurrentCoinDecimals()
        ) + " " + QmlSystem.getCurrentCoin()
        + "<br>" + QmlSystem.weiToFixedPoint(
          ((QmlSystem.getCurrentToken() == lowerToken) ? removeLowerEstimate : removeHigherEstimate),
          QmlSystem.getCurrentTokenDecimals()
        ) + " " + QmlSystem.getCurrentToken() + "</b>"
      }

      AVMEButton {
        id: liquidityBtn
        width: (parent.width * 0.5)
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (addToPool && addAllowance != "" && (
          !QmlSystem.isApproved(liquidityTokenInput.text, addAllowance) ||
          (liquidityCoinInput.acceptableInput && liquidityTokenInput.acceptableInput)
        )) || (!addToPool && removeAllowance != "" && (
          !QmlSystem.isApproved(liquidityTokenInput.text, removeAllowance) ||
          liquidityLPSlider.value > 0
        ))
        text: {
          if (addAllowance == "" || removeAllowance == "") {
            text: "Checking approval..."
          } else if (addToPool && QmlSystem.isApproved(liquidityTokenInput.text, addAllowance)) {
            text: "Add to the pool"
          } else if (!addToPool && QmlSystem.isApproved(liquidityTokenInput.text, removeAllowance)) {
            text: "Remove from the pool"
          } else {
            text: "Approve"
          }
        }
        onClicked: {
          var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
          if (addToPool) {
            if (!QmlSystem.isApproved(liquidityTokenInput.text, addAllowance)) {
              QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              QmlSystem.operationOverride("Approve Exchange", "", "", "")
            } else if (
              QmlSystem.hasInsufficientFunds(
                "Coin", QmlSystem.getRealMaxAVAXAmount("250000", QmlSystem.getAutomaticFee()),
                liquidityCoinInput.text
              ) || QmlSystem.hasInsufficientFunds("Token", acc.balanceAVME, liquidityTokenInput.text)
            ) {
              fundsPopup.open()
            } else {
              QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              QmlSystem.operationOverride("Add Liquidity", liquidityCoinInput.text, liquidityTokenInput.text, "")
            }
          } else {
            if (!QmlSystem.isApproved(removeLPEstimate, removeAllowance)) {
              QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              QmlSystem.operationOverride("Approve Liquidity", "", "", "")
            } else {
              QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              QmlSystem.operationOverride("Remove Liquidity", "", "", removeLPEstimate)
            }
          }
        }
      }
    }
  }

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

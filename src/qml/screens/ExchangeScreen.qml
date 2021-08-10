/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

// Screen for exchanging coins/tokens in a given Account
Item {
  id: exchangeScreen
  /*
  Connections {
    target: qmlSystem
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
      var userShares = qmlSystem.calculatePoolShares(
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
      qmlSystem.updateExchangeData("AVAX", "Token") // TODO: token name here
      calculateExchangeAmountOut()
    }
  }

  Timer {
    id: reloadLiquidityDataTimer
    interval: 5000
    repeat: true
    onTriggered: {
      qmlSystem.updateLiquidityData("AVAX", "Token") // TODO: token name here
    }
  }

  // For manual input
  function calculateAddLiquidityAmount(fromCoin) {
    var amountIn = (fromCoin) ? liquidityCoinInput.text : liquidityTokenInput.text
    var amountName = (fromCoin) ? "AVAX" : "Token"  // TODO: token name here
    var maxAmountAVAX = qmlSystem.getRealMaxAVAXAmount("250000", qmlSystem.getAutomaticFee())
    var maxAmountAVME = qmlSystem.getAccountBalances(qmlSystem.getCurrentAccount()).balanceAVME
    var amountOut, coinAmount, tokenAmount

    // Set the values accordingly
    if (amountName == lowerToken) {
      amountOut = qmlSystem.calculateAddLiquidityAmount(amountIn, lowerReserves, higherReserves)
    } else if (amountName == higherToken) {
      amountOut = qmlSystem.calculateAddLiquidityAmount(amountIn, higherReserves, lowerReserves)
    }
    if (fromCoin) {
      liquidityTokenInput.text = amountOut
    } else {
      liquidityCoinInput.text = amountOut
    }
  }

  // For the Max Amounts button
  function calculateMaxAddLiquidityAmount() {
    var maxAmountAVAX = qmlSystem.getRealMaxAVAXAmount("250000", qmlSystem.getAutomaticFee())
    var maxAmountAVME = qmlSystem.getAccountBalances(qmlSystem.getCurrentAccount()).balanceAVME
    var coinAmount, tokenAmount

    // Get the expected amounts for maxed values
    if (lowerToken == "AVAX") {
      tokenAmount = qmlSystem.calculateAddLiquidityAmount(maxAmountAVAX, lowerReserves, higherReserves)
      coinAmount = qmlSystem.calculateAddLiquidityAmount(maxAmountAVME, higherReserves, lowerReserves)
    } else if (lowerToken == "Token") { // TODO: token name here
      coinAmount = qmlSystem.calculateAddLiquidityAmount(maxAmountAVME, lowerReserves, higherReserves)
      tokenAmount = qmlSystem.calculateAddLiquidityAmount(maxAmountAVAX, higherReserves, lowerReserves)
    }

    // Limit the max amount to the lowest the user has.
    // If coinAmount is higher than the user's AVAX balance,
    // then the AVAX user balance is limiting. Same with tokenAmount and AVME.
    if (qmlSystem.firstHigherThanSecond(coinAmount, maxAmountAVAX)) {
      maxAmountAVME = tokenAmount
    }
    if (qmlSystem.firstHigherThanSecond(tokenAmount, maxAmountAVME)) {
      maxAmountAVAX = coinAmount
    }

    // Set the values accordingly
    if (lowerToken == "AVAX") {
      liquidityCoinInput.text = maxAmountAVAX
      liquidityTokenInput.text = qmlSystem.calculateAddLiquidityAmount(
        maxAmountAVAX, lowerReserves, higherReserves
      )
    } else if (lowerToken == "Token") { // TODO: token name here
      liquidityTokenInput.text = maxAmountAVME
      liquidityCoinInput.text = qmlSystem.calculateAddLiquidityAmount(
        maxAmountAVME, lowerReserves, higherReserves
      )
    }
  }
  */

  function checkTransactionFunds() {
    if (fromAssetPopup.chosenAssetSymbol == "AVAX") {  // Coin
      var hasCoinFunds = !qmlSystem.hasInsufficientFunds(
        accountHeader.coinRawBalance, qmlSystem.calculateTransactionCost(
          exchangePanel.amount, "180000", qmlSystem.getAutomaticFee()
        ), 18
      )
      return hasCoinFunds
    } else { // Token
      var hasCoinFunds = !qmlSystem.hasInsufficientFunds(
        accountHeader.coinRawBalance, qmlSystem.calculateTransactionCost(
          "0", "180000", qmlSystem.getAutomaticFee()
        ), 18
      )
      var hasTokenFunds = !qmlSystem.hasInsufficientFunds(
        accountHeader.tokenList[fromAssetPopup.chosenAssetAddress]["rawBalance"],
        exchangePanel.amount, fromAssetPopup.chosenAssetDecimals
      )
      return (hasCoinFunds && hasTokenFunds)
    }
  }

  AVMEPanelExchange {
    id: exchangePanel
    width: (parent.width * 0.5)
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      margins: 10
    }
    swapBtn.onClicked: {
      if (!checkTransactionFunds()) {
        fundsPopup.open()
      } else {
        // TODO: fix Ledger
        //if (qmlSystem.getLedgerFlag()) {
        //  checkLedger()
        //} else {
        //  confirmExchangePopup.open()
        //}
        confirmExchangePopup.open()
      }
    }
  }

  // Popups for choosing the asset going "in"/"out".
  // Defaults to "from AVAX to AVME".
  AVMEPopupAssetSelect {
    id: fromAssetPopup
    defaultToAVME: false
    Component.onCompleted: exchangePanel.fetchAllowance()
    onAboutToHide: {
      if (chosenAssetAddress == toAssetPopup.chosenAssetAddress) {
        if (chosenAssetAddress == qmlSystem.getContract("AVAX")) {
          toAssetPopup.forceAVME()
        } else {
          toAssetPopup.forceAVAX()
        }
      }
      exchangePanel.fetchAllowance()
    }
  }
  AVMEPopupAssetSelect {
    id: toAssetPopup
    defaultToAVME: true
    onAboutToHide: {
      if (chosenAssetAddress == fromAssetPopup.chosenAssetAddress) {
        if (chosenAssetAddress == qmlSystem.getContract("AVAX")) {
          fromAssetPopup.forceAVME()
        } else {
          fromAssetPopup.forceAVAX()
        }
      }
      exchangePanel.fetchAllowance()
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
    info: "Cannot send swap for 0 value."
  }

  // Popups for confirming approval and swap, respectively
  AVMEPopupConfirmTx {
    id: confirmApprovalPopup
    info: "You will approve "
    + "<b>" + fromAssetPopup.chosenAssetSymbol + "</b>"
    + " swapping for the current address<br>"
    + "<br>Gas Limit: <b>"
    + qmlSystem.weiToFixedPoint("180000", 18) + " AVAX</b>"
    + "<br>Gas Price: <b>"
    + qmlSystem.weiToFixedPoint(qmlSystem.getAutomaticFee(), 9) + " AVAX</b>"
    okBtn.onClicked: {} // TODO
  }
  AVMEPopupConfirmTx {
    id: confirmExchangePopup
    info: "You will swap "
    + "<b>" + exchangePanel.amount + " " + fromAssetPopup.chosenAssetSymbol + "</b><br>"
    + "for <b>" + exchangePanel.swapEstimate + " " + toAssetPopup.chosenAssetSymbol + "</b>"
    + "<br>Gas Limit: <b>"
    + qmlSystem.weiToFixedPoint("180000", 18) + " AVAX</b>"
    + "<br>Gas Price: <b>"
    + qmlSystem.weiToFixedPoint(qmlSystem.getAutomaticFee(), 9) + " AVAX</b>"
    okBtn.onClicked: {} // TODO
  }
}

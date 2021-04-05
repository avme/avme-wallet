import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Screen for exchanging coins/tokens in a given Account

Item {
  id: exchangeScreen
  property string addAllowance
  property string removeAllowance
  property string lowerToken
  property string lowerReserves
  property string higherToken
  property string higherReserves
  property string liquidity
  property string userLowerReserves
  property string userHigherReserves
  property string userLPSharePercentage
  property string removeLowerEstimate
  property string removeHigherEstimate
  property string removeLPEstimate

  Connections {
    target: System
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
    onAllowancesUpdated: {
      addAllowance = exchangeAllowance
      removeAllowance = liquidityAllowance
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
    System.updateLiquidityData(System.getCurrentCoin(), System.getCurrentToken())
    reloadLiquidityDataTimer.start()
  }

  Text {
    id: info
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      margins: 20
    }
    horizontalAlignment: Text.AlignHCenter
    text: "Liquidity operations for the Account<br><b>" + System.getTxSenderAccount() + "</b>"
    font.pointSize: 18.0
  }

  Rectangle {
    id: addLiquidityRect
    width: parent.width * 0.45
    height: parent.height * 0.75
    anchors {
      top: info.bottom
      left: parent.left
      margins: 20
    }
    color: "#44F66986"
    radius: 5

    Column {
      id: addLiquidityItems
      anchors.fill: parent
      spacing: 30
      anchors.topMargin: 20

      Text {
        id: addLiquidityTitle
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 14.0
        text: "Add Liquidity"
      }

      Row {
        id: addLogos
        height: 64
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20

        Image {
          id: addCoinLogo
          width: 64
          height: 64
          anchors.margins: 20
          source: "qrc:/img/avax_logo.png"
        }

        Image {
          id: addTokenLogo
          width: 64
          height: 64
          anchors.margins: 20
          source: "qrc:/img/avme_logo.png"
        }

        Text {
          id: addArrow
          font.pointSize: 42.0
          text: " -> "
        }

        Image {
          id: addLPLogo
          width: 64
          height: 64
          anchors.margins: 20
          source: "qrc:/img/pangolin.png"
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
        id: liquidityCoinInput
        width: parent.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        validator: RegExpValidator { regExp: System.createCoinRegExp() }
        label: "Amount of " + System.getCurrentCoin() + " to add"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: calculateAddLiquidityAmount(true)
      }

      AVMEInput {
        id: liquidityTokenInput
        width: parent.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        validator: RegExpValidator { regExp: System.createTokenRegExp() }
        label: "Amount of " + System.getCurrentToken() + " to add"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: calculateAddLiquidityAmount(false)
      }

      Row {
        id: liquidityAmountBtnRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        spacing: 50

        AVMEButton {
          id: liquidityMaxCoinBtn
          width: removeLiquidityRect.width * 0.4
          text: "Max " + System.getCurrentCoin() + " Amount"
          onClicked: {
            liquidityCoinInput.text = System.getTxSenderCoinAmount()  // TODO: include fees in calculation
          }
        }

        AVMEButton {
          id: liquidityMaxTokenBtn
          width: removeLiquidityRect.width * 0.4
          text: "Max " + System.getCurrentToken() + " Amount"
          onClicked: {
            liquidityTokenInput.text = System.getTxSenderTokenAmount()
          }
        }
      }

      AVMEButton {
        id: liquidityAddBtn
        width: removeLiquidityRect.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (addAllowance != "" && liquidityCoinInput.text != "" && liquidityTokenInput.text != "")
        text: {
          if (addAllowance === "") {
            text: "Checking approval..."
          } else if (System.isApproved(liquidityTokenInput.text, addAllowance)) {
            text: "Add Liquidity to Pool"
          } else {
            text: "Approve"
          }
        }
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
      }
    }
  }

  Rectangle {
    id: removeLiquidityRect
    width: parent.width * 0.45
    height: parent.height * 0.75
    anchors {
      top: info.bottom
      right: parent.right
      margins: 20
    }
    color: "#44F66986"
    radius: 5

    Column {
      id: removeLiquidityItems
      anchors.fill: parent
      spacing: 30
      anchors.topMargin: 20

      Text {
        id: removeLiquidityTitle
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 14.0
        text: "Remove Liquidity"
      }

      Row {
        id: removeLogos
        height: 64
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20

        Image {
          id: removeLPLogo
          width: 64
          height: 64
          anchors.margins: 20
          source: "qrc:/img/pangolin.png"
        }

        Text {
          id: removeArrow
          font.pointSize: 42.0
          text: " -> "
        }

        Image {
          id: removeCoinLogo
          width: 64
          height: 64
          anchors.margins: 20
          source: "qrc:/img/avax_logo.png"
        }

        Image {
          id: removeTokenLogo
          width: 64
          height: 64
          anchors.margins: 20
          source: "qrc:/img/avme_logo.png"
        }
      }

      Text {
        id: poolBalances
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: "Pooled " + System.getCurrentCoin() + ": <b>"
        + System.weiToFixedPoint(
          ((System.getCurrentCoin() == lowerToken) ? userLowerReserves : userHigherReserves),
          System.getCurrentCoinDecimals()
        ) + "</b><br>"
        + "Pooled " + System.getCurrentToken() + ": <b>"
        + System.weiToFixedPoint(
          ((System.getCurrentToken() == lowerToken) ? userLowerReserves : userHigherReserves),
          System.getCurrentTokenDecimals()
        ) + "</b><br>"
        + "Pool share (LP): <b>" + userLPSharePercentage + "% ("
        + System.getTxSenderLPFreeAmount() + ")</b>"
      }

      Slider {
        id: liquidityLPSlider
        from: 0
        value: 0
        to: 100
        stepSize: 1
        snapMode: Slider.SnapAlways
        width: parent.width * 0.8
        anchors.left: parent.left
        anchors.margins: 20
        enabled: (lowerReserves != "" && higherReserves != "" && liquidity != "")
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
          font.pointSize: 18.0
          text: parent.value + "%"
        }
      }

      // TODO: "advanced" mode (manual input instead of a slider)
      Row {
        id: sliderBtnRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20

        AVMEButton {
          id: sliderBtn25
          enabled: (lowerReserves != "" && higherReserves != "" && liquidity != "")
          width: removeLiquidityRect.width * 0.2
          text: "25%"
          onClicked: { liquidityLPSlider.value = 25; liquidityLPSlider.moved(); }
        }

        AVMEButton {
          id: sliderBtn50
          enabled: (lowerReserves != "" && higherReserves != "" && liquidity != "")
          width: removeLiquidityRect.width * 0.2
          text: "50%"
          onClicked: { liquidityLPSlider.value = 50; liquidityLPSlider.moved(); }
        }

        AVMEButton {
          id: sliderBtn75
          enabled: (lowerReserves != "" && higherReserves != "" && liquidity != "")
          width: removeLiquidityRect.width * 0.2
          text: "75%"
          onClicked: { liquidityLPSlider.value = 75; liquidityLPSlider.moved(); }
        }

        AVMEButton {
          id: sliderBtn100
          enabled: (lowerReserves != "" && higherReserves != "" && liquidity != "")
          width: removeLiquidityRect.width * 0.2
          text: "100%"
          onClicked: { liquidityLPSlider.value = 100; liquidityLPSlider.moved(); }
        }
      }

      Text {
        id: removeEstimateBalances
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: "Estimated " + System.getCurrentCoin() + " return: <b>"
        + System.weiToFixedPoint(
          ((System.getCurrentCoin() == lowerToken) ? removeLowerEstimate : removeHigherEstimate),
          System.getCurrentCoinDecimals()
        ) + "</b><br>"
        + "Estimated " + System.getCurrentToken() + " return: <b>"
        + System.weiToFixedPoint(
          ((System.getCurrentToken() == lowerToken) ? removeLowerEstimate : removeHigherEstimate),
          System.getCurrentTokenDecimals()
        ) + "</b><br>"
        + "Share cost (LP): <b>" + ((removeLPEstimate) ? removeLPEstimate : "0")
      }

      AVMEButton {
        id: liquidityRemoveBtn
        width: parent.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (removeAllowance != "" && liquidityLPSlider.value > 0)
        text: {
          if (removeAllowance == "") {
            text: "Checking approval..."
          } else if (System.isApproved(System.getTxSenderLPFreeAmount(), removeAllowance)) {
            text: "Remove Liquidity from Pool"
          } else {
            text: "Approve"
          }
        }
        onClicked: {
          System.setTxGasLimit("250000")
          System.setTxGasPrice(System.getAutomaticFee())
          if (!System.isApproved(liquidityTokenInput.text, removeAllowance)) {
            approveLiquidityPopup.setTxData(System.getTxGasLimit(), System.getTxGasPrice())
            approveLiquidityPopup.open()
            return
          }

          var noCoinFunds = System.hasInsufficientCoinFunds(
            System.getTxSenderCoinAmount(),
            System.calculateTransactionCost(
              "0", System.getTxGasLimit(), System.getTxGasPrice()
            )
          )

          if (noCoinFunds) {
            fundsPopup.open()
          } else {
            confirmRemoveLPPopup.setTxData(
              System.weiToFixedPoint(
                ((System.getCurrentCoin() == lowerToken) ? removeLowerEstimate : removeHigherEstimate),
                System.getCurrentCoinDecimals()
              ), System.getCurrentCoin(),
              System.weiToFixedPoint(
                ((System.getCurrentToken() == lowerToken) ? removeLowerEstimate : removeHigherEstimate),
                System.getCurrentTokenDecimals()
              ), System.getCurrentToken(),
              System.getTxGasLimit(), System.getTxGasPrice()
            )
            confirmRemoveLPPopup.open()
          }
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
      reloadLiquidityDataTimer.stop()
      System.setScreen(content, "qml/screens/StatsScreen.qml")
    }
  }

  // Popups for confirming approval to add (same as exchange) and remove liquidity
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

  AVMEPopupApprove {
    id: approveLiquidityPopup
    confirmBtn.onClicked: {
      if (System.checkWalletPass(pass)) {
        System.setTxOperation("Approve Liquidity")
        System.setScreen(content, "qml/screens/ProgressScreen.qml")
        System.txStart(pass)
      } else {
        approveLiquidityPopup.showErrorMsg()
      }
    }
  }

  // Popups for confirming addition/removal of funds to/from the pool
  AVMEPopupConfirmAddLP {
    id: confirmAddLPPopup
    confirmBtn.onClicked: {
      if (System.checkWalletPass(pass)) {
        System.setTxReceiverCoinAmount(liquidityCoinInput.text)
        System.setTxReceiverTokenAmount(liquidityTokenInput.text)
        System.setTxOperation("Add Liquidity")
        System.setScreen(content, "qml/screens/ProgressScreen.qml")
        System.txStart(pass)
      } else {
        confirmAddLPPopup.showErrorMsg()
      }
    }
  }

  AVMEPopupConfirmRemoveLP {
    id: confirmRemoveLPPopup
    confirmBtn.onClicked: {
      if (System.checkWalletPass(pass)) {
        System.setTxReceiverCoinAmount(System.weiToFixedPoint(
          ((System.getCurrentCoin() == lowerToken) ? removeLowerEstimate : removeHigherEstimate),
          System.getCurrentCoinDecimals()
        ))
        System.setTxReceiverTokenAmount(System.weiToFixedPoint(
          ((System.getCurrentToken() == lowerToken) ? removeLowerEstimate : removeHigherEstimate),
          System.getCurrentTokenDecimals()
        ))
        System.setTxReceiverLPAmount(System.fixedPointToWei(removeLPEstimate, 18))
        System.setTxOperation("Remove Liquidity")
        System.setScreen(content, "qml/screens/ProgressScreen.qml")
        System.txStart(pass)
      } else {
        confirmRemoveLPPopup.showErrorMsg()
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

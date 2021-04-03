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
    }
  }

  Component.onCompleted: {
    allowance = System.getExchangeAllowance()
    System.updateExchangeData(System.getCurrentCoin(), System.getCurrentToken())
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
    text: "Liquidity operations for the Account<br><b>" + System.getTxSenderAccount() + "</b>"
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
    id: addLiquidityRect
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
        enabled: (liquidityCoinInput.text != "" && liquidityTokenInput.text != "")
        text: "Add Liquidity to Pool"
        onClicked: {} // TODO: this, also check if both values are non-zero
      }
    }
  }

  Rectangle {
    id: removeLiquidityRect
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

      AVMEInput {
        id: liquidityLPInput
        width: parent.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        validator: RegExpValidator { regExp: System.createCoinRegExp() }  // TODO: fixed regexp
        label: "Amount of LP to remove"
        placeholder: "Fixed point amount (e.g. 0.5)"
      }

      AVMEButton {
        id: liquidityMaxLPBtn
        width: parent.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Max LP Amount"
        onClicked: {
          liquidityLPInput.text = System.getTxSenderLPFreeAmount()  // TODO: include fees in calculation
        }
      }

      AVMEButton {
        id: liquidityRemoveBtn
        width: parent.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (liquidityLPInput.text != "")
        text: "Remove Liquidity from Pool"
        onClicked: {} // TODO: this, also check if both values are non-zero
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
  // TODO: change this
  AVMEPopupApproveExchange {
    id: approveExchangePopup
    confirmBtn.onClicked: {
      System.setTxOperation("Approve Exchange")
      System.setScreen(content, "qml/screens/ProgressScreen.qml")
      System.txStart(pass)
    }
  }

  // Popup for confirming the exchange operation
  // TODO: change this
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

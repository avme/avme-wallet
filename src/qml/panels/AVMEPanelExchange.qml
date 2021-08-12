/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import QmlApi 1.0

import "qrc:/qml/components"

// Panel for exchanging coins/tokens in a given Account
AVMEPanel {
  id: exchangePanel
  title: "Exchange Details"
  property string allowance
  property string pairAddress
  property string inReserves
  property string outReserves
  property string swapEstimate
  property double swapImpact
  property alias amount: swapInput.text
  property alias swapBtn: btnSwap

  QmlApi { id: qmlApi }

  Connections {
    target: accountHeader
    function onUpdatedBalances() { refreshAssetBalance() }
  }

  Connections {
    target: qmlApi
    function onApiRequestAnswered(answer, requestID) {
      if (requestID == "QmlExchange_fetchAllowance") {
        var resp = JSON.parse(answer)
        allowance = qmlApi.parseHex(resp[0].result, ["uint"])
        pairAddress = qmlApi.parseHex(resp[1].result, ["address"])
        // AVAX doesn't need approval, tokens do (and individually)
        if (fromAssetPopup.chosenAssetSymbol == "AVAX") {
          exchangeDetailsColumn.visible = true
        } else {
          var asset = accountHeader.tokenList[fromAssetPopup.chosenAssetAddress]
          exchangeDetailsColumn.visible = (+allowance >= +qmlSystem.fixedPointToWei(
            asset["rawBalance"], fromAssetPopup.chosenAssetDecimals
          ))
        }
        qmlApi.clearAPIRequests("QmlExchange_refreshReserves")
        qmlApi.buildGetReservesReq(pairAddress, "QmlExchange_refreshReserves")
        qmlApi.doAPIRequests("QmlExchange_refreshReserves")
      } else if (requestID == "QmlExchange_refreshReserves") {
        var resp = JSON.parse(answer)
        var reserves = qmlApi.parseHex(resp[0].result, ["uint", "uint", "uint"])
        var lowerAddress = qmlSystem.getFirstFromPair(
          fromAssetPopup.chosenAssetAddress, toAssetPopup.chosenAssetAddress
        )
        if (lowerAddress == fromAssetPopup.chosenAssetAddress) {
          inReserves = reserves[0]
          outReserves = reserves[1]
        } else if (lowerAddress == toAssetPopup.chosenAssetAddress) {
          inReserves = reserves[1]
          outReserves = reserves[0]
        }
      }
    }
  }

  function fetchAllowance() {
    refreshAssetBalance()
    swapInput.text = swapEstimate = swapImpact = inReserves = outReserves = ""
    qmlApi.clearAPIRequests("QmlExchange_fetchAllowance")
    qmlApi.buildGetAllowanceReq(
      fromAssetPopup.chosenAssetAddress,
      qmlSystem.getCurrentAccount(),
      qmlSystem.getContract("router"),
      "QmlExchange_fetchAllowance"
    )
    qmlApi.buildGetPairReq(
      fromAssetPopup.chosenAssetAddress,
      toAssetPopup.chosenAssetAddress,
      "QmlExchange_fetchAllowance"
    )
    qmlApi.doAPIRequests("QmlExchange_fetchAllowance")
  }

  function refreshAssetBalance() {
    if (fromAssetPopup.chosenAssetSymbol == "AVAX") {
      assetBalance.text = (accountHeader.coinRawBalance != "")
      ? "Balance: <b>" + accountHeader.coinRawBalance + " AVAX</b>"
      : "Loading asset balance..."
    } else {
      var asset = accountHeader.tokenList[fromAssetPopup.chosenAssetAddress]
      assetBalance.text = (asset != undefined)
      ? "Balance: <b>" + asset["rawBalance"]
      + " " + fromAssetPopup.chosenAssetSymbol + "</b>"
      : "Loading asset balance..."
    }
  }

  Column {
    id: exchangeHeaderColumn
    height: (parent.height * 0.5) - anchors.topMargin
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      topMargin: 80
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 20

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
          var avmeAddress = qmlSystem.getAVMEAddress()
          if (fromAssetPopup.chosenAssetSymbol == "AVAX") {
            source: "qrc:/img/avax_logo.png"
          } else if (fromAssetPopup.chosenAssetAddress == avmeAddress) {
            source: "qrc:/img/avme_logo.png"
          } else {
            var img = qmlSystem.getARC20TokenImage(fromAssetPopup.chosenAssetAddress)
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
          var avmeAddress = qmlSystem.getAVMEAddress()
          if (toAssetPopup.chosenAssetSymbol == "AVAX") {
            source: "qrc:/img/avax_logo.png"
          } else if (toAssetPopup.chosenAssetAddress == avmeAddress) {
            source: "qrc:/img/avme_logo.png"
          } else {
            var img = qmlSystem.getARC20TokenImage(toAssetPopup.chosenAssetAddress)
            source: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
          }
        }
      }
    }

    Text {
      id: assetBalance
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Loading asset balance..."
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
  }

  Column {
    id: exchangeApprovalColumn
    visible: !exchangeDetailsColumn.visible
    anchors {
      top: exchangeHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: 20
      bottomMargin: 20
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 20

    Text {
      id: exchangeApprovalText
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "You need to approve your Account in order to swap <b>"
      + fromAssetPopup.chosenAssetSymbol + "</b>."
      + "<br>This operation will have a total gas cost of:<br><b>"
      + qmlSystem.calculateTransactionCost("0", "180000", qmlSystem.getAutomaticFee())
      + " AVAX</b>"
    }

    AVMEButton {
      id: approveBtn
      width: parent.width
      enabled: (+accountHeader.coinRawBalance >=
        +qmlSystem.calculateTransactionCost("0", "180000", qmlSystem.getAutomaticFee())
      )
      anchors.horizontalCenter: parent.horizontalCenter
      text: (enabled) ? "Approve" : "Not enough funds"
      onClicked: confirmAddApprovalPopup.open()
    }
  }

  Column {
    id: exchangeDetailsColumn
    anchors {
      top: exchangeHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: 20
      bottomMargin: 20
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 20

    AVMEInput {
      id: swapInput
      width: (parent.width * 0.8)
      validator: RegExpValidator {
        regExp: qmlSystem.createTxRegExp(fromAssetPopup.chosenAssetDecimals)
      }
      enabled: (inReserves != "" && outReserves != "")
      label: fromAssetPopup.chosenAssetSymbol + " Amount"
      placeholder: (enabled) ? "Fixed point amount (e.g. 0.5)" : "Loading reserves..."
      onTextEdited: {
        swapEstimate = qmlSystem.calculateExchangeAmount(
          swapInput.text, inReserves, outReserves
        )
        swapImpact = qmlSystem.calculateExchangePriceImpact(
          inReserves, swapInput.text, 18
        )
      }

      AVMEButton {
        id: swapMaxBtn
        width: (parent.parent.width * 0.2) - anchors.leftMargin
        anchors {
          left: parent.right
          leftMargin: 10
        }
        text: "Max"
        onClicked: {
          swapInput.text = (fromAssetPopup.chosenAssetSymbol == "AVAX")
            ? qmlSystem.getRealMaxAVAXAmount(
              accountHeader.coinRawBalance, "180000", qmlSystem.getAutomaticFee()
            )
            : accountHeader.tokenList[fromAssetPopup.chosenAssetAddress]["rawBalance"]
          swapEstimate = qmlSystem.calculateExchangeAmount(
            swapInput.text, inReserves, outReserves
          )
          swapImpact = qmlSystem.calculateExchangePriceImpact(
            inReserves, swapInput.text, 18
          )
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
      font.pixelSize: 14.0
      text: "Estimated return: <b>"
      + swapEstimate + " " + toAssetPopup.chosenAssetSymbol + "</b> "
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
      id: btnSwap
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (
        swapInput.acceptableInput && (swapImpact <= 10.0 || ignoreImpactCheck.checked)
      )
      text: (swapImpact <= 10.0 || ignoreImpactCheck.checked)
      ? "Make Swap" : "Price impact too high"
      /*
      onClicked: {
        if (!qmlSystem.isApproved(swapInput.text, allowance)) {
          qmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
          qmlSystem.operationOverride("Approve Exchange", "", "", "")
        } else if (coinToToken) {
          if (qmlSystem.balanceIsZero(swapInput.text, 18)) {
            zeroSwapPopup.open()
          } else {
            if (qmlSystem.hasInsufficientFunds(
              "Coin", qmlSystem.getRealMaxAVAXAmount("180000", qmlSystem.getAutomaticFee()), swapInput.text
            )) {
              fundsPopup.open()
            } else {
              qmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              qmlSystem.operationOverride("Swap AVAX -> AVME", swapInput.text, swapEstimate, "")
            }
          }
        } else {
          var acc = qmlSystem.getAccountBalances(qmlSystem.getCurrentAccount())
          if (qmlSystem.balanceIsZero(swapInput.text, 18)) {
            zeroSwapPopup.open()
          } else {
            if (qmlSystem.hasInsufficientFunds("Token", acc.balanceAVME, swapInput.text)) {
              fundsPopup.open()
            } else {
              qmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              qmlSystem.operationOverride("Swap AVME -> AVAX", swapEstimate, swapInput.text, "")
            }
          }
        }
      }
      */
    }
  }
}

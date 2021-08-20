/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import QmlApi 1.0

import "qrc:/qml/components"

/**
 * Panel for exchanging coins/tokens in a given Account.
 * Example for reserves:
 * Single token swap (e.g AVME -> AVAX)
 *  [
 *    {
 *      pair: "0xabcd..."
 *      reservesIn: "xyz"
 *      reservesOut: "xyz"
 *    }
 *  ]
 *
 * Multiple token swap (e.g AVME -> AVAX, then AVAX -> SNOB)
 * [
 *   {
 *     pair: "0xabcd..."
 *     reservesIn: "xyz"
 *     reservesOut: "xyz"
 *   },
 *   {
 *     pair: "0xabcd..."
 *     reservesIn: "xyz"
 *     reservesOut: "xyz"
 *   }
 * ]
 */
AVMEPanel {
  id: exchangePanel
  title: "Exchange Details"
  property string allowance
  property string pairAddress
  property var reservesList: {[]}
  property var pairAddresses: ([])
  property string swapEstimate
  property string pairTokenInAddress
  property string pairTokenOutAddress
  property string randomID
  property bool needRoute
  property double swapImpact
  property alias amountIn: swapInput.text
  property alias swapBtn: btnSwap
  property alias approveBtn: btnApprove
  property string to
  property string coinValue
  property string txData
  property string gas
  property string gasPrice
  property bool automaticGas: true
  property string info
  property string historyInfo

  Timer { id: reservesTimer; interval: 1000; repeat: true; onTriggered: (refreshReserves()) }
  Timer { id: allowanceTimer; interval: 100; repeat: true; onTriggered: (fetchAllowance(false)) }
  // Timer is needed, because declaring on the variable itself doesn't cause it to change.
  Timer { id: swapTimer; interval: 10; repeat: true; onTriggered: {
      swapEstimate = calculateExchangeAmount(swapInput.text, fromAssetPopup.chosenAssetDecimals, toAssetPopup.chosenAssetDecimals)
      swapImpact = calculatePriceImpact(swapInput.text, fromAssetPopup.chosenAssetDecimals, toAssetPopup.chosenAssetDecimals)
    }
  }
  
  Connections {
    target: txProgressPopup
    function onClosed() { allowanceTimer.start() }
  }

  Connections {
    target: accountHeader
    function onUpdatedBalances() { refreshAssetBalance() }
  }

  Connections {
    target: qmlApi
    function onApiRequestAnswered(answer, requestID) {
      if (requestID == "QmlExchange_fetchAllowance") {
        var respArr = JSON.parse(answer)
        needRoute = false;
        allowance = ""
        pairAddress = ""
        pairTokenInAddress = ""
        pairTokenOutAddress = ""
        // Loop the answer, as we know, API requests can answer unordered.
        for (var answerItem in respArr) {
          if (respArr[answerItem]["id"] == 1) {
            allowance = qmlApi.parseHex(respArr[answerItem].result, ["uint"])
          }
          if (respArr[answerItem]["id"] == 2) {
            pairAddress = qmlApi.parseHex(respArr[answerItem].result, ["address"])
          }
          if (respArr[answerItem]["id"] == 3) {
            pairTokenInAddress = qmlApi.parseHex(respArr[answerItem].result, ["address"])
          }
          if (respArr[answerItem]["id"] == 4) {
            pairTokenOutAddress = qmlApi.parseHex(respArr[answerItem].result, ["address"])
          }
        }
        // AVAX doesn't need approval, tokens do (and individually)
        if (fromAssetPopup.chosenAssetSymbol == "AVAX") {
          allowanceTimer.stop()
          reservesTimer.start()
          return
        } else {
          var asset = accountHeader.tokenList[fromAssetPopup.chosenAssetAddress]
          if (+allowance <= +qmlSystem.fixedPointToWei(
            asset["rawBalance"], fromAssetPopup.chosenAssetDecimals
          )) {
            exchangeApprovalColumn.visible = true
            exchangeDetailsColumn.visible = false
            exchangeLoadingPng.visible = false
            return
          }
        }
        allowanceTimer.stop()
        reservesTimer.start()
      } else if (requestID == "QmlExchange_refreshReserves_" + randomID) {
        var resp = JSON.parse(answer)
        reservesList = ([])
        if (!needRoute) {
          var reservesAnswer = qmlApi.parseHex(resp[0].result, ["uint", "uint", "uint"])
          var reserves = ({})
          var lowerAddress = qmlSystem.getFirstFromPair(
            fromAssetPopup.chosenAssetAddress, toAssetPopup.chosenAssetAddress
          )
          if (lowerAddress == fromAssetPopup.chosenAssetAddress) {
            reserves["inReserves"] = reservesAnswer[0]
            reserves["outReserves"] = reservesAnswer[1]
          } else if (lowerAddress == toAssetPopup.chosenAssetAddress) {
            reserves["inReserves"] = reservesAnswer[1]
            reserves["outReserves"] = reservesAnswer[0]
          }
          reserves["pair"] = pairAddress
          reservesList.push(reserves)
        } else {
          // API can answer UNORDERED! we need to keep track properly
          var reservesTokenIn = ({})
          var reservesTokenOut = ({})
          for (var i = 0; i < resp.length; ++i) {
            // ID = 1 means reservesTokenIn
            // ID = 2 means reservesTokenOut
            if (resp[i]["id"] == 1) {
              var reservesAnswer = qmlApi.parseHex(resp[i].result, ["uint", "uint", "uint"])
              var reserves = ({})
              var lowerAddress = qmlSystem.getFirstFromPair(
                fromAssetPopup.chosenAssetAddress, qmlSystem.getContract("AVAX")
              )
              if (lowerAddress == fromAssetPopup.chosenAssetAddress) {
                reserves["inReserves"] = reservesAnswer[0]
                reserves["outReserves"] = reservesAnswer[1]
              } else if (lowerAddress == qmlSystem.getContract("AVAX")) {
                reserves["inReserves"] = reservesAnswer[1]
                reserves["outReserves"] = reservesAnswer[0]
              }
              reserves["pair"] = pairAddresses[0]
              reservesList.push(reserves)
            }
            if (resp[i]["id"] == 2) {
              var reservesAnswer = qmlApi.parseHex(resp[i].result, ["uint", "uint", "uint"])
              var reserves = ({})
              var lowerAddress = qmlSystem.getFirstFromPair(
                toAssetPopup.chosenAssetAddress, qmlSystem.getContract("AVAX")
              )
              if (lowerAddress == qmlSystem.getContract("AVAX")) {
                reserves["inReserves"] = reservesAnswer[0]
                reserves["outReserves"] = reservesAnswer[1]
              } else if (lowerAddress == toAssetPopup.chosenAssetAddress) {
                reserves["inReserves"] = reservesAnswer[1]
                reserves["outReserves"] = reservesAnswer[0]
              }
              reserves["pair"] = pairAddresses[1]
              reservesList.push(reserves)
            }
          }
        }
        exchangeApprovalColumn.visible = false
        exchangeDetailsColumn.visible = true
        exchangeLoadingPng.visible = false
        qmlApi.clearAPIRequests("QmlExchange_refreshReserves_" + randomID)
      }
    }
  }

  function calculateExchangeAmount(amountIn, inDecimals, outDecimals) {
    if (!needRoute) {
      amountIn = qmlSystem.calculateExchangeAmount(amountIn, reservesList[0]["inReserves"], reservesList[0]["outReserves"], inDecimals, outDecimals)
    } else {
      amountIn = qmlSystem.calculateExchangeAmount(amountIn, reservesList[0]["inReserves"], reservesList[0]["outReserves"], inDecimals, 18)
      amountIn = qmlSystem.calculateExchangeAmount(amountIn, reservesList[1]["inReserves"], reservesList[1]["outReserves"], 18, outDecimals)
    }
    return amountIn
  }

  function refreshReserves() {
    qmlApi.clearAPIRequests("QmlExchange_refreshReserves_" + randomID)
    // Check if there are reserves for the optimal pair (tokenIn/tokenOut).
    // If not, get request for pair tokenIn/WAVAX/tokenOut.
    pairAddresses = ([])
    if (pairAddress == "0x0000000000000000000000000000000000000000") {
      needRoute = true;
      // id 1 == first Pair reserves
      // id 2 == second Pair reserves
      pairAddresses.push(pairTokenInAddress)
      pairAddresses.push(pairTokenOutAddress)
      qmlApi.buildGetReservesReq(pairTokenInAddress, "QmlExchange_refreshReserves_" + randomID)
      qmlApi.buildGetReservesReq(pairTokenOutAddress, "QmlExchange_refreshReserves_" + randomID)
    } else {
      // id 1 == pairAddress reserves
      pairAddresses.push(pairAddress)
      qmlApi.buildGetReservesReq(pairAddress, "QmlExchange_refreshReserves_" + randomID)
    }
    qmlApi.doAPIRequests("QmlExchange_refreshReserves_" + randomID)
  }

  function fetchAllowance(firstCall) {
    if (firstCall) {
      refreshAssetBalance()
      swapTimer.stop()
      reservesTimer.stop()
      randomID = qmlApi.getRandomID()
      swapInput.text = swapEstimate = swapImpact = ""
      needRoute = false
      exchangeApprovalColumn.visible = false
      exchangeDetailsColumn.visible = false
      exchangeLoadingPng.visible = true
      reservesList = ([])
    }
    qmlApi.clearAPIRequests("QmlExchange_fetchAllowance")
    // Get allowance for inToken and reserves for all
    // Including reserves for both in/out tokens against WAVAX
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
    qmlApi.buildGetPairReq(
      fromAssetPopup.chosenAssetAddress,
      qmlSystem.getContract("AVAX"),
      "QmlExchange_fetchAllowance"
    )
    qmlApi.buildGetPairReq(
      qmlSystem.getContract("AVAX"),
      toAssetPopup.chosenAssetAddress,
      "QmlExchange_fetchAllowance"
    )
    // id 1: allowance for inToken
    // id 2: Pair contract for inToken/outToken
    // id 3: Pair contract for inToken/WAVAX
    // id 4: Pair contract for outToken/WAVAX
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
  function calculatePriceImpact(amountIn, inDecimals, outDecimals) {
    return qmlSystem.calculateExchangePriceImpact(reservesList[0]["inReserves"], amountIn, inDecimals)
  }

  function approveTx() {
    to = fromAssetPopup.chosenAssetAddress
    coinValue = 0
    gas = 100000
    gasPrice = 225
    info = "You will Approve <b>" + fromAssetPopup.chosenAssetSymbol + "<\b> on Pangolin Router Contract"
    historyInfo = "Approve <b>" + fromAssetPopup.chosenAssetSymbol + "<\b< on Pangolin"

    var ethCallJson = ({})
    ethCallJson["function"] = "approve(address,uint256)"
    ethCallJson["args"] = []
    ethCallJson["args"].push(qmlSystem.getContract("router"))
    ethCallJson["args"].push(qmlApi.MAX_U256_VALUE())
    ethCallJson["types"] = []
    ethCallJson["types"].push("address")
    ethCallJson["types"].push("uint*")
    var ethCallString = JSON.stringify(ethCallJson)
    var ABI = qmlApi.buildCustomABI(ethCallString)
    txData = ABI
  }

  function swapTx(amountIn, amountOut) {
    to = qmlSystem.getContract("router")
    gas = 300000
    gasPrice = 225
    info = "You will Swap <b>" + amountIn + " " + fromAssetPopup.chosenAssetSymbol + "<\b> to <b>"
    info += amountOut + " " + toAssetPopup.chosenAssetSymbol + "<\b> on Pangolin"
    historyInfo = "Swap <b>" + fromAssetPopup.chosenAssetSymbol + "<\b> to <b>" + toAssetPopup.chosenAssetSymbol + "<\b>"
    if (fromAssetPopup.chosenAssetSymbol == "AVAX") {
      coinValue = String(amountIn)
      var ethCallJson = ({})
      var routing = ([])
      ethCallJson["function"] = "swapExactAVAXForTokens(uint256,address[],address,uint256)"
      ethCallJson["args"] = []
      // 1% Slippage TODO: Add setting to change slippage
      //uint256 amountOutMin
      ethCallJson["args"].push(String(Math.round(+qmlApi.fixedPointToWei(amountOut, toAssetPopup.chosenAssetDecimals) * 0.99)))
      //address[] path
      routing.push(qmlSystem.getContract("AVAX"))
      routing.push(toAssetPopup.chosenAssetAddress)
      ethCallJson["args"].push(routing)
      //address to
      ethCallJson["args"].push(qmlSystem.getCurrentAccount())
      //uint256 deadline, 60 minutes deadline
      ethCallJson["args"].push(String((+qmlApi.getCurrentUnixTime() + 3600) * 1000))
      ethCallJson["types"] = []
      ethCallJson["types"].push("uint*")
      ethCallJson["types"].push("address[]")
      ethCallJson["types"].push("address")
      ethCallJson["types"].push("uint*")
      var ethCallString = JSON.stringify(ethCallJson)
      var ABI = qmlApi.buildCustomABI(ethCallString)
      txData = ABI
      return;
    }
    if (toAssetPopup.chosenAssetSymbol == "AVAX") {
      coinValue = 0
      var ethCallJson = ({})
      var routing = ([])
      ethCallJson["function"] = "swapExactTokensForAVAX(uint256,uint256,address[],address,uint256)"
      ethCallJson["args"] = []
      // uint256 amountIn
      ethCallJson["args"].push(String(qmlApi.fixedPointToWei(amountIn, toAssetPopup.chosenAssetDecimals)))
      // 1% Slippage TODO: Add setting to change slippage
      // amountOutMin
      ethCallJson["args"].push(String(Math.round(+qmlApi.fixedPointToWei(amountOut, toAssetPopup.chosenAssetDecimals) * 0.99)))
      // address[] path
      routing.push(fromAssetPopup.chosenAssetAddress)
      routing.push(qmlSystem.getContract("AVAX"))
      ethCallJson["args"].push(routing)
      // address to
      ethCallJson["args"].push(qmlSystem.getCurrentAccount())
      // uint256 deadline 60 minutes deadline
      ethCallJson["args"].push(String((+qmlApi.getCurrentUnixTime() + 3600) * 1000))
      ethCallJson["types"] = []
      ethCallJson["types"].push("uint*")
      ethCallJson["types"].push("uint*")
      ethCallJson["types"].push("address[]")
      ethCallJson["types"].push("address")
      ethCallJson["types"].push("uint*")
      var ethCallString = JSON.stringify(ethCallJson)
      var ABI = qmlApi.buildCustomABI(ethCallString)
      txData = ABI
      return;
    }
    if (toAssetPopup.chosenAssetSymbol != "AVAX" && fromAssetPopup.chosenAssetSymbol != "AVAX") {
      coinValue = 0
      var ethCallJson = ({})
      var routing = ([])
      ethCallJson["function"] = "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)"
      ethCallJson["args"] = []
      // uint256 amountIn
      ethCallJson["args"].push(String(qmlApi.fixedPointToWei(amountIn, toAssetPopup.chosenAssetDecimals)))
      // 1% Slippage TODO: Add setting to change slippage
      // amountOutMin
      ethCallJson["args"].push(String(Math.round(+qmlApi.fixedPointToWei(amountOut, toAssetPopup.chosenAssetDecimals) * 0.99)))
      // address[] path
      routing.push(fromAssetPopup.chosenAssetAddress)
      if (needRoute) {
        routing.push(qmlSystem.getContract("AVAX"))
      }
      routing.push(toAssetPopup.chosenAssetAddress)
      ethCallJson["args"].push(routing)
      // address to
      ethCallJson["args"].push(qmlSystem.getCurrentAccount())
      // uint256 deadline 60 minutes deadline
      ethCallJson["args"].push(String((+qmlApi.getCurrentUnixTime() + 3600) * 1000))
      ethCallJson["types"] = []
      ethCallJson["types"].push("uint*")
      ethCallJson["types"].push("uint*")
      ethCallJson["types"].push("address[]")
      ethCallJson["types"].push("address")
      ethCallJson["types"].push("uint*")
      var ethCallString = JSON.stringify(ethCallJson)
      var ABI = qmlApi.buildCustomABI(ethCallString)
      txData = ABI
      return;
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
      id: btnApprove
      width: parent.width
      enabled: (+accountHeader.coinRawBalance >=
        +qmlSystem.calculateTransactionCost("0", "180000", qmlSystem.getAutomaticFee())
      )
      anchors.horizontalCenter: parent.horizontalCenter
      text: (enabled) ? "Approve" : "Not enough funds"
    }
  }

  Image {
    id: exchangeLoadingPng
    anchors {
      top: exchangeHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: parent.height * 0.1
      bottomMargin: parent.height * 0.1
    }
    fillMode: Image.PreserveAspectFit
    source: "qrc:/img/icons/loading.png"
    RotationAnimator {
      target: exchangeLoadingPng
      from: 0
      to: 360
      duration: 1000
      loops: Animation.Infinite
      easing.type: Easing.InOutQuad
      running: true
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
      label: fromAssetPopup.chosenAssetSymbol + " Amount"
      placeholder: (enabled) ? "Fixed point amount (e.g. 0.5)" : "Loading reserves..."
      onTextEdited: {
        swapTimer.start()
      }
      AVMEButton {
        id: swapMaxBtn
        width: (parent.parent.width * 0.2) - 10
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
          swapTimer.start()
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
    }
  }
}

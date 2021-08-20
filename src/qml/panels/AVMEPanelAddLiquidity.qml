/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import QmlApi 1.0

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Panel for adding liquidity to a pool.
AVMEPanel {
  id: addLiquidityPanel
  title: "Add Liquidity"
  property string asset1Allowance
  property string asset2Allowance
  property string asset1Reserves
  property string asset2Reserves
  property string asset1Balance
  property string asset2Balance
  property string pglSupply
  property bool asset1Approved
  property bool asset2Approved
  property string pairAddress
  property alias add1Amount: addAsset1Input.text
  property alias add2Amount: addAsset2Input.text
  property alias addBtn: addLiquidityBtn
  property bool loading: true
  property string to
  property string coinValue
  property string txData
  property string gas
  property string gasPrice
  property bool automaticGas: true
  property string info
  property string historyInfo

  Connections {
    target: accountHeader
    function onUpdatedBalances() { refreshAssetBalance() }
  }

  Connections {
    target: txProgressPopup
    function onClosed() { fetchAllowancesAndPair() }
  }

  Connections {
    target: qmlApi
    function onApiRequestAnswered(answer, requestID) {
      var resp = JSON.parse(answer)
      if (requestID == "QmlAddLiquidity_fetchAllowancesAndPair") {
        for (var item in resp) {
          if (resp[item]["id"] == 1) {
            pairAddress = qmlApi.parseHex(resp[item].result, ["address"])
          }  
          if (resp[item]["id"] == 2) {
            asset1Allowance = qmlApi.parseHex(resp[item].result, ["uint"])
          }
          if (resp[item]["id"] == 3) {
            asset2Allowance = qmlApi.parseHex(resp[item].result, ["uint"])
          }
        }
        if (pairAddress == "0x0000000000000000000000000000000000000000") {
          addLiquidityDetailsColumn.visible = false
          addLiquidityApprovalColumn.visible = false
          addLiquidityPairUnavailable.visible = true
          loading = false;
          return
        }
        // AVAX doesn't need approval, tokens do (and individually)
        if (addAsset1Popup.chosenAssetSymbol == "AVAX") {
          asset1Approved = true
        } else {
          var asset1 = accountHeader.tokenList[addAsset1Popup.chosenAssetAddress]
          asset1Approved = (+asset1Allowance > +qmlSystem.fixedPointToWei(
            asset1["rawBalance"], addAsset1Popup.chosenAssetDecimals
          ))
        }
        if (addAsset2Popup.chosenAssetSymbol == "AVAX") {
          asset2Approved = true
        } else {
          var asset2 = accountHeader.tokenList[addAsset2Popup.chosenAssetAddress]
          asset2Approved = (+asset2Allowance > +qmlSystem.fixedPointToWei(
            asset2["rawBalance"], addAsset2Popup.chosenAssetDecimals
          ))
        }
        if (asset1Approved && asset2Approved) {
          fetchReserves()
        } else {
          addLiquidityDetailsColumn.visible = false
          addLiquidityApprovalColumn.visible = true
          addLiquidityPairUnavailable.visible = false
          loading = false
        }
      } else if (requestID == "QmlAddLiquidity_fetchReserves") {
        var reserves 
        for (var item in resp) {
          if (resp[item]["id"] == 1) {
            reserves = qmlApi.parseHex(resp[item].result, ["uint", "uint", "uint"])
          }  
          if (resp[item]["id"] == 2) {
            pglSupply = qmlApi.parseHex(resp[item].result, ["uint"])
          }
        }
        var reserves = qmlApi.parseHex(resp[0].result, ["uint", "uint", "uint"])
        var lowerAddress = qmlSystem.getFirstFromPair(
          addAsset1Popup.chosenAssetAddress, addAsset2Popup.chosenAssetAddress
        )
        if (lowerAddress == addAsset1Popup.chosenAssetAddress) {
          asset1Reserves = reserves[0]
          asset2Reserves = reserves[1]
        } else if (lowerAddress == addAsset2Popup.chosenAssetAddress) {
          asset1Reserves = reserves[1]
          asset2Reserves = reserves[0]
        }
        loading = false;
        addLiquidityDetailsColumn.visible = true
        addLiquidityApprovalColumn.visible = false
        addLiquidityPairUnavailable.visible = false
      }
    }
  }

  function fetchAllowancesAndPair() {
    addLiquidityDetailsColumn.visible = false
    addLiquidityApprovalColumn.visible = false
    addLiquidityPairUnavailable.visible = false
    loading = true
    refreshAssetBalance()
    asset1Allowance = asset2Allowance = ""
    qmlApi.clearAPIRequests("QmlAddLiquidity_fetchAllowancesAndPair")
    qmlApi.buildGetPairReq(
      addAsset1Popup.chosenAssetAddress,
      addAsset2Popup.chosenAssetAddress,
      "QmlAddLiquidity_fetchAllowancesAndPair"
    )
    qmlApi.buildGetAllowanceReq(
      addAsset1Popup.chosenAssetAddress,
      qmlSystem.getCurrentAccount(),
      qmlSystem.getContract("router"),
      "QmlAddLiquidity_fetchAllowancesAndPair"
    )
    qmlApi.buildGetAllowanceReq(
      addAsset2Popup.chosenAssetAddress,
      qmlSystem.getCurrentAccount(),
      qmlSystem.getContract("router"),
      "QmlAddLiquidity_fetchAllowancesAndPair"
    )
    qmlApi.doAPIRequests("QmlAddLiquidity_fetchAllowancesAndPair")
  }

  function fetchReserves() {
    refreshAssetBalance()
    addAsset1Input.text = addAsset2Input.text = asset1Reserves = asset2Reserves = pglSupply = ""
    qmlApi.clearAPIRequests("QmlAddLiquidity_fetchReserves")
    qmlApi.buildGetReservesReq(pairAddress, "QmlAddLiquidity_fetchReserves")
    qmlApi.buildGetTotalSupplyReq(pairAddress, "QmlAddLiquidity_fetchReserves")
    qmlApi.doAPIRequests("QmlAddLiquidity_fetchReserves")
  }

  function refreshAssetBalance() {
    var asset1Symbol = addAsset1Popup.chosenAssetSymbol
    var asset2Symbol = addAsset2Popup.chosenAssetSymbol
    if (asset1Symbol == "AVAX") {
      asset1Balance = accountHeader.coinRawBalance
    } else {
      var asset1 = accountHeader.tokenList[addAsset1Popup.chosenAssetAddress]
      asset1Balance = (asset1 != undefined) ? asset1["rawBalance"] : ""
    }
    if (asset2Symbol == "AVAX") {
      asset2Balance = accountHeader.coinRawBalance
    } else {
      var asset2 = accountHeader.tokenList[addAsset2Popup.chosenAssetAddress]
      asset2Balance = (asset2 != undefined) ? asset2["rawBalance"] : ""
    }
    assetBalance.text = (asset1Balance != "" && asset2Balance != "")
      ? "Balances:<br><b>"
        + asset1Balance + " " + asset1Symbol + "<br>"
        + asset2Balance + " " + asset2Symbol + "</b>"
      : "Loading asset balances..."
  }

  // For manual inputs on amounts
  function calculateAddLiquidityAmount(isFirstInput) {
    var lowerAddress = qmlSystem.getFirstFromPair(
      addAsset1Popup.chosenAssetAddress, addAsset2Popup.chosenAssetAddress
    )
    if ((lowerAddress == addAsset1Popup.chosenAssetAddress && isFirstInput) 
    || (lowerAddress == addAsset2Popup.chosenAssetAddress && isFirstInput))
     {
      addAsset2Input.text = qmlSystem.calculateAddLiquidityAmount(
        addAsset1Input.text, asset1Reserves, asset2Reserves
      )
    } else if ((lowerAddress == addAsset2Popup.chosenAssetAddress && !isFirstInput)
    || (lowerAddress == addAsset1Popup.chosenAssetAddress && !isFirstInput))
     {
      addAsset1Input.text = qmlSystem.calculateAddLiquidityAmount(
        addAsset2Input.text, asset2Reserves, asset1Reserves
      )
    }
  }
  // For the Max Amounts button
  function calculateMaxAddLiquidityAmount() {
    // Get the max asset amounts, check who is lower and calculate accordingly
    var asset1Max = (addAsset1Popup.chosenAssetSymbol == "AVAX")
      ? qmlSystem.getRealMaxAVAXAmount(accountHeader.coinRawBalance, "250000", qmlSystem.getAutomaticFee())
      : accountHeader.tokenList[addAsset1Popup.chosenAssetAddress]["rawBalance"]
    var asset2Max = (addAsset2Popup.chosenAssetSymbol == "AVAX")
      ? qmlSystem.getRealMaxAVAXAmount(accountHeader.coinRawBalance, "250000", qmlSystem.getAutomaticFee())
      : accountHeader.tokenList[addAsset2Popup.chosenAssetAddress]["rawBalance"]
    var lowerAddress = qmlSystem.getFirstFromPair(
      addAsset1Popup.chosenAssetAddress, addAsset2Popup.chosenAssetAddress
    )
    var asset1Amount, asset2Amount
    asset1Amount = qmlSystem.calculateAddLiquidityAmount(asset1Max, asset1Reserves, asset2Reserves)
    asset2Amount = qmlSystem.calculateAddLiquidityAmount(asset2Max, asset2Reserves, asset1Reserves)
    // Limit the max amount to the lowest the user has, then set the right
    // values afterwards. If asset1Amount is higher than the balance in asset1Max,
    // then that balance is limiting. Same with asset2Amount and asset2Max.
    
    var asset1MaxTmp = asset1Max
    var asset2MaxTmp = asset2Max
    // asset1MaxTmp = Input 1 Balance
    // asset2MaxTmp = Input 2 Balance
    // asset1Amount = How much 1 is worth at 2
    // asset2Amount = How much 2 is worth at 1
    if (+asset1MaxTmp > +asset2Amount) {
      asset1Max = asset2Amount
    }
    if (+asset2MaxTmp > +asset1Amount) {
      asset2Max = asset1Amount
    }
    if (lowerAddress == addAsset1Popup.chosenAssetAddress) {
      addAsset1Input.text = asset1Max
      addAsset2Input.text = qmlSystem.calculateAddLiquidityAmount(
        asset1Max, asset1Reserves, asset2Reserves
      )
    } else if (lowerAddress == addAsset2Popup.chosenAssetAddress) {
      addAsset2Input.text = asset2Max
      addAsset1Input.text = qmlSystem.calculateAddLiquidityAmount(
        asset2Max, asset2Reserves, asset1Reserves
      )
    }
  }
  function checkTransactionFunds() {
    // Approval
    if(addLiquidityApprovalColumn.visible) {
      var Fees = +qmlApi.fixedPointToWei(gasPrice, 8) * +gas
      if (Fees > +qmlApi.fixedPointToWei(accountHeader.coinRawBalance, 18)) {
        return false
      }
      return true
    }

    if (addAsset1Popup.chosenAssetSymbol == "AVAX" || addAsset2Popup.chosenAssetSymbol == "AVAX") {  // AVAX/Token liquidity
      var Fees = +qmlApi.fixedPointToWei(gasPrice, 8) * +gas
      var TxCost = Fees + +qmlApi.fixedPointToWei(
        (addAsset1Popup.chosenAssetSymbol == "AVAX") ?
        add1Amount
        :
        add2Amount, 18
        )
      if (TxCost > +qmlApi.fixedPointToWei(accountHeader.coinRawBalance, 18)) {
        return false
      }

      var tokenBalance = +qmlApi.fixedPointToWei(
        accountHeader.tokenList[
          (addAsset1Popup.chosenAssetSymbol != "AVAX") ?
          addAsset1Popup.chosenAssetAddress
          :
          addAsset2Popup.chosenAssetAddress
        ]["rawBalance"],
        (addAsset1Popup.chosenAssetSymbol != "AVAX") ?
          addAsset1Popup.chosenAssetAddress
          :
          addAsset2Popup.chosenAssetAddress)
      if (tokenBalance < +qmlApi.fixedPointToWei(
        (addAsset1Popup.chosenAssetSymbol != "AVAX") ?
        add1Amount
        :
        add2Amount),
        (addAsset1Popup.chosenAssetSymbol != "AVAX") ?
        addAsset1Popup.chosenAssetDecimals
        :
        addAsset2Popup.chosenAssetDecimals) {
          return false
      }
      return true
    } else { // Token/Token liquidity
      var Fees = +qmlApi.fixedPointToWei(gasPrice, 8) * +gas
      if (Fees > +qmlApi.fixedPointToWei(accountHeader.coinRawBalance, 18)) {
        return false
      }
      var token1Balance = +qmlApi.fixedPointToWei(accountHeader.tokenList[addAsset1Popup.chosenAssetAddress]["rawBalance"], addAsset1Popup.chosenAssetDecimals)
      if (token1Balance < +qmlApi.fixedPointToWei(add1Amount, addAsset1Popup.chosenAssetDecimals)) {
        return false
      }
      var token2Balance = +qmlApi.fixedPointToWei(accountHeader.tokenList[addAsset2Popup.chosenAssetAddress]["rawBalance"], addAsset2Popup.chosenAssetDecimals)
      if (token2Balance < +qmlApi.fixedPointToWei(add2Amount, addAsset2Popup.chosenAssetDecimals)) {
        return false
      }
      return true
    }
  }

  function approveTx(contract) {
    to = contract
    coinValue = 0
    gas = 70000
    gasPrice = 225
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

  function addLiquidityTx() {
    to = qmlSystem.getContract("router")
    gas = 300000
    gasPrice = 225
    info = "You will Add <b>" + addAsset1Input.text + " " + addAsset1Popup.symbol + "<\b> <br>and<br> <b>"
    info += addAsset1Input.text + " " + addAsset2Popup.symbol + "<\b> on Pangolin Liquidity Pool"
    historyInfo = "Add <b>" + addAsset1Input.text + "<\b> and <b>" + addAsset2Popup.symbol + "<\b> to Pangolin Liquidity"
    if (addAsset1Popup.chosenAssetSymbol == "AVAX" || addAsset2Popup.chosenAssetSymbol == "AVAX") {
      var ethCallJson = ({})
      ethCallJson["function"] = "addLiquidityAVAX(address,uint256,uint256,uint256,address,uint256)"
      ethCallJson["args"] = []
      // Token
      ethCallJson["args"].push((addAsset1Popup.chosenAssetSymbol == "AVAX") ? 
        addAsset2Popup.chosenAssetAddress : addAsset1Popup.chosenAssetAddress)
      // amountTokenDesired 
      var amountTokenDesired
      if (addAsset1Popup.chosenAssetSymbol != "AVAX") {
        amountTokenDesired = qmlApi.fixedPointToWei(add1Amount, addAsset1Popup.chosenAssetDecimals)
      } else {
        amountTokenDesired = qmlApi.fixedPointToWei(add2Amount, addAsset1Popup.chosenAssetDecimals)
      }
      ethCallJson["args"].push(String(amountTokenDesired))
      // amountTokenMin
      ethCallJson["args"].push(String(Math.round(amountTokenDesired * 0.99))) // 1% Slippage
      // amountAVAXMin
      var amountAVAX
      if (addAsset1Popup.chosenAssetSymbol == "AVAX") {
        amountAVAX = qmlApi.fixedPointToWei(add1Amount, addAsset1Popup.chosenAssetDecimals)
      } else {
        amountAVAX = qmlApi.fixedPointToWei(add2Amount, addAsset1Popup.chosenAssetDecimals)
      }
      ethCallJson["args"].push(String(Math.round(+amountAVAX * 0.99)))
      // to
      ethCallJson["args"].push(qmlSystem.getCurrentAccount())
      // deadline
      ethCallJson["args"].push(String((+qmlApi.getCurrentUnixTime() + 3600) * 1000))
      ethCallJson["types"] = []
      ethCallJson["types"].push("address")
      ethCallJson["types"].push("uint*")
      ethCallJson["types"].push("uint*")
      ethCallJson["types"].push("uint*")
      ethCallJson["types"].push("address")
      ethCallJson["types"].push("uint*")
      var ethCallString = JSON.stringify(ethCallJson)
      var ABI = qmlApi.buildCustomABI(ethCallString)
      coinValue = qmlApi.weiToFixedPoint(amountAVAX, 18)
      txData = ABI
    } else {
      var ethCallJson = ({})
      ethCallJson["function"] = "addLiquidity(address,address,uint256,uint256,uint256,uint256,address,uint256)"
      ethCallJson["args"] = []
      // tokenA
      ethCallJson["args"].push(addAsset1Popup.chosenAssetAddress)
      // tokenB
      ethCallJson["args"].push(addAsset2Popup.chosenAssetAddress)
      // amountADesired
      var amountADesired = qmlApi.fixedPointToWei(add1Amount, addAsset1Popup.chosenAssetDecimals)
      ethCallJson["args"].push(amountADesired)
      // amountBDesired
      var amountBDesired = qmlApi.fixedPointToWei(add2Amount, addAsset2Popup.chosenAssetDecimals)
      ethCallJson["args"].push(amountBDesired)
      // amountAMin
      ethCallJson["args"].push(String(Math.round(amountADesired * 0.99))) // 1% Slippage
      // amountBMin
      ethCallJson["args"].push(String(Math.round(amountBDesired * 0.99))) // 1% Slippage
      // to
      ethCallJson["args"].push(qmlSystem.getCurrentAccount())
      // deadline
      ethCallJson["args"].push(String((+qmlApi.getCurrentUnixTime() + 3600) * 1000))
      ethCallJson["types"] = []
      ethCallJson["types"].push("address")
      ethCallJson["types"].push("address")
      ethCallJson["types"].push("uint*")
      ethCallJson["types"].push("uint*")
      ethCallJson["types"].push("uint*")
      ethCallJson["types"].push("uint*")
      ethCallJson["types"].push("address")
      ethCallJson["types"].push("uint*")
      var ethCallString = JSON.stringify(ethCallJson)
      var ABI = qmlApi.buildCustomABI(ethCallString)
      coinValue = "0"
      txData = ABI
    }
  }

  Column {
    id: addLiquidityHeaderColumn
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
      id: addLiquidityHeader
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "You will add liquidity to the <b>" +
      addAsset1Popup.chosenAssetSymbol + "/" + addAsset2Popup.chosenAssetSymbol
      + "</b> pool"
    }

    Row {
      id: addLiquidityLogos
      height: 64
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.margins: 20

      Image {
        id: addAsset1Logo
        height: 48
        antialiasing: true
        smooth: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        fillMode: Image.PreserveAspectFit
        source: {
          var avmeAddress = qmlSystem.getAVMEAddress()
          if (addAsset1Popup.chosenAssetSymbol == "AVAX") {
            source: "qrc:/img/avax_logo.png"
          } else if (addAsset1Popup.chosenAssetAddress == avmeAddress) {
            source: "qrc:/img/avme_logo.png"
          } else {
            var img = qmlSystem.getARC20TokenImage(addAsset1Popup.chosenAssetAddress)
            source: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
          }
        }
      }

      Image {
        id: addAsset2Logo
        height: 48
        antialiasing: true
        smooth: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        fillMode: Image.PreserveAspectFit
        source: {
          var avmeAddress = qmlSystem.getAVMEAddress()
          if (addAsset2Popup.chosenAssetSymbol == "AVAX") {
            source: "qrc:/img/avax_logo.png"
          } else if (addAsset2Popup.chosenAssetAddress == avmeAddress) {
            source: "qrc:/img/avme_logo.png"
          } else {
            var img = qmlSystem.getARC20TokenImage(addAsset2Popup.chosenAssetAddress)
            source: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
          }
        }
      }

      Text {
        id: addLiquidityOrder
        anchors.verticalCenter: parent.verticalCenter
        color: "#FFFFFF"
        font.pixelSize: 48.0
        text: " -> "
      }

      Image {
        id: addPangolinLogo
        height: 48
        antialiasing: true
        smooth: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        fillMode: Image.PreserveAspectFit
        source: "qrc:/img/pangolin.png"
      }
    }

    Text {
      id: assetBalance
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Loading asset balances..."
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btnChangeAdd1
        width: (parent.parent.width * 0.5) - (parent.spacing / 2)
        text: "Change Asset 1"
        enabled: !loading
        onClicked: addAsset1Popup.open()
      }
      AVMEButton {
        id: btnChangeAdd2
        width: (parent.parent.width * 0.5) - (parent.spacing / 2)
        text: "Change Asset 2"
        enabled: !loading
        onClicked: addAsset2Popup.open()
      }
    }
  }

  Image {
    id: addLiquidityLoadingPng
    visible: loading
    anchors {
      top: addLiquidityHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: parent.height * 0.1
      bottomMargin: parent.height * 0.1
    }
    fillMode: Image.PreserveAspectFit
    source: "qrc:/img/icons/loading.png"
    RotationAnimator {
      target: addLiquidityLoadingPng
      from: 0
      to: 360
      duration: 1000
      loops: Animation.Infinite
      easing.type: Easing.InOutQuad
      running: true
    }
  }

  Column {
    id: addLiquidityApprovalColumn
    visible: !addLiquidityDetailsColumn.visible
    anchors {
      top: addLiquidityHeaderColumn.bottom
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
      id: addLiquidityApprovalText
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "You need to approve your Account in order to add<br><b>"
      + ((!asset1Approved) ? addAsset1Popup.chosenAssetSymbol : "")
      + ((!asset1Approved && !asset2Approved) ? " and " : "")
      + ((!asset2Approved) ? addAsset2Popup.chosenAssetSymbol : "")
      + "</b> to the pool."
      + "<br>This operation will have a total gas cost of:<br><b>"
      + qmlSystem.calculateTransactionCost("0",
        (!asset1Approved && !asset2Approved) ? "320000" : "180000",
        qmlSystem.getAutomaticFee()
      ) + " AVAX</b>"
    }

    AVMEButton {
      id: approveAsset1Btn
      width: parent.width
      visible: (!asset1Approved)
      enabled: (+accountHeader.coinRawBalance >=
        +qmlSystem.calculateTransactionCost("0", "180000", qmlSystem.getAutomaticFee())
      )
      anchors.horizontalCenter: parent.horizontalCenter
      text: (enabled) ? "Approve " + addAsset1Popup.chosenAssetSymbol : "Not enough funds"
      onClicked: {
        if (checkTransactionFunds()) {
          info = "You will approve <b>"
          + (addAsset1Popup.chosenAssetSymbol)
          + "</b> to be added to the pool for the current address"
          historyInfo = "Approve " + addAsset1Popup.chosenAssetSymbol
          approveTx(addAsset1Popup.chosenAssetAddress)
          confirmAddApprovalAsset1Popup.setData(
            to,
            coinValue,
            txData,
            gas,
            gasPrice,
            automaticGas,
            info,
            historyInfo
          )
          confirmAddApprovalAsset1Popup.open()
        } else {
          fundsPopup.open()
        }
      }
    }
    AVMEButton {
      id: approveAsset2Btn
      width: parent.width
      visible: (!asset2Approved)
      enabled: (+accountHeader.coinRawBalance >=
        +qmlSystem.calculateTransactionCost("0", "180000", qmlSystem.getAutomaticFee())
      )
      anchors.horizontalCenter: parent.horizontalCenter
      text: (enabled) ? "Approve " + addAsset2Popup.chosenAssetSymbol : "Not enough funds"
      onClicked: {
        if (checkTransactionFunds()) {
          info = "You will approve <b>"
          + (addAsset2Popup.chosenAssetSymbol)
          + "</b> to be added to the pool for the current address"
          historyInfo = "Approve " + addAsset2Popup.chosenAssetSymbol
          approveTx(addAsset2Popup.chosenAssetAddress)
          confirmAddApprovalAsset2Popup.setData(
            to,
            coinValue,
            txData,
            gas,
            gasPrice,
            automaticGas,
            info,
            historyInfo
          )
          confirmAddApprovalAsset2Popup.open()
        } else {
          fundsPopup.open()
        }
      }
    }
  }

  Column {
    id: addLiquidityPairUnavailable
    visible: false
    anchors {
      top: addLiquidityHeaderColumn.bottom
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
      id: addLiquidityPairUnavailableText
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      color: "#FFFFFF"
      font.pixelSize: 18.0
      text: "The desired pair is unavailable<br>Please select other"
    }
  }

  Column {
    id: addLiquidityDetailsColumn
    anchors {
      top: addLiquidityHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: 40
      bottomMargin: 20
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 25

    AVMEInput {
      id: addAsset1Input
      width: parent.width
      enabled: (asset1Reserves != "" && asset2Reserves != "")
      validator: RegExpValidator {
        regExp: qmlSystem.createTxRegExp(addAsset1Popup.chosenAssetDecimals)
      }
      label: addAsset1Popup.chosenAssetSymbol + " Amount"
      placeholder: "Fixed point amount (e.g. 0.5)"
      onTextEdited: calculateAddLiquidityAmount(true)
    }

    AVMEInput {
      id: addAsset2Input
      width: parent.width
      enabled: (asset1Reserves != "" && asset2Reserves != "")
      validator: RegExpValidator {
        regExp: qmlSystem.createTxRegExp(addAsset2Popup.chosenAssetDecimals)
      }
      label: addAsset2Popup.chosenAssetSymbol + " Amount"
      placeholder: "Fixed point amount (e.g. 0.5)"
      onTextEdited: calculateAddLiquidityAmount(false)
    }

    AVMEButton {
      id: addMaxBtn
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Max Amounts"
      enabled: (asset1Reserves != "" && asset2Reserves != "" && +asset1Balance != 0 && +asset2Balance != 0)
      onClicked: calculateMaxAddLiquidityAmount()
    }

    AVMEButton {
      id: addLiquidityBtn
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (addAsset1Input.acceptableInput && addAsset2Input.acceptableInput)
      text: "Add to the pool"
      onClicked: {
        addLiquidityTx()
        if (!checkTransactionFunds()) {
          fundsPopup.open()
        } else {
          confirmAddLiquidityPopup.setData(
            to,
            coinValue,
            txData,
            gas,
            gasPrice,
            automaticGas,
            info,
            historyInfo
          )
          confirmAddLiquidityPopup.open()
        }
      }
    }
  }
  AVMEPopupInfo {
    id: fundsPopup
    icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your inputs."
  }
}

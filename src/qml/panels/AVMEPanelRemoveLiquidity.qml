/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import QmlApi 1.0

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Panel for removing liquidity from: a pool.
AVMEPanel {
  id: removeLiquidityPanel
  title: "Remove Liquidity"
  property string pairAddress
  property string pairBalance
  property string pairSupply
  property string pairAllowance
  property string asset1Reserves
  property string asset2Reserves
  property string randomID
  property string userAsset1Reserves
  property string userAsset2Reserves
  property string userLPSharePercentage
  property string removeAsset1Estimate
  property string removeAsset2Estimate
  property string removeLPEstimate
  property bool loading: true
  property string to
  property string coinValue
  property string txData
  property string gas
  property string gasPrice: qmlApi.sum(accountHeader.gasPrice, 15)
  property bool automaticGas: true
  property string info
  property string historyInfo
  property alias removeBtn: removeLiquidityBtn

  Timer { id: requestsTimer; interval: 5000; repeat: true; onTriggered: (fetchAllowanceBalanceReservesAndSupply()) }

  Connections {
    target: qmlApi
    function onApiRequestAnswered(answer, requestID) {
      var resp = JSON.parse(answer)
      if (requestID == "QmlRemoveLiquidity_fetchPair") {
        pairAddress = qmlApi.parseHex(resp[0].result, ["address"])
        if (pairAddress != "0x0000000000000000000000000000000000000000") {
          requestsTimer.start()
        } else {
          loading = false
          removeLiquidityPairUnavailable.visible = true
          return;
        }
      } else if (requestID == "QmlRemoveLiquidity_fetchAllowanceBalanceReservesAndSupply_"+randomID) {
        var reserves
        for (var item in resp) {
          if (resp[item]["id"] == 1) {
            pairBalance = qmlApi.weiToFixedPoint(qmlApi.parseHex(resp[item].result, ["uint"]), 18)
          }
          if (resp[item]["id"] == 2) {
            pairAllowance = qmlApi.parseHex(resp[item].result, ["uint"])
          }
          if (resp[item]["id"] == 3) {
            reserves = qmlApi.parseHex(resp[item].result, ["uint", "uint", "uint"])
          }
          if (resp[item]["id"] == 4) {
            pairSupply = qmlApi.parseHex(resp[item].result, ["uint"])
          }
        }
        if (+pairAllowance < +pairBalance) { // TODO: block if balance is zero, check with >=
          removeLiquidityApprovalColumn.visible = true
          loading = false
          return
        } else {
          removeLiquidityDetailsColumn.visible = false
        }
        var lowerAddress = qmlSystem.getFirstFromPair(
          removeAsset1Popup.chosenAssetAddress, removeAsset2Popup.chosenAssetAddress
        )
        if (lowerAddress == removeAsset1Popup.chosenAssetAddress) {
          asset1Reserves = reserves[0]
          asset2Reserves = reserves[1]
        } else {
          asset2Reserves = reserves[0]
          asset1Reserves = reserves[1]
        }
        var userShares = qmlSystem.calculatePoolShares(
          asset1Reserves, asset2Reserves, pairBalance, pairSupply
        )
        userAsset1Reserves = userShares.asset1
        userAsset2Reserves = userShares.asset2
        userLPSharePercentage = userShares.liquidity
        removeLiquidityApprovalColumn.visible = false
        removeLiquidityDetailsColumn.visible = true
        loading = false
      }
      qmlApi.clearAPIRequests(requestID)
    }
  }

  function fetchPair() {
    pairAddress = ""
    requestsTimer.stop()
    randomID = qmlApi.getRandomID()
    loading = true
    removeLiquidityApprovalColumn.visible = false
    removeLiquidityDetailsColumn.visible = false
    removeLiquidityPairUnavailable.visible = false
    qmlApi.clearAPIRequests("QmlRemoveLiquidity_fetchPair")
    qmlApi.buildGetPairReq(
      removeAsset1Popup.chosenAssetAddress,
      removeAsset2Popup.chosenAssetAddress,
      "QmlRemoveLiquidity_fetchPair"
    )
    qmlApi.doAPIRequests("QmlRemoveLiquidity_fetchPair")
  }

  function fetchAllowanceBalanceReservesAndSupply() {
    pairAllowance = ""
    qmlApi.clearAPIRequests("QmlRemoveLiquidity_fetchAllowanceBalanceReservesAndSupply_"+randomID)
    qmlApi.buildGetTokenBalanceReq(
      pairAddress,
      accountHeader.currentAddress,
      "QmlRemoveLiquidity_fetchAllowanceBalanceReservesAndSupply_"+randomID
    )
    qmlApi.buildGetAllowanceReq(
      pairAddress,
      accountHeader.currentAddress,
      qmlSystem.getContract("router"),
      "QmlRemoveLiquidity_fetchAllowanceBalanceReservesAndSupply_"+randomID
    )
    qmlApi.buildGetReservesReq(pairAddress, "QmlRemoveLiquidity_fetchAllowanceBalanceReservesAndSupply_"+randomID)
    qmlApi.buildGetTotalSupplyReq(pairAddress, "QmlRemoveLiquidity_fetchAllowanceBalanceReservesAndSupply_"+randomID)
    qmlApi.doAPIRequests("QmlRemoveLiquidity_fetchAllowanceBalanceReservesAndSupply_"+randomID)
  }

  function checkTransactionFunds() {
    var Fees = +qmlApi.mul(qmlApi.fixedPointToWei(gasPrice, 9), gas)
    if (+Fees > +qmlApi.fixedPointToWei(accountHeader.coinRawBalance, 18)) {
      return false
    }
    if (pairBalance) {
      if (+pairBalance < +removeLPEstimate) {
        return false;
      }
    }
    return true;
  }

  function approveTx() {
    to = pairAddress
    coinValue = 0
    gas = 70000
    var ethCallJson = ({})
    info = "You will approve <b>"
    + (removeAsset1Popup.chosenAssetSymbol) + "/" + removeAsset2Popup.chosenAssetSymbol
    + "</b> LP in Pangolin router contract"
    historyInfo = "Approve <\b>" + (removeAsset1Popup.chosenAssetSymbol) + "/" + removeAsset2Popup.chosenAssetSymbol + "<\b>in Pangolin"
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

  function removeLiquidityTx() {
    to = qmlSystem.getContract("router")
    coinValue = 0
    gas = 400000
    var ethCallJson = ({})
    info = "You will remove <b><br>"
    + qmlApi.weiToFixedPoint(removeAsset1Estimate, removeAsset1Popup.chosenAssetDecimals) + " " + (removeAsset1Popup.chosenAssetSymbol)
    + " and "
    + qmlApi.weiToFixedPoint(removeAsset2Estimate, removeAsset2Popup.chosenAssetDecimals) + " " + removeAsset2Popup.chosenAssetSymbol
    + "<br></b> LP in Pangolin router contract (estimated)"
    if (removeAsset1Popup.chosenAssetSymbol == "AVAX" || removeAsset2Popup.chosenAssetSymbol == "AVAX") {
      ethCallJson["function"] = "removeLiquidityAVAX(address,uint256,uint256,uint256,address,uint256)"
      ethCallJson["args"] = []
      // token
      ethCallJson["args"].push(
        (removeAsset1Popup.chosenAssetSymbol != "AVAX") ?
        removeAsset1Popup.chosenAssetAddress
        :
        removeAsset2Popup.chosenAssetAddress
      )
      // Liquidity
      ethCallJson["args"].push(qmlApi.fixedPointToWei(removeLPEstimate, 18))
      // amountTokenMin
      var amountTokenMin
      if (removeAsset1Popup.chosenAssetSymbol != "AVAX") {
        amountTokenMin = qmlApi.floor(qmlApi.mul(removeAsset1Estimate, 0.99)) // 1% Slippage
      } else {
        amountTokenMin = qmlApi.floor(qmlApi.mul(removeAsset2Estimate, 0.99)) // 1% Slippage
      }
      ethCallJson["args"].push(amountTokenMin)
      // amountETHMin
      var amountAVAXMin
      if (removeAsset1Popup.chosenAssetSymbol == "AVAX") {
        amountAVAXMin = qmlApi.floor(qmlApi.mul(removeAsset1Estimate,0.99))  // 1% Slippage
      } else {
        amountAVAXMin = qmlApi.floor(qmlApi.mul(removeAsset2Estimate,0.99)) // 1% Slippage
      }
      ethCallJson["args"].push(amountAVAXMin)
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
      txData = ABI
    } else {
      ethCallJson["function"] = "removeLiquidity(address,address,uint256,uint256,uint256,address,uint256)"
      ethCallJson["args"] = []
      // tokenA
      ethCallJson["args"].push(removeAsset1Popup.chosenAssetAddress)
      // tokenB
      ethCallJson["args"].push(removeAsset2Popup.chosenAssetAddress)
      // liquidity
      ethCallJson["args"].push(qmlApi.fixedPointToWei(removeLPEstimate, 18))
      // amountAMin
      ethCallJson["args"].push(qmlApi.floor(qmlApi.mul(removeAsset1Estimate, 0.99)))
      // amountBMin
      ethCallJson["args"].push(qmlApi.floor(qmlApi.mul(removeAsset2Estimate, 0.99)))
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
      ethCallJson["types"].push("address")
      ethCallJson["types"].push("uint*")
      var ethCallString = JSON.stringify(ethCallJson)
      var ABI = qmlApi.buildCustomABI(ethCallString)
      txData = ABI
    }
  }

  Column {
    id: removeLiquidityHeaderColumn
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
      id: removeLiquidityHeader
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "You will remove liquidity from the <b>" +
      removeAsset1Popup.chosenAssetSymbol + "/" + removeAsset2Popup.chosenAssetSymbol
      + "</b> pool"
    }

    Row {
      id: removeLiquidityLogos
      height: 64
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.margins: 20

      Image {
        id: removePangolinLogo
        height: 48
        antialiasing: true
        smooth: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        fillMode: Image.PreserveAspectFit
        source: "qrc:/img/pangolin.png"
      }

      Text {
        id: removeLiquidityOrder
        anchors.verticalCenter: parent.verticalCenter
        color: "#FFFFFF"
        font.pixelSize: 48.0
        text: " -> "
      }

      Image {
        id: removeAsset1Logo
        height: 48
        antialiasing: true
        smooth: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        fillMode: Image.PreserveAspectFit
        source: {
          var avmeAddress = qmlSystem.getContract("AVME")
          if (removeAsset1Popup.chosenAssetSymbol == "AVAX") {
            source: "qrc:/img/avax_logo.png"
          } else if (removeAsset1Popup.chosenAssetAddress == avmeAddress) {
            source: "qrc:/img/avme_logo.png"
          } else {
            var img = qmlSystem.getARC20TokenImage(removeAsset1Popup.chosenAssetAddress)
            source: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
          }
        }
      }

      Image {
        id: removeAsset2Logo
        height: 48
        antialiasing: true
        smooth: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        fillMode: Image.PreserveAspectFit
        source: {
          var avmeAddress = qmlSystem.getContract("AVME")
          if (removeAsset2Popup.chosenAssetSymbol == "AVAX") {
            source: "qrc:/img/avax_logo.png"
          } else if (removeAsset2Popup.chosenAssetAddress == avmeAddress) {
            source: "qrc:/img/avme_logo.png"
          } else {
            var img = qmlSystem.getARC20TokenImage(removeAsset2Popup.chosenAssetAddress)
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
      text: (pairBalance != "")
      ? "Balance: <b>" + pairBalance + " " + removeAsset1Popup.chosenAssetSymbol
      + "/" + removeAsset2Popup.chosenAssetSymbol + " LP</b>"
      : "Loading asset balance..."
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btnChangeRemove1
        width: (parent.parent.width * 0.5) - (parent.spacing / 2)
        text: "Change Asset 1"
        enabled: !loading
        onClicked: removeAsset1Popup.open()
      }
      AVMEButton {
        id: btnChangeRemove2
        width: (parent.parent.width * 0.5) - (parent.spacing / 2)
        text: "Change Asset 2"
        enabled: !loading
        onClicked: removeAsset2Popup.open()
      }
    }
  }

  Image {
    id: removeLiquidityLoadingPng
    visible: loading
    anchors {
      top: removeLiquidityHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: parent.height * 0.1
      bottomMargin: parent.height * 0.1
    }
    fillMode: Image.PreserveAspectFit
    source: "qrc:/img/icons/loading.png"
    RotationAnimator {
      target: removeLiquidityLoadingPng
      from: 0
      to: 360
      duration: 1000
      loops: Animation.Infinite
      easing.type: Easing.InOutQuad
      running: true
    }
  }

  Column {
    id: removeLiquidityApprovalColumn
    anchors {
      top: removeLiquidityHeaderColumn.bottom
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
      id: removeLiquidityApprovalText
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "You need to approve your Account in order to remove <br><b>"
      + removeAsset1Popup.chosenAssetSymbol + "/"
      + removeAsset2Popup.chosenAssetSymbol + " LP</b> from the pool."
      + "<br>This operation will have a total gas cost of:<br><b>"
      + qmlSystem.calculateTransactionCost("0", "180000", gasPrice)
      + " AVAX</b>"
    }

    AVMEButton {
      id: approveBtn
      width: parent.width
      enabled: (+accountHeader.coinRawBalance >=
        +qmlSystem.calculateTransactionCost("0", "180000", gasPrice)
      )
      anchors.horizontalCenter: parent.horizontalCenter
      text: (enabled) ? "Approve" : "Not enough funds"
      onClicked: {
        if (checkTransactionFunds()) {
          approveTx();
          confirmRemoveApprovalPopup.setData(
            to, coinValue, txData, gas, gasPrice, automaticGas, info, historyInfo
          )
          confirmRemoveApprovalPopup.open()
        } else {
          fundsPopup.open()
        }
      }
    }
  }

  Column {
    id: removeLiquidityDetailsColumn
    anchors {
      top: removeLiquidityHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: 0
      bottomMargin: 20
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 25

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
      enabled: (pairAllowance != "" || asset1Reserves != "" || asset2Reserves != "" || pairBalance != "")
      onMoved: {
        var estimates = qmlSystem.calculateRemoveLiquidityAmount(
          userAsset1Reserves, userAsset2Reserves, value, pairBalance
        )
        removeAsset1Estimate = estimates.lower
        removeAsset2Estimate = estimates.higher
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

    Row {
      id: sliderBtnRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 20

      AVMEButton {
        id: sliderBtn25
        enabled: (+pairBalance != 0)
        width: (parent.parent.width * 0.2)
        text: "25%"
        onClicked: { liquidityLPSlider.value = 25; liquidityLPSlider.moved(); }
      }

      AVMEButton {
        id: sliderBtn50
        enabled: (+pairBalance != 0)
        width: (parent.parent.width * 0.2)
        text: "50%"
        onClicked: { liquidityLPSlider.value = 50; liquidityLPSlider.moved(); }
      }

      AVMEButton {
        id: sliderBtn75
        enabled: (+pairBalance != 0)
        width: (parent.parent.width * 0.2)
        text: "75%"
        onClicked: { liquidityLPSlider.value = 75; liquidityLPSlider.moved(); }
      }

      AVMEButton {
        id: sliderBtn100
        enabled: (+pairBalance != 0)
        width: (parent.parent.width * 0.2)
        text: "100%"
        onClicked: { liquidityLPSlider.value = 100; liquidityLPSlider.moved(); }
      }
    }

    Text {
      id: removeEstimate
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "<b>" + ((removeLPEstimate) ? removeLPEstimate : "0") + " LP</b>"
      + "<br><br>Estimated returns:<br>"
      + "<b>" + qmlSystem.weiToFixedPoint(
        removeAsset1Estimate, removeAsset1Popup.chosenAssetDecimals
      )
      + " " + removeAsset1Popup.chosenAssetSymbol
      + "<br>" + qmlSystem.weiToFixedPoint(
        removeAsset2Estimate, removeAsset2Popup.chosenAssetDecimals
      )
      + " " + removeAsset2Popup.chosenAssetSymbol + "</b>"
    }

    AVMEButton {
      id: removeLiquidityBtn
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: ((liquidityLPSlider.value > 0) && +removeLPEstimate != 0)
      text: "Remove from the pool"
      onClicked: {
        if (checkTransactionFunds()) {
          removeLiquidityTx()
          confirmRemoveLiquidityPopup.setData(
            to, coinValue, txData, gas, gasPrice, automaticGas, info, historyInfo
          )
          confirmRemoveLiquidityPopup.open()
        } else {
          fundsPopup.open()
        }
      }
    }
  }
  Column {
    id: removeLiquidityPairUnavailable
    visible: false
    anchors {
      top: removeLiquidityHeaderColumn.bottom
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
      id: removeLiquidityPairUnavailableText
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      color: "#FFFFFF"
      font.pixelSize: 18.0
      text: "The desired pair is unavailable<br>Please select other"
    }
  }
  AVMEPopupInfo {
    id: fundsPopup
    icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your inputs."
  }
}

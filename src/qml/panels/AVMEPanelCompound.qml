/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Panel for classic staking (AVME smart contract)
AVMEPanel {
  id: stakingPanel
  readonly property string pairAddress: "0x381cc7bcba0afd3aeb0eaec3cb05d7796ddfd860"
  property string pairTotalBalance
  property string pairUserBalance
  property string pairUserLockedBalance
  property string allowance
  property string lowerToken
  property string lowerReserves
  property string higherToken
  property string higherReserves
  property string userLowerShares
  property string userHigherShares
  property string userLPShares
  property string lowerEstimate
  property string higherEstimate
  property string compoundUserLockedBalance
  property string compoundSupply
  property string compoundTotalDeposits
  property bool loading
  property string to
  property string coinValue
  property string txData
  property string gas
  property string gasPrice
  property bool automaticGas: true
  property string info
  property string historyInfo
  title: "Compound Staking"

  Timer { id: reservesTimer; interval: 1000; repeat: true; onTriggered: (fetchBalanceAllowanceAndReserves()) } 

  Connections {
    target: qmlApi          
    function onApiRequestAnswered(answer, requestID) {
      var resp = JSON.parse(answer)
      if (requestID == "QmlCompoundStaking_fetchBalanceAllowanceAndReserves") {
        var reserves, lowerAddress, shares
        for (var item in resp) {
          if (resp[item]["id"] == 1) { // Pair Supply
            pairTotalBalance = qmlApi.parseHex(resp[item].result, ["uint"])
          }
          if (resp[item]["id"] == 2) {  // Pair Balance
            pairUserBalance = qmlApi.parseHex(resp[item].result, ["uint"])
          }
          if (resp[item]["id"] == 3) { // Compound Allowance
            allowance = qmlApi.parseHex(resp[item].result, ["uint"])
          }
          if (resp[item]["id"] == 4) { // Reserves
            reserves = qmlApi.parseHex(resp[item].result, ["uint", "uint", "uint"])
          }
          if (resp[item]["id"] == 5) { // Compound Balance
            compoundUserLockedBalance = qmlApi.parseHex(resp[item].result, ["uint"])
          }
          if (resp[item]["id"] == 6) { // Compound Supply
            compoundSupply = qmlApi.parseHex(resp[item].result, ["uint"])
          }
          if (resp[item]["id"] == 7) { // Compound Deposited
            compoundTotalDeposits = qmlApi.parseHex(resp[item].result, ["uint"])
          }
        }
        // TODO: check edge case of allowance and balance both being zero
        if (+allowance <= +pairUserBalance) {
          stakingDetailsColumn.visible = false
          stakingApprovalColumn.visible = true
          loading = false
          return
        }

        lowerAddress = qmlSystem.getFirstFromPair(
          qmlSystem.getContract("AVAX"), qmlSystem.getContract("AVME")
        )
        pairUserLockedBalance = (+compoundUserLockedBalance * +compoundTotalDeposits) / +compoundSupply

        lowerReserves = reserves[0]
        higherReserves = reserves[1]
        if (lowerAddress == qmlSystem.getContract("AVAX")) {
          lowerToken = "AVAX"
          higherToken = "AVME"
        } else if (lowerAddress == qmlSystem.getContract("AVME")) {
          lowerToken = "AVME"
          higherToken = "AVAX"
        }

        shares = qmlSystem.calculatePoolShares(
          lowerReserves, higherReserves, qmlApi.weiToFixedPoint(pairUserLockedBalance, 18), pairTotalBalance
        )
        userLowerShares = shares.asset1
        userHigherShares = shares.asset2
        userLPShares = shares.liquidity
        loading = false
        stakingApprovalColumn.visible = false
        stakingDetailsColumn.visible = true
      }
    }
  }

  function fetchBalanceAllowanceAndReserves() {
    qmlApi.clearAPIRequests("QmlCompoundStaking_fetchBalanceAllowanceAndReserves")
    qmlApi.buildGetTotalSupplyReq(
      pairAddress, "QmlCompoundStaking_fetchBalanceAllowanceAndReserves"
    )
    qmlApi.buildGetTokenBalanceReq(
      pairAddress, accountHeader.currentAddress, "QmlCompoundStaking_fetchBalanceAllowanceAndReserves"
    )
    qmlApi.buildGetAllowanceReq(
      pairAddress,
      accountHeader.currentAddress,
      qmlSystem.getContract("compound"),
      "QmlCompoundStaking_fetchBalanceAllowanceAndReserves"
    )
    qmlApi.buildGetReservesReq(pairAddress, "QmlCompoundStaking_fetchBalanceAllowanceAndReserves")
    qmlApi.buildGetTokenBalanceReq(qmlSystem.getContract("compound"), accountHeader.currentAddress, "QmlCompoundStaking_fetchBalanceAllowanceAndReserves")
    qmlApi.buildGetTotalSupplyReq(
      qmlSystem.getContract("compound"), "QmlCompoundStaking_fetchBalanceAllowanceAndReserves"
    )
    var ethCallJson = ({})
    ethCallJson["function"] = "totalDeposits()"
    ethCallJson["args"] = []
    ethCallJson["types"] = []
    var ethCallString = JSON.stringify(ethCallJson)
    var ABI = qmlApi.buildCustomABI(ethCallString)
    qmlApi.buildCustomEthCallReq(
      qmlSystem.getContract("compound"), ABI, "QmlCompoundStaking_fetchBalanceAllowanceAndReserves"
    )

    qmlApi.doAPIRequests("QmlCompoundStaking_fetchBalanceAllowanceAndReserves")
  }

  function calculateTransactionCost() {
    var Fees = +qmlApi.fixedPointToWei(gasPrice, 8) * +gas
    if (Fees > +qmlApi.fixedPointToWei(accountHeader.coinRawBalance, 18)) {
      return false
    }
    if (isStaking) {
      if (pairUserBalance < stakeInput.text) {
        return false 
      }
    } else {
      if (pairUserLockedBalance < stakeInput.text) {
        return false 
      }
    }
    return true
  }

  function approveTx() {
    to = pairAddress
    coinValue = 0
    gas = 100000
    gasPrice = 225
    info = "You will Approve <b> AVME/AVAX LP <\b> on Compound Staking Contract"
    historyInfo = "Approve <b> AVME/AVAX LP <\b> on Compound Staking Contract"

    var ethCallJson = ({})
    ethCallJson["function"] = "approve(address,uint256)"
    ethCallJson["args"] = []
    ethCallJson["args"].push(qmlSystem.getContract("compound"))
    ethCallJson["args"].push(qmlApi.MAX_U256_VALUE())
    ethCallJson["types"] = []
    ethCallJson["types"].push("address")
    ethCallJson["types"].push("uint*")
    var ethCallString = JSON.stringify(ethCallJson)
    var ABI = qmlApi.buildCustomABI(ethCallString)
    txData = ABI
  }

  function stakeTx() {
    to = qmlSystem.getContract("compound")
    coinValue = 0
    gas = 200000
    gasPrice = 225
    info = "You will stake <b> " + qmlApi.weiToFixedPoint(stakeInput.text, 18) + " AVME/AVAX LP <\b> on Compound Staking"
    historyInfo = "Stake <b> AVME/AVAX LP <\b> on Compound Staking"
    var ethCallJson = ({})
    ethCallJson["function"] = "deposit(uint256)"
    ethCallJson["args"] = []
    ethCallJson["args"].push(qmlApi.fixedPointToWei(stakeInput.text, 18))
    ethCallJson["types"] = []
    ethCallJson["types"].push("uint*")
    var ethCallString = JSON.stringify(ethCallJson)
    var ABI = qmlApi.buildCustomABI(ethCallString)
    txData = ABI
  }

  function unstakeTx() {
    to = qmlSystem.getContract("compound")
    coinValue = 0
    gas = 200000
    gasPrice = 225
    info = "You will unstake <b> " + qmlApi.weiToFixedPoint(stakeInput.text, 18) + " AVME/AVAX LP <\b> on Compound Staking"
    historyInfo = "Unstake <b> AVME/AVAX LP <\b> on Compound Staking"
    var ethCallJson = ({})
    ethCallJson["function"] = "withdraw(uint256)"
    ethCallJson["args"] = []
    var sharesForDepositTokens = (+qmlApi.fixedPointToWei(stakeInput.text, 18) * +compoundSupply) / +compoundTotalDeposits
    // Edge case of dumb JS calcs
    if (qmlSystem.firstHigherThanSecond(sharesForDepositTokens, compoundUserLockedBalance)) {
      sharesForDepositTokens = compoundUserLockedBalance      
    }
    ethCallJson["args"].push(sharesForDepositTokens)
    ethCallJson["types"] = []
    ethCallJson["types"].push("uint*")
    var ethCallString = JSON.stringify(ethCallJson)
    var ABI = qmlApi.buildCustomABI(ethCallString)
    txData = ABI
  }

  Component.onCompleted: {
    stakingDetailsColumn.visible = false
    stakingApprovalColumn.visible = false
    loading = true; 
    reservesTimer.start()
  }
  Column {
    id: stakingHeaderColumn
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      topMargin: 80
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 30

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 20

      Text {
        id: stakeTitle
        anchors.verticalCenter: parent.verticalCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "You will <b>" + ((isStaking) ? "stake" : "unstake") + " AVAX/AVME LP</b>"
      }
      AVMEButton {
        id: btnSwitchOrder
        width: 200
        anchors.verticalCenter: parent.verticalCenter
        text: "Switch to " + ((isStaking) ? "Unstake" : "Stake")
        onClicked: {
          isStaking = !isStaking
          stakeInput.text = ""
        }
      }
    }

    Image {
      id: stakeLogo
      anchors.horizontalCenter: parent.horizontalCenter
      height: 48
      antialiasing: true
      smooth: true
      fillMode: Image.PreserveAspectFit
      source: "qrc:/img/pangolin.png"
    }

    Text {
      id: stakeBalance
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: (pairUserBalance)
      ? (isStaking) 
      ? "Balance: <b>" + qmlApi.weiToFixedPoint(pairUserBalance, 18) + " AVAX/AVME LP</b>"
      : "Balance: <b>" + qmlApi.weiToFixedPoint(pairUserLockedBalance, 18) + " AVAX/AVME LP</b>"
      : "Loading LP balance..."
    }
  }

  Column {
    id: stakingApprovalColumn
    visible: !stakingDetailsColumn.visible
    anchors {
      top: stakingHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: 20
      bottomMargin: 20
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 30

    Text {
      id: stakingApprovalText
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "You need to approve your Account in order to stake<br>"
      + "<b>AVAX/AVME LP</b> in the staking contract."
      + "<br>This operation will have a total gas cost of:<br><b>"
      + qmlSystem.calculateTransactionCost("0", "200000", qmlSystem.getAutomaticFee())
      + " AVAX</b>"
    }

    AVMEButton {
      id: btnApprove
      width: parent.width
      enabled: (+accountHeader.coinRawBalance >=
        +qmlSystem.calculateTransactionCost("0", "200000", qmlSystem.getAutomaticFee())
      )
      anchors.horizontalCenter: parent.horizontalCenter
      text: (enabled) ? "Approve" : "Not enough funds"
      onClicked: {
        approveTx()
        confirmApprovalPopup.setData(
            to,
            coinValue,
            txData,
            gas,
            gasPrice,
            automaticGas,
            info,
            historyInfo
        )
        confirmApprovalPopup.open()
      }
    }
  }

  Column {
    id: stakingDetailsColumn
    anchors {
      top: stakingHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: 20
      bottomMargin: 20
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 50

    AVMEInput {
      id: stakeInput
      width: (parent.width * 0.8)
      anchors.left: parent.left
      enabled: (allowance != "")
      validator: RegExpValidator { regExp: /[0-9]{1,}(?:\.[0-9]{1,18})?/ }
      label: "Amount of AVAX/AVME LP to " + ((isStaking) ? "stake" : "unstake")
      placeholder: "Fixed point amount (e.g. 0.5)"

      AVMEButton {
        id: btnMaxAmount
        width: (parent.parent.width * 0.2) - anchors.leftMargin
        anchors {
          left: parent.right
          leftMargin: 10
        }
        text: "Max"
        onClicked: {
          stakeInput.text = (isStaking) ? qmlApi.weiToFixedPoint(pairUserBalance, 18) : qmlApi.weiToFixedPoint(pairUserLockedBalance, 18)
        }
      }
    }

    AVMEButton {
      id: btnStake
      width: parent.width
      enabled: (stakeInput.acceptableInput)
      text: {
        if (isStaking) {
          text: "Stake"
        } else if (!isStaking) {
          text: "Unstake"
        }
      }
      onClicked: {
        if (isStaking) {
          stakeTx()
        } else {
          unstakeTx()
        }
        if (calculateTransactionCost()) {
          confirmStakePopup.setData(
              to,
              coinValue,
              txData,
              gas,
              gasPrice,
              automaticGas,
              info,
              historyInfo
          )
          confirmStakePopup.open()
        } else {
          fundsPopup.open()
        }
      } 
    }

    Rectangle {
      id: estimatedCompoundLockedValue
      radius: 10
      color: "#1d1827"
      height: parent.height * 0.35
      width: parent.width
    Text {
      id: estimatedCompoundLockedValueText
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      text: "Locked LP Estimates:"
        + "<br><b>" + qmlSystem.weiToFixedPoint(userLowerShares, 18) + " " + lowerToken
        + "<br><b>" + qmlSystem.weiToFixedPoint(userHigherShares, 18) + " " + higherToken
    }
    }
  }
  Image {
    id: stakingLoadingPng
    visible: loading
    anchors {
      top: stakingHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: parent.height * 0.1
      bottomMargin: parent.height * 0.1
    }
    fillMode: Image.PreserveAspectFit
    source: "qrc:/img/icons/loading.png"
    RotationAnimator {
      target: stakingLoadingPng
      from: 0
      to: 360
      duration: 1000
      loops: Animation.Infinite
      easing.type: Easing.InOutQuad
      running: true
    }
  }
  AVMEPopupInfo {
    id: fundsPopup
    icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your inputs."
  }
}

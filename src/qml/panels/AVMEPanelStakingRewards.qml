/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Panel for classic staking rewards
AVMEPanel {
  id: stakingRewardsPanel
  property string reward
  property string lockedBalance
  property bool loading
  property string to
  property string coinValue
  property string txData
  property string gas
  property string gasPrice: qmlApi.sum(accountHeader.gasPrice, 15)
  property bool automaticGas: true
  property string info
  property string historyInfo
  title: "Classic Staking Rewards"

  Timer { id: rewardsTimer; interval: 1000; repeat: true; onTriggered: (fetchRewards()) }

  Connections {
    target: qmlApi
    function onApiRequestAnswered(answer, requestID) {
      var resp = JSON.parse(answer)
      if (requestID == "QmlClassicStaking_fetchRewards") {
        var rewardParsed = qmlApi.parseHex(resp[0].result, ["uint"])
        reward = rewardParsed[0]
        stakingLoadingPng.visible = false
        loading = false
      }
    }
  }

  function fetchRewards() {
    qmlApi.clearAPIRequests("QmlClassicStaking_fetchRewards")
    var ethCallJson = ({})
    ethCallJson["function"] = "earned(address)"
    ethCallJson["args"] = []
    ethCallJson["args"].push(qmlSystem.getCurrentAccount())
    ethCallJson["types"] = []
    ethCallJson["types"].push("address")
    var ethCallString = JSON.stringify(ethCallJson)
    var ABI = qmlApi.buildCustomABI(ethCallString)
    qmlApi.buildCustomEthCallReq(
      qmlSystem.getContract("staking"), ABI, "QmlClassicStaking_fetchRewards"
    )
    qmlApi.doAPIRequests("QmlClassicStaking_fetchRewards")
  }

  function exitTx() {
    to = qmlSystem.getContract("staking")
    coinValue = 0
    gas = 200000
    info = "You will Harvest <b> " + qmlApi.weiToFixedPoint(reward, 18) + " AVME <\b> "
    + "<br> and withdraw <b>" + qmlApi.weiToFixedPoint(lockedBalance, 18) + " AVME/AVAX LP "
    + "</b><br> on Classic Staking Contract"
    historyInfo = "Exit Classic Staking Contract"
    var ethCallJson = ({})
    ethCallJson["function"] = "exit()"
    ethCallJson["args"] = []
    ethCallJson["types"] = []
    var ethCallString = JSON.stringify(ethCallJson)
    var ABI = qmlApi.buildCustomABI(ethCallString)
    txData = ABI
  }

  function harvestTx() {
    to = qmlSystem.getContract("staking")
    coinValue = 0
    gas = 200000
    info = "You will Harvest <b> " + qmlApi.weiToFixedPoint(reward, 18) + " AVME <\b>"
    + "</b><br> on Classic Staking Contract"
    historyInfo = "Harves Classic Staking Contract"
    var ethCallJson = ({})
    ethCallJson["function"] = "getReward()"
    ethCallJson["args"] = []
    ethCallJson["types"] = []
    var ethCallString = JSON.stringify(ethCallJson)
    var ABI = qmlApi.buildCustomABI(ethCallString)
    txData = ABI
  }

  Component.onCompleted: {
    loading = true
    stakingLoadingPng.visible = true
    rewardsTimer.start()
  }

  Column {
    id: stakingRewardsDetailsColumn
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      topMargin: 80
      bottomMargin: 20
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 30

    Text {
      id: harvestTitle
      anchors.horizontalCenter: parent.horizontalCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "You will <b>harvest AVME</b> rewards"
    }

    Image {
      id: harvestTokenLogo
      anchors.horizontalCenter: parent.horizontalCenter
      height: 48
      antialiasing: true
      smooth: true
      fillMode: Image.PreserveAspectFit
      source: "qrc:/img/avme_logo.png"
    }

    Text {
      id: rewardAmount
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: (loading) ? "Loading rewards..." : "Unharvested rewards:<br><b>" + qmlApi.weiToFixedPoint(reward, 18) + " AVME</b>"
    }

    AVMEButton {
      id: btnExitStake
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      visible: (!loading)
      enabled: ((+reward != 0) && (+accountHeader.coinRawBalance >=
        +qmlSystem.calculateTransactionCost("0", "70000", gasPrice)
      ))
      onClicked: {
        exitTx()
        confirmRewardPopup.setData(
            to,
            coinValue,
            txData,
            gas,
            gasPrice,
            automaticGas,
            info,
            historyInfo
        )
        confirmRewardPopup.open()
      }
      text: "Harvest AVME & Unstake LP"
    }

    AVMEButton {
      id: btnHarvest
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      visible: (!loading)
      enabled: ((+reward != 0) &&(+accountHeader.coinRawBalance >=
        +qmlSystem.calculateTransactionCost("0", "70000", gasPrice)
      ))
      onClicked: {
        harvestTx()
        confirmRewardPopup.setData(
            to,
            coinValue,
            txData,
            gas,
            gasPrice,
            automaticGas,
            info,
            historyInfo
        )
        confirmRewardPopup.open()
      }
      text: "Harvest AVME"
    }
  }
  Image {
    id: stakingLoadingPng
    visible: loading
    anchors {
      top: stakingRewardsDetailsColumn.bottom
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

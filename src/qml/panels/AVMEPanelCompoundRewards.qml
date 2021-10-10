/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Panel for Compound staking rewards
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
  title: "Compound Staking Rewards"

  Timer { id: rewardsTimer; interval: 1000; repeat: true; onTriggered: (fetchRewards()) }

  Connections {
    target: qmlApi
    function onApiRequestAnswered(answer, requestID) {
      var resp = JSON.parse(answer)
      if (requestID == "QmlCompoundStaking_fetchRewards") {
        var rewardParsed = qmlApi.parseHex(resp[0].result, ["uint"])
        reward = rewardParsed[0]
        stakingLoadingPng.visible = false
        loading = false
      }
    }
  }

  function fetchRewards() {
    qmlApi.clearAPIRequests("QmlCompoundStaking_fetchRewards")
    var ethCallJson = ({})
    ethCallJson["function"] = "checkReward()"
    ethCallJson["args"] = []
    ethCallJson["args"].push(qmlSystem.getCurrentAccount())
    ethCallJson["types"] = []
    ethCallJson["types"].push("address")
    var ethCallString = JSON.stringify(ethCallJson)
    var ABI = qmlApi.buildCustomABI(ethCallString)
    qmlApi.buildCustomEthCallReq(
      qmlSystem.getContract("compound"), ABI, "QmlCompoundStaking_fetchRewards"
    )
    qmlApi.doAPIRequests("QmlCompoundStaking_fetchRewards")
  }

  function reinvestTx() {
    to = qmlSystem.getContract("compound")
    coinValue = 0
    gas = 600000 // Avoid "gas required exceeds allowance" error
    info = "You will reinvest and receive <b> " + qmlApi.weiToFixedPoint(reward, 18) + " AVME </b>"
    + "</b><br> on Compound Staking Contract"
    historyInfo = "Harvest Compound Staking Contract"
    var ethCallJson = ({})
    ethCallJson["function"] = "reinvest()"
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
      text: "You will <b>reinvest AVME</b> (optional)"
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
      text: (loading) ? "Loading rewards..." : "Unreinvested AVME:<br><b>" + qmlApi.weiToFixedPoint(reward, 18) + " AVME</b>"
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
        reinvestTx()
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
      text: "Reinvest AVME"
    }
    Text {
      id: reinvestAmount
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: (loading) ? "Loading rewards..." : "Reinvest Reward AVME:<br><b>" + qmlApi.weiToFixedPoint((+reward * 0.02), 18) + " AVME</b>"
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

  Image {
    id: yyLogo
    anchors {
      bottom: parent.bottom
      right: parent.right
      margins: 20
    }
    width: 128
    height: 64
    source: "qrc:/img/yieldyak.png"
    Text {
      id: yyLogoText
      anchors {
        bottom: parent.top
        horizontalCenter: parent.horizontalCenter
        bottomMargin: -10
      }
      color: "#FFFFFF"
      font.pixelSize: 18.0
      verticalAlignment: Text.AlignVCenter
      text: "Powered by"
    }
  }

  AVMEPopupInfo {
    id: fundsPopup
    icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your inputs."
  }
}

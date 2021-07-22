/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Screen for staking tokens with a given Account
Item {
  id: stakingScreen
  property bool isStaking: true
  property bool isExiting: false
  property bool isClassic: true
  property bool isyyCompound: true
  property string allowance
  property string reward
  property string compoundallowance
  property string reinvestreward
  property string lowerToken
  property string lowerReserves
  property string higherToken
  property string higherReserves
  property string liquidity
  property string userClassicLowerReserves
  property string userClassicHigherReserves
  property string userCompoundLowerReserves
  property string userCompoundHigherReserves
  property string userLPSharePercentage
  property string removeLPEstimate

  Connections {
    target: QmlSystem
    function onAllowancesUpdated(
      exchangeAllowance, liquidityAllowance, stakingAllowance, compoundAllowance
    ) {
      allowance = stakingAllowance
      compoundallowance = compoundAllowance
    }
    function onRewardUpdated(poolReward) { reward = poolReward }
    function onCompoundUpdated(reinvestReward) { reinvestreward = reinvestReward }
    function onLiquidityDataUpdated(
      lowerTokenName, lowerTokenReserves, higherTokenName, higherTokenReserves, totalLiquidity
    ) {
      lowerToken = lowerTokenName
      lowerReserves = lowerTokenReserves
      higherToken = higherTokenName
      higherReserves = higherTokenReserves
      liquidity = totalLiquidity
      var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
      var userClassicShares = QmlSystem.calculatePoolSharesForTokenValue(
        lowerReserves, higherReserves, liquidity, acc.balanceLPLocked
      )
      var userCompoundShares = QmlSystem.calculatePoolSharesForTokenValue(
        lowerReserves, higherReserves, liquidity, acc.balanceLockedCompoundLP
      )
      userClassicLowerReserves = userClassicShares.lower
      userClassicHigherReserves = userClassicShares.higher
      userCompoundLowerReserves = userCompoundShares.lower
      userCompoundHigherReserves = userCompoundShares.higher
    }
  }

  Timer {
    id: reloadRewardTimer
    interval: 1000
    repeat: true
    onTriggered: QmlSystem.getPoolReward()
  }

  Timer {
    id: reloadCompoundTimer
    interval: 1000
    repeat: true
    onTriggered: QmlSystem.getCompoundReward()
  }

  Timer {
    id: reloadLiquidityDataTimer
    interval: 5000
    repeat: true
    onTriggered: QmlSystem.updateLiquidityData("AVAX", "AVME")
  }

  Component.onCompleted: {
    QmlSystem.getAllowances()
    reloadRewardTimer.start()
    reloadCompoundTimer.start()
    reloadLiquidityDataTimer.start()
  }

  AVMEAccountHeader {
    id: accountHeader
  }

  // Panel for selecting Classic x Compound
  AVMEPanel {
    id: stakingSelectPanel
    width: (parent.width - (anchors.margins * 2))
    height: (parent.height * 0.075)
    title: ""
    anchors {
      top: accountHeader.bottom
      left: parent.left
      margins: 10
    }

    AVMEButton {
      id: btnSwitchClassic
      width: parent.width * 0.25
      anchors {
        horizontalCenter: parent.horizontalCenter
        verticalCenter: parent.verticalCenter
        horizontalCenterOffset: -(parent.width / 4)
      }
      text: "Classic"
      onClicked: isClassic = true
    }
    AVMEButton {
      id: btnSwitchYYCompound
      width: parent.width * 0.25
      anchors {
        horizontalCenter: parent.horizontalCenter
        verticalCenter: parent.verticalCenter
        horizontalCenterOffset: parent.width / 4
      }
      text: "YieldYak Compound"
      onClicked: isClassic = false
    }
  }

  // Panel for staking/unstaking LP
  AVMEPanel {
    id: stakingPanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
    visible: isClassic
    anchors {
      top: stakingSelectPanel.bottom
      left: parent.left
      bottom: parent.bottom
      margins: 10
    }
    title: "Staking Details"

    Column {
      id: stakingDetailsColumn
      anchors {
        top: parent.top
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        topMargin: 80
        bottomMargin: 20
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

      // TODO: fix balances to fix this
      Text {
        id: stakeBalance
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 18.0
        text: {
          var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
          text: (isStaking)
          ? "Free (unstaked) LP:<br><b>" + acc.balanceLPFree + "</b>"
          : "Locked (staked) LP:<br><b>" + acc.balanceLPLocked + "</b>"
        }
      }

      AVMEInput {
        id: stakeInput
        width: (parent.width * 0.8)
        anchors.left: parent.left
        enabled: (allowance != "")
        validator: RegExpValidator { regExp: /[0-9]{1,}(?:\.[0-9]{1,18})?/ }
        label: "Amount of LP to " + ((isStaking) ? "stake" : "unstake")
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
            var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
            stakeInput.text = (isStaking) ? acc.balanceLPFree : acc.balanceLPLocked
          }
        }
      }

      Text {
        id: classicLPReturnsText
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Locked LP Estimates:"
          + "<br><b>" + QmlSystem.weiToFixedPoint(
            (("AVAX" == lowerToken) ? userClassicLowerReserves : userClassicHigherReserves), 18
          ) + " AVAX"
          + "<br>" + QmlSystem.weiToFixedPoint(
            (("AVME" == lowerToken) ? userClassicLowerReserves : userClassicHigherReserves), 18
          ) + " AVME" + "</b>"
      }

      AVMEButton {
        id: btnStake
        width: parent.width
        enabled: {
          var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
          enabled: allowance != "" && (
            !QmlSystem.isApproved(acc.balanceLPFree, allowance) || stakeInput.acceptableInput
          )
        }
        text: {
          var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
          if (allowance == "") {
            text: "Checking approval..."
          } else if (isStaking && QmlSystem.isApproved(acc.balanceLPFree, allowance)) {
            text: "Stake"
          } else if (!isStaking && QmlSystem.isApproved(acc.balanceLPLocked, allowance)) {
            text: "Unstake"
          } else {
            text: "Approve"
          }
        }
        /*
        // TODO: this
        onClicked: {
          var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
          if (!QmlSystem.isApproved(acc.balanceLPFree, allowance)) {
            QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
            QmlSystem.operationOverride("Approve Staking", "", "", "")
          } else if (isStaking) {
            if (QmlSystem.hasInsufficientFunds("LP", acc.balanceLPFree, stakeInput.text)) {
              fundsPopup.open()
            } else {
              QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              QmlSystem.operationOverride("Stake LP", "", "", stakeInput.text)
            }
          } else {
            if (QmlSystem.hasInsufficientFunds("LP", acc.balanceLPLocked, stakeInput.text)) {
              fundsPopup.open()
            } else {
              QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              QmlSystem.operationOverride("Unstake LP", "", "", stakeInput.text)
            }
          }
        }
        */
      }
    }
  }

  // Panel for harvesting/exiting
  AVMEPanel {
    id: harvestPanel
    visible: isClassic
    width: (parent.width * 0.5) - (anchors.margins * 2)
    anchors {
      top: stakingSelectPanel.bottom
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
    title: "Harvesting Details"

    Column {
      id: harvestDetailsColumn
      anchors {
        top: parent.top
        bottom: parent.bottom
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
        text: "Unharvested rewards:<br><b>" + reward + " AVME</b>"
      }

      AVMEButton {
        id: btnExitStake
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: {
          var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
          enabled: (
            reward != "" && !QmlSystem.balanceIsZero(reward, 18) &&
            !QmlSystem.balanceIsZero(acc.balanceLPLocked, 18)
          )
        }
        text: (reward != "") ? "Harvest AVME & Unstake LP" : "Querying reward..."
        onClicked: {
          QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
          QmlSystem.operationOverride("Exit Staking", "", "", "")
        }
      }

      AVMEButton {
        id: btnHarvest
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (reward != "" && !QmlSystem.balanceIsZero(reward, 18))
        text: (reward != "") ? "Harvest AVME" : "Querying reward..."
        onClicked: {
          QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
          QmlSystem.operationOverride("Harvest AVME", "", "", "")
        }
      }
    }
  }

  // Panel for Investing/Withdrawing from YY
  AVMEPanel {
    id: yyCompoundPanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
    visible: !isClassic
    anchors {
      top: stakingSelectPanel.bottom
      left: parent.left
      bottom: parent.bottom
      margins: 10
    }
    title: "YieldYak Compound Details"

    Column {
      id: yyCompoundDetailsColumn
      anchors {
        top: parent.top
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        topMargin: 80
        bottomMargin: 20
        leftMargin: 40
        rightMargin: 40
      }
      spacing: 30

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20

        Text {
          id: compoundTitle
          anchors.verticalCenter: parent.verticalCenter
          color: "#FFFFFF"
          font.pixelSize: 14.0
          text: "You will <b>" + ((isyyCompound) ? "stake" : "unstake") + " AVAX/AVME LP</b>"
        }
        AVMEButton {
          id: btnSwitchCompoundOrder
          width: 200
          anchors.verticalCenter: parent.verticalCenter
          text: "Switch to " + ((isyyCompound) ? "Unstake" : "Stake")
          onClicked: {
            isyyCompound = !isyyCompound
            compoundInput.text = ""
          }
        }
      }

      Image {
        id: compoundLogo
        anchors.horizontalCenter: parent.horizontalCenter
        height: 48
        antialiasing: true
        smooth: true
        fillMode: Image.PreserveAspectFit
        source: "qrc:/img/pangolin.png"
      }

      Text {
        id: compoundBalance
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 18.0
        text: {
          var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
          text: (isyyCompound)
            ? "Free (unstaked) LP:<br><b>" + acc.balanceLPFree + "</b>"
            : "Locked (staked) LP:<br><b>" + acc.balanceLockedCompoundLP + "</b>"
        }
      }

      AVMEInput {
        id: compoundInput
        width: (parent.width * 0.8)
        anchors.left: parent.left
        enabled: (allowance != "")
        validator: RegExpValidator { regExp: /[0-9]{1,}(?:\.[0-9]{1,18})?/ }
        label: "Amount of LP to " + ((isyyCompound) ? "stake" : "unstake")
        placeholder: "Fixed point amount (e.g. 0.5)"

        AVMEButton {
          id: btnMaxAmountCompound
          width: (parent.parent.width * 0.2) - anchors.leftMargin
          anchors {
            left: parent.right
            leftMargin: 10
          }
          text: "Max"
          onClicked: {
            var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
            compoundInput.text = (isyyCompound) ? acc.balanceLPFree : acc.balanceLockedCompoundLP
          }
        }
      }

      Text {
        id: compoundLPReturnsText
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Locked LP Estimates:"
          + "<br><b>" + QmlSystem.weiToFixedPoint(
            (("AVAX" == lowerToken) ? userCompoundLowerReserves : userCompoundHigherReserves), 18
          ) + " AVAX"
          + "<br>" + QmlSystem.weiToFixedPoint(
            (("AVME" == lowerToken) ? userCompoundLowerReserves : userCompoundHigherReserves), 18
          ) + " AVME" + "</b>"
      }

      AVMEButton {
        id: btnDepositCompound
        width: parent.width
        enabled: {
          var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
          enabled: compoundallowance != "" && (
            !QmlSystem.isApproved(acc.balanceLPFree, compoundallowance) || compoundInput.acceptableInput
          )
        }
        text: {
          var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
          if (compoundallowance == "") {
            text: "Checking approval..."
          } else if (isyyCompound && QmlSystem.isApproved(acc.balanceLPFree, compoundallowance)) {
            text: "Stake"
          } else if (!isyyCompound && QmlSystem.isApproved(acc.balanceLockedCompoundLP, compoundallowance)) {
            text: "Unstake"
          } else {
            text: "Approve"
          }
        }
        onClicked: {
          var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
          if (!QmlSystem.isApproved(acc.balanceLPFree, compoundallowance)) {
            QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
            QmlSystem.operationOverride("Approve Compound", "", "", "")
          } else if (isyyCompound) {
            if (QmlSystem.hasInsufficientFunds("LP", acc.balanceLPFree, compoundInput.text)) {
              fundsPopup.open()
            } else {
              QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              QmlSystem.operationOverride("Stake Compound LP", "", "", compoundInput.text)
            }
          } else {
            if (QmlSystem.hasInsufficientFunds("LP", acc.balanceLockedCompoundLP, compoundInput.text)) {
              fundsPopup.open()
            } else {
              QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              QmlSystem.operationOverride("Unstake Compound LP", "", "", compoundInput.text)
            }
          }
        }
      }
    }
  }

  // Panel for reinvesting in YY
  AVMEPanel {
    id: reinvestPanel
    visible: !isClassic
    width: (parent.width * 0.5) - (anchors.margins * 2)
    anchors {
      top: stakingSelectPanel.bottom
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
    title: "Reinvesting Details (Optional)"

    Column {
      id: reinvestDetailsColumn
      anchors {
        top: parent.top
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        topMargin: 80
        bottomMargin: 20
        leftMargin: 40
        rightMargin: 40
      }
      spacing: 30

      Text {
        id: reinvestTitle
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "You will <b>reinvest AVME</b> rewards"
      }

      Image {
        id: reinvestTokenLogo
        anchors.horizontalCenter: parent.horizontalCenter
        height: 48
        antialiasing: true
        smooth: true
        fillMode: Image.PreserveAspectFit
        source: "qrc:/img/avme_logo.png"
      }

      Text {
        id: reinvestAmount
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Unreinvested rewards:<br><b>" + reinvestreward + " AVME</b>"
      }

      Text {
        id: reinvestRewardText
        anchors.horizontalCenter: parent.horizontalCenter
        width: 128
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Reinvesting returns:<br><b>" + (reinvestreward * 0.05) + " AVME</b>"
      }

      AVMEButton {
        id: btnreinvest
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (reinvestreward != "" && !QmlSystem.balanceIsZero(reinvestreward, 18))
        text: (reinvestreward != "") ? "Reinvest AVME" : "Querying Reinvest..."
        onClicked: {
          QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
          QmlSystem.operationOverride("Reinvest AVME", "", "", "")
        }
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
  }

  // Popup for insufficient funds
  AVMEPopupInfo {
    id: fundsPopup
    icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your inputs."
  }
}

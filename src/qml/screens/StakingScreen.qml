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
  
  property bool isClassic: true

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
    onTriggered: {
      QmlSystem.updateLiquidityData(QmlSystem.getCurrentCoin(), QmlSystem.getCurrentToken())
    }
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

      Text {
        id: stakeTitle
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#FFFFFF"
        font.bold: true
        font.pixelSize: 24.0
        text: (isStaking) ? "Stake LP" : "Unstake LP"
      }

      Image {
        id: stakeLogo
        width: 64
        height: 64
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        source: "qrc:/img/pangolin.png"
      }

      AVMEButton {
        id: btnSwitchOrder
        width: parent.width * 0.5
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Switch to " + ((isStaking) ? "Unstake" : "Stake")
        onClicked: {
          isStaking = !isStaking
          stakeInput.text = ""
        }
      }

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
        width: parent.width * 0.75
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (allowance != "")
        validator: RegExpValidator { regExp: /[0-9]{1,}(?:\.[0-9]{1,18})?/ }
        label: "Amount of LP to " + ((isStaking) ? "stake" : "unstake")
        placeholder: "Fixed point amount (e.g. 0.5)"
      }

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AVMEButton {
          id: btnMaxAmount
          width: (stakingDetailsColumn.width * 0.5) - parent.spacing
          enabled: (allowance != "")
          text: "Max Amount"
          onClicked: {
            var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
            stakeInput.text = (isStaking) ? acc.balanceLPFree : acc.balanceLPLocked
          }
        }

        AVMEButton {
          id: btnStake
          width: (stakingDetailsColumn.width * 0.5) - parent.spacing
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
        }
      }
      Rectangle {
        id: classicLPReturns
        width: parent.width
        height: classicLPReturnsText.height
        anchors {
          horizontalCenter: parent.horizontalCenter
          left: parent.left
          leftMargin: 10
        }
        color: "#3E4653"
        radius: 10
        Text {
          id: classicLPReturnsText
          width: parent.width
          verticalAlignment: Text.AlignVCenter
          color: "#FFFFFF"
          text: "Locked LP Estimates:"
            + "<br><b>" + QmlSystem.weiToFixedPoint(
              ((QmlSystem.getCurrentCoin() == lowerToken) ? userClassicLowerReserves : userClassicHigherReserves),
              QmlSystem.getCurrentCoinDecimals()
            ) + " " + QmlSystem.getCurrentCoin()
            + "<br>" + QmlSystem.weiToFixedPoint(
              ((QmlSystem.getCurrentToken() == lowerToken) ? userClassicLowerReserves : userClassicHigherReserves),
              QmlSystem.getCurrentTokenDecimals()
            ) + " " + QmlSystem.getCurrentToken() + "</b>"
        }
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
        font.bold: true
        font.pixelSize: 24.0
        text: "Harvest AVME"
      }

      Image {
        id: harvestTokenLogo
        width: 64
        height: 64
        anchors.horizontalCenter: parent.horizontalCenter
        source: "qrc:/img/avme_logo.png"
      }

      Text {
        id: rewardAmount
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 18.0
        text: "Unharvested " + QmlSystem.getCurrentToken() + ":<br><b>" + reward + "</b>"
      }

      AVMEButton {
        id: btnExitStake
        width: (parent.width * 0.75)
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: {
          var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
          enabled: (
            reward != "" && !QmlSystem.balanceIsZero(reward, QmlSystem.getCurrentTokenDecimals()) &&
            !QmlSystem.balanceIsZero(acc.balanceLPLocked, 18)
          )
        }
        text: (reward != "")
          ? "Harvest " + QmlSystem.getCurrentToken() + " & Unstake LP"
          : "Querying reward..."
        onClicked: {
          QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
          QmlSystem.operationOverride("Exit Staking", "", "", "")
        }
      }

      AVMEButton {
        id: btnHarvest
        width: (parent.width * 0.75)
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (reward != "" && !QmlSystem.balanceIsZero(reward, QmlSystem.getCurrentTokenDecimals()))
        text: (reward != "")
          ? "Harvest " + QmlSystem.getCurrentToken()
          : "Querying reward..."
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

      Text {
        id: compoundTitle
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#FFFFFF"
        font.bold: true
        font.pixelSize: 24.0
        text: (isyyCompound) ? "Stake LP" : "Unstake LP"
      }

      Image {
        id: compoundLogo
        width: 64
        height: 64
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        source: "qrc:/img/pangolin.png"
      }

      AVMEButton {
        id: btnSwitchCompoundOrder
        width: parent.width * 0.5
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Switch to " + ((isyyCompound) ? "Unstake" : "Stake")
        onClicked: {
          isyyCompound = !isyyCompound
          compoundInput.text = ""
        }
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
        width: parent.width * 0.75
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (allowance != "")
        validator: RegExpValidator { regExp: /[0-9]{1,}(?:\.[0-9]{1,18})?/ }
        label: "Amount of LP to " + ((isyyCompound) ? "stake" : "unstake")
        placeholder: "Fixed point amount (e.g. 0.5)"
      }

      Row {
        id: yyCompoundButtonRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AVMEButton {
          id: btnMaxAmountCompound
          width: (yyCompoundDetailsColumn.width * 0.5) - parent.spacing
          enabled: (compoundallowance != "")
          text: "Max Amount"
          onClicked: {
            var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
            compoundInput.text = (isyyCompound) ? acc.balanceLPFree : acc.balanceLockedCompoundLP
          }
        }

        AVMEButton {
          id: btnDepositCompound
          width: (yyCompoundDetailsColumn.width * 0.5) - parent.spacing
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
      Rectangle {
        id: compoundLPReturns
        width: parent.width
        height: compoundLPReturnsText.height
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#3e4653"
        radius: 10
        Text {
          id: compoundLPReturnsText
          width: parent.width
          anchors {
            left: parent.left
            leftMargin: 10
          }
          verticalAlignment: Text.AlignVCenter
          color: "#FFFFFF"
          text: "Locked LP Estimates:"
            + "<br><b>" + QmlSystem.weiToFixedPoint(
              ((QmlSystem.getCurrentCoin() == lowerToken) ? userCompoundLowerReserves : userCompoundHigherReserves),
              QmlSystem.getCurrentCoinDecimals()
            ) + " " + QmlSystem.getCurrentCoin()
            + "<br>" + QmlSystem.weiToFixedPoint(
              ((QmlSystem.getCurrentToken() == lowerToken) ? userCompoundLowerReserves : userCompoundHigherReserves),
              QmlSystem.getCurrentTokenDecimals()
            ) + " " + QmlSystem.getCurrentToken() + "</b>"
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
    title: "Reinvesting Details"

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
        font.bold: true
        font.pixelSize: 24.0
        text: "Reinvest AVME (Optional)"
      }

      Image {
        id: reinvestTokenLogo
        width: 64
        height: 64
        anchors.horizontalCenter: parent.horizontalCenter
        source: "qrc:/img/avme_logo.png"
      }

      Text {
        id: reinvestAmount
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 18.0
        text: "Unreinvested " + QmlSystem.getCurrentToken() + ":<br><b>" + reinvestreward + "</b>"
      }

      AVMEButton {
        id: btnreinvest
        width: (parent.width * 0.75)
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (reinvestreward != "" && !QmlSystem.balanceIsZero(reinvestreward, QmlSystem.getCurrentTokenDecimals()))
        text: (reinvestreward != "")
          ? "Reinvest " + QmlSystem.getCurrentToken()
          : "Querying Reinvest..."
        onClicked: {
          QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
          QmlSystem.operationOverride("Reinvest AVME", "", "", "")
        }
      }

      Text {
        id: reinvestRewardText
        anchors.horizontalCenter: parent.horizontalCenter
        width: 128
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 18.0
        text: "Reinvest Reward " + QmlSystem.getCurrentToken() + ":<br><b>" + (reinvestreward * 0.05) + "</b>"
      }
    }

    Image {
      id: yyLogo
      anchors {
        bottom: parent.bottom
        right: parent.right
        margins: 35
      }
      width: 128
      height: 64
      source: "qrc:/img/yieldyak.png"
      Text {
        color: "#FFFFFF"
        font.pixelSize: 18.0
        verticalAlignment: Text.AlignVCenter
        text: "Powered By"
        anchors {
          bottom: parent.bottom
          left: parent.left
          right: parent.right
          bottomMargin: -20
        }
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

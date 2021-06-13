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
    target: System
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
	  var acc = System.getAccountBalances(System.getCurrentAccount())
      var userClassicShares = System.calculatePoolSharesForTokenValue(
        lowerReserves, higherReserves, liquidity, acc.balanceLPLocked
      )
      var userCompoundShares = System.calculatePoolSharesForTokenValue(
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
    onTriggered: System.getPoolReward()
  }
  
  Timer {
    id: reloadCompoundTimer
    interval: 1000
    repeat: true
    onTriggered: System.getCompoundReward()
  }
  
  Timer {
    id: reloadLiquidityDataTimer
    interval: 5000
    repeat: true
    onTriggered: {
      System.updateLiquidityData(System.getCurrentCoin(), System.getCurrentToken())
	}
  }

  Component.onCompleted: {
    System.getAllowances()
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
	  color: "#1D212A"
	  anchors {
	  	top: accountHeader.bottom
	  	left: parent.left
	  	margins: 10
	  }
	  width: (parent.width - (anchors.margins * 2))
	  height: (parent.height * 0.075)
	  title: ""
	  AVMEButton {
        id: btnSwitchClassic
        width: parent.width * 0.25
		anchors.horizontalCenterOffset: -(parent.width / 4)
        anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
        text: "Classic"
        onClicked: {
          isClassic = true
        }
      }
	  AVMEButton {
        id: btnSwitchYYCompound
        width: parent.width * 0.25
		anchors.horizontalCenterOffset: parent.width / 4
        anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
        text: "YY Compound"
        onClicked: {
          isClassic = false
        }
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
        top: parent.header.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: 20
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
          var acc = System.getAccountBalances(System.getCurrentAccount())
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
            var acc = System.getAccountBalances(System.getCurrentAccount())
            stakeInput.text = (isStaking) ? acc.balanceLPFree : acc.balanceLPLocked
          }
        }

        AVMEButton {
          id: btnStake
          width: (stakingDetailsColumn.width * 0.5) - parent.spacing
          enabled: {
            var acc = System.getAccountBalances(System.getCurrentAccount())
            enabled: allowance != "" && (
              !System.isApproved(acc.balanceLPFree, allowance) || stakeInput.acceptableInput
            )
          }
          text: {
            var acc = System.getAccountBalances(System.getCurrentAccount())
            if (allowance == "") {
              text: "Checking approval..."
            } else if (isStaking && System.isApproved(acc.balanceLPFree, allowance)) {
              text: "Stake"
            } else if (!isStaking && System.isApproved(acc.balanceLPLocked, allowance)) {
              text: "Unstake"
            } else {
              text: "Approve"
            }
          }
          onClicked: {
            var acc = System.getAccountBalances(System.getCurrentAccount())
            if (!System.isApproved(acc.balanceLPFree, allowance)) {
              System.setScreen(content, "qml/screens/TransactionScreen.qml")
              System.operationOverride("Approve Staking", "", "", "")
            } else if (isStaking) {
              if (System.hasInsufficientFunds("LP", acc.balanceLPFree, stakeInput.text)) {
                fundsPopup.open()
              } else {
                System.setScreen(content, "qml/screens/TransactionScreen.qml")
                System.operationOverride("Stake LP", "", "", stakeInput.text)
              }
            } else {
              if (System.hasInsufficientFunds("LP", acc.balanceLPLocked, stakeInput.text)) {
                fundsPopup.open()
              } else {
                System.setScreen(content, "qml/screens/TransactionScreen.qml")
                System.operationOverride("Unstake LP", "", "", stakeInput.text)
              }
            }
          }
        }
      }
	  Rectangle {
	    id: classicLPReturns
	    anchors.horizontalCenter: parent.horizontalCenter
		width: parent.width
		color: "#3e4653"
		radius: 10
	    Text {
		  id: classicLPReturnsText
          anchors.left: parent.left
          anchors.leftMargin: 10
		  width: parent.width
		  verticalAlignment: Text.AlignVCenter
          color: "#FFFFFF"
		  text: "Locked LP Estimates:"
          + "<br><b>" + System.weiToFixedPoint(
            ((System.getCurrentCoin() == lowerToken) ? userClassicLowerReserves : userClassicHigherReserves),
            System.getCurrentCoinDecimals()
          ) + " " + System.getCurrentCoin()
          + "<br>" + System.weiToFixedPoint(
            ((System.getCurrentToken() == lowerToken) ? userClassicLowerReserves : userClassicHigherReserves),
            System.getCurrentTokenDecimals()
          ) + " " + System.getCurrentToken() + "</b>"
	    }
		height: classicLPReturnsText.height
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
        top: parent.header.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: 20
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
        text: "Unharvested " + System.getCurrentToken() + ":<br><b>" + reward + "</b>"
      }

      AVMEButton {
        id: btnExitStake
        width: (parent.width * 0.75)
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: {
          var acc = System.getAccountBalances(System.getCurrentAccount())
          enabled: (
            reward != "" && !System.balanceIsZero(reward, System.getCurrentTokenDecimals()) &&
            !System.balanceIsZero(acc.balanceLPLocked, 18)
          )
        }
        text: (reward != "")
        ? "Harvest " + System.getCurrentToken() + " & Unstake LP"
        : "Querying reward..."
        onClicked: {
          System.setScreen(content, "qml/screens/TransactionScreen.qml")
          System.operationOverride("Exit Staking", "", "", "")
        }
      }

      AVMEButton {
        id: btnHarvest
        width: (parent.width * 0.75)
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (reward != "" && !System.balanceIsZero(reward, System.getCurrentTokenDecimals()))
        text: (reward != "")
        ? "Harvest " + System.getCurrentToken()
        : "Querying reward..."
        onClicked: {
          System.setScreen(content, "qml/screens/TransactionScreen.qml")
          System.operationOverride("Harvest AVME", "", "", "")
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
        top: parent.header.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: 20
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
          var acc = System.getAccountBalances(System.getCurrentAccount())
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
            var acc = System.getAccountBalances(System.getCurrentAccount())
            compoundInput.text = (isyyCompound) ? acc.balanceLPFree : acc.balanceLockedCompoundLP
          }
        }

        AVMEButton {
          id: btnDepositCompound
          width: (yyCompoundDetailsColumn.width * 0.5) - parent.spacing
          enabled: {
            var acc = System.getAccountBalances(System.getCurrentAccount())
            enabled: compoundallowance != "" && (
              !System.isApproved(acc.balanceLPFree, compoundallowance) || compoundInput.acceptableInput
            )
          }
          text: {
            var acc = System.getAccountBalances(System.getCurrentAccount())
            if (compoundallowance == "") {
              text: "Checking approval..."
            } else if (isyyCompound && System.isApproved(acc.balanceLPFree, compoundallowance)) {
              text: "Stake"
            } else if (!isyyCompound && System.isApproved(acc.balanceLockedCompoundLP, compoundallowance)) {
              text: "Unstake"
            } else {
              text: "Approve"
            }
          }
          onClicked: {
            var acc = System.getAccountBalances(System.getCurrentAccount())
            if (!System.isApproved(acc.balanceLPFree, compoundallowance)) {
              System.setScreen(content, "qml/screens/TransactionScreen.qml")
              System.operationOverride("Approve Compound", "", "", "")
            } else if (isyyCompound) {
              if (System.hasInsufficientFunds("LP", acc.balanceLPFree, compoundInput.text)) {
                fundsPopup.open()
              } else {
                System.setScreen(content, "qml/screens/TransactionScreen.qml")
                System.operationOverride("Stake Compound LP", "", "", compoundInput.text)
              }
            } else {
              if (System.hasInsufficientFunds("LP", acc.balanceLockedCompoundLP, compoundInput.text)) {
                fundsPopup.open()
              } else {
                System.setScreen(content, "qml/screens/TransactionScreen.qml")
                System.operationOverride("Unstake Compound LP", "", "", compoundInput.text)
              }
            }
          }
        }
      }
	  Rectangle {
	    id: compoundLPReturns
	    anchors.horizontalCenter: parent.horizontalCenter
		width: parent.width
		color: "#3e4653"
		radius: 10
	    Text {
		  id: compoundLPReturnsText
          anchors.left: parent.left
          anchors.leftMargin: 10
		  width: parent.width
		  verticalAlignment: Text.AlignVCenter
          color: "#FFFFFF"
		  text: "Locked LP Estimates:"
          + "<br><b>" + System.weiToFixedPoint(
            ((System.getCurrentCoin() == lowerToken) ? userCompoundLowerReserves : userCompoundHigherReserves),
            System.getCurrentCoinDecimals()
          ) + " " + System.getCurrentCoin()
          + "<br>" + System.weiToFixedPoint(
            ((System.getCurrentToken() == lowerToken) ? userCompoundLowerReserves : userCompoundHigherReserves),
            System.getCurrentTokenDecimals()
          ) + " " + System.getCurrentToken() + "</b>"
	    }
		height: compoundLPReturnsText.height
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
        top: parent.header.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: 20
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
        text: "Unreinvested " + System.getCurrentToken() + ":<br><b>" + reinvestreward + "</b>"
      }

      AVMEButton {
        id: btnreinvest
        width: (parent.width * 0.75)
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (reinvestreward != "" && !System.balanceIsZero(reinvestreward, System.getCurrentTokenDecimals()))
        text: (reinvestreward != "")
        ? "Reinvest " + System.getCurrentToken()
        : "Querying Reinvest..."
        onClicked: {
          System.setScreen(content, "qml/screens/TransactionScreen.qml")
          System.operationOverride("Reinvest AVME", "", "", "")
        }
      }
      Text {
        id: reinvestRewardText
        anchors.horizontalCenter: parent.horizontalCenter
		width: 128
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 18.0
        text: "Reinvest Reward " + System.getCurrentToken() + ":<br><b>" + (reinvestreward * 0.05) + "</b>"
      }
    }
	Image {
	  anchors.bottom: parent.bottom
	  anchors.right: parent.right
	  anchors.margins: 35
	  id: yyLogo
	  width: 128
	  height: 64
	  source: "qrc:/img/yieldyak.png"
	  Text {
	    color: "#FFFFFF"
        font.pixelSize: 18.0
	    text: "Powered By"
        anchors.bottom: parent.bottom
        verticalAlignment: Text.AlignVCenter
		anchors.bottomMargin: -20
        anchors.left: parent.left
        anchors.right: parent.right
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

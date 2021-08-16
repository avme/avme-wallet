/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

// Screen for staking AVME with a given Account
Item {
  id: stakingScreen
  property bool isStaking: true
  property bool isClassic: true

  /*
  Connections {
    target: qmlSystem
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
      var acc = qmlSystem.getAccountBalances(qmlSystem.getCurrentAccount())
      var userClassicShares = qmlSystem.calculatePoolSharesForTokenValue(
        lowerReserves, higherReserves, liquidity, acc.balanceLPLocked
      )
      var userCompoundShares = qmlSystem.calculatePoolSharesForTokenValue(
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
    onTriggered: qmlSystem.getPoolReward()
  }

  Timer {
    id: reloadCompoundTimer
    interval: 1000
    repeat: true
    onTriggered: qmlSystem.getCompoundReward()
  }

  Timer {
    id: reloadLiquidityDataTimer
    interval: 5000
    repeat: true
    onTriggered: qmlSystem.updateLiquidityData("AVAX", "AVME")
  }

  Component.onCompleted: {
    // TODO: get staking/compound allowances
    std::string stakingAllowance = Pangolin::allowance(
      Pangolin::contracts["AVAX-AVME"],
      this->w.getCurrentAccount().first,
      Pangolin::contracts["staking"]
    );
    std::string compoundAllowance = Pangolin::allowance(
      Pangolin::contracts["AVAX-AVME"],
      this->w.getCurrentAccount().first,
      Pangolin::contracts["compound"]
    );
    reloadRewardTimer.start()
    reloadCompoundTimer.start()
    reloadLiquidityDataTimer.start()
  }
  */

  // Panel for selecting Classic x Compound
  AVMEPanel {
    id: stakingSelectPanel
    width: (parent.width - (anchors.margins * 2))
    height: (parent.height * 0.075)
    title: ""
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
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

  AVMEPanelStaking {
    id: stakingPanel
    width: (parent.width * 0.5) - (anchors.margins / 2)
    visible: isClassic
    anchors {
      top: stakingSelectPanel.bottom
      left: parent.left
      bottom: parent.bottom
      margins: 10
    }
  }

  AVMEPanelStakingRewards {
    id: stakingRewardsPanel
    visible: isClassic
    width: (parent.width * 0.5) - (anchors.margins / 2)
    anchors {
      top: stakingSelectPanel.bottom
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
  }

  AVMEPanelCompound {
    id: compoundPanel
    width: (parent.width * 0.5) - (anchors.margins / 2)
    visible: !isClassic
    anchors {
      top: stakingSelectPanel.bottom
      left: parent.left
      bottom: parent.bottom
      margins: 10
    }
  }

  AVMEPanelCompoundRewards {
    id: compoundRewardsPanel
    visible: !isClassic
    width: (parent.width * 0.5) - (anchors.margins / 2)
    anchors {
      top: stakingSelectPanel.bottom
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
  }

  // Popup for insufficient funds
  AVMEPopupInfo {
    id: fundsPopup
    icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your inputs."
  }

  // Popups for staking approval and confirmation, respectively
  // TODO: approval and confirm button logic on both panels
  AVMEPopupConfirmTx {
    id: confirmApprovalPopup
    info: "You will approve <b>AVAX/AVME LP</b> staking in the "
    + ((isClassic) ? "staking" : "compound") + " contract"
  }
  AVMEPopupConfirmTx {
    id: confirmStakePopup
    info: "You will " + ((isStaking) ? "stake" : "unstake") + " <b>AVAX/AVME LP</b>"
    + " in the " + ((isClassic) ? "staking" : "compound") + " contract"
  }

  AVMEPopupTxProgress {
    id: txProgressPopup
  }

  // TODO: Ledger popup here
}

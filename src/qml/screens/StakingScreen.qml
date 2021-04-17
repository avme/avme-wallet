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
  property string allowance
  property string reward

  Connections {
    target: System
    onAllowancesUpdated: allowance = stakingAllowance
    onRewardUpdated: reward = poolReward
  }

  Timer {
    id: reloadRewardTimer
    interval: 1000
    repeat: true
    onTriggered: System.getPoolReward()
  }

  Component.onCompleted: {
    System.getAllowances()
    reloadRewardTimer.start()
  }

  AVMEAccountHeader {
    id: accountHeader
  }

  // Panel for staking/unstaking LP
  AVMEPanel {
    id: stakingPanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
    anchors {
      top: accountHeader.bottom
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
        font.pointSize: 18.0
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
        font.pointSize: 14.0
        text: {
          var acc = System.getAccountBalances(System.getTxSenderAccount())
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
            var acc = System.getAccountBalances(System.getTxSenderAccount())
            stakeInput.text = (isStaking) ? acc.balanceLPFree : acc.balanceLPLocked
          }
        }

        AVMEButton {
          id: btnStake
          width: (stakingDetailsColumn.width * 0.5) - parent.spacing
          enabled: {
            var acc = System.getAccountBalances(System.getTxSenderAccount())
            enabled: allowance != "" && (
              !System.isApproved(acc.balanceLPFree, allowance) || stakeInput.acceptableInput
            )
          }
          text: {
            var acc = System.getAccountBalances(System.getTxSenderAccount())
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
            var acc = System.getAccountBalances(System.getTxSenderAccount())
            System.setScreen(content, "qml/screens/TransactionScreen.qml")
            if (!System.isApproved(acc.balanceLPFree, allowance)) {
              System.operationOverride("Approve Staking", "", "", "")
            } else if (isStaking) {
              System.operationOverride("Stake LP", "", "", stakeInput.text)
            } else {
              System.operationOverride("Unstake LP", "", "", stakeInput.text)
            }
          }
        }
      }
    }
  }

  // Panel for harvesting/exiting
  AVMEPanel {
    id: harvestPanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
    anchors {
      top: accountHeader.bottom
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
        font.pointSize: 18.0
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
        font.pointSize: 14.0
        text: "Unharvested " + System.getCurrentToken() + ":<br><b>" + reward + "</b>"
      }

      AVMEButton {
        id: btnExitStake
        width: (parent.width * 0.75)
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: {
          var acc = System.getAccountBalances(System.getTxSenderAccount())
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
}

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

    onAllowancesUpdated: {
      allowance = stakingAllowance
    }
    onRewardUpdated: {
      reward = poolReward
    }
  }

  Timer {
    id: reloadRewardTimer
    interval: 1000
    repeat: true
    onTriggered: {
      System.getPoolReward()
    }
  }

  Component.onCompleted: {
    System.getAllowances()
    reloadRewardTimer.start()
  }

  Text {
    id: info
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      margins: 20
    }
    horizontalAlignment: Text.AlignHCenter
    text: "Staking details for the Account<br><b>" + System.getTxSenderAccount() + "</b>"
    font.pointSize: 18.0
  }

  Rectangle {
    id: stakeRect
    width: parent.width * 0.45
    height: parent.height * 0.5
    anchors {
      verticalCenter: parent.verticalCenter
      left: parent.left
      margins: 20
    }
    color: "#44F66986"
    radius: 5

    Column {
      id: stakeItems
      anchors.fill: parent
      spacing: 30
      anchors.topMargin: 20

      Text {
        id: stakeTitle
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 14.0
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

      Text {
        id: stakeBalances
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: (isStaking)
        ? "Free (unstaked) LP: <b>" + System.getTxSenderLPFreeAmount() + "</b>"
        : "Locked (staked) LP: <b>" + System.getTxSenderLPLockedAmount() + "</b>"
      }

      AVMEInput {
        id: stakeInput
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.9
        enabled: (allowance != "")
        validator: RegExpValidator { regExp: /[0-9]{1,}(?:\.[0-9]{1,18})?/ }
        label: "Amount of LP to " + ((isStaking) ? "stake" : "unstake")
        placeholder: "Fixed point amount (e.g. 0.5)"
      }

      Row {
        id: stakeBtnRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        AVMEButton {
          id: btnMaxAmount
          width: stakeRect.width * 0.25
          enabled: (allowance != "")
          text: "Max Amount"
          onClicked: stakeInput.text = (isStaking)
          ? System.getTxSenderLPFreeAmount()
          : System.getTxSenderLPLockedAmount()
        }

        AVMEButton {
          id: btnSwitchOrder
          width: stakeRect.width * 0.35
          enabled: (allowance != "")
          text: "Switch to " + ((isStaking) ? "Unstake" : "Stake")
          onClicked: {
            isStaking = !isStaking
            stakeInput.text = ""
          }
        }

        AVMEButton {
          id: btnStake
          width: stakeRect.width * 0.25
          text: {
            if (allowance == "") {
              text: "Approval..."
            } else if (isStaking && System.isApproved(System.getTxSenderLPFreeAmount(), allowance)) {
              text: "Stake"
            } else if (!isStaking && System.isApproved(System.getTxSenderLPLockedAmount(), allowance)) {
              text: "Unstake"
            } else {
              text: "Approve"
            }
          }
          enabled: (allowance != "" && stakeInput.text != "")
          onClicked: {
            System.setTxGasLimit("250000")
            System.setTxGasPrice(System.getAutomaticFee())
            var lpAmount = (isStaking)
              ? System.getTxSenderLPFreeAmount() : System.getTxSenderLPLockedAmount()
            if (!System.isApproved(lpAmount, allowance)) {
              approveStakePopup.setTxData(System.getTxGasLimit(), System.getTxGasPrice())
              approveStakePopup.open()
              return
            }

            var noCoinFunds = System.hasInsufficientCoinFunds(
              System.getTxSenderCoinAmount(),
              System.calculateTransactionCost(
                "0", System.getTxGasLimit(), System.getTxGasPrice()
              )
            )
            var noLPFunds = System.hasInsufficientTokenFunds(
              lpAmount, stakeInput.text
            )

            if (noCoinFunds || noLPFunds) {
              fundsPopup.open()
            } else {
              confirmStakePopup.setTxData(
                isStaking, stakeInput.text, System.getTxGasLimit(), System.getTxGasPrice()
              )
              confirmStakePopup.open()
            }
          }
        }
      }
    }
  }

  Rectangle {
    id: harvestRect
    width: parent.width * 0.45
    height: parent.height * 0.5
    anchors {
      verticalCenter: parent.verticalCenter
      right: parent.right
      margins: 20
    }
    color: "#44F66986"
    radius: 5

    Column {
      id: harvestItems
      anchors.fill: parent
      spacing: 30
      anchors.topMargin: 20

      Text {
        id: harvestTitle
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 14.0
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
        id: unharvestedAmount
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: "Unharvested " + System.getCurrentToken() + ": <b>" + reward + "</b>"
      }

      AVMEButton {
        id: btnExitStake
        width: parent.width * 0.9
        enabled: (reward != "") // TODO: reward > 0 && locked LP > 0
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Harvest All " + System.getCurrentToken() + " & Unstake All LP"
        onClicked: {
          isExiting = true
          System.setTxGasLimit("250000")
          System.setTxGasPrice(System.getAutomaticFee())

          var noCoinFunds = System.hasInsufficientCoinFunds(
            System.getTxSenderCoinAmount(),
            System.calculateTransactionCost(
              "0", System.getTxGasLimit(), System.getTxGasPrice()
            )
          )

          if (noCoinFunds) {
            fundsPopup.open()
          } else {
            confirmHarvestPopup.setTxData(
              isExiting, reward, System.getCurrentToken(), System.getTxSenderLPLockedAmount(),
              System.getTxGasLimit(), System.getTxGasPrice()
            )
            confirmHarvestPopup.open()
          }
        }
      }

      AVMEButton {
        id: btnHarvest
        width: parent.width * 0.9
        enabled: (reward != "") // TODO: reward > 0
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Harvest All " + System.getCurrentToken()
        onClicked: {
          isExiting = false
          System.setTxGasLimit("250000")
          System.setTxGasPrice(System.getAutomaticFee())

          var noCoinFunds = System.hasInsufficientCoinFunds(
            System.getTxSenderCoinAmount(),
            System.calculateTransactionCost(
              "0", System.getTxGasLimit(), System.getTxGasPrice()
            )
          )

          if (noCoinFunds) {
            fundsPopup.open()
          } else {
            confirmHarvestPopup.setTxData(
              isExiting, reward, System.getCurrentToken(), "0",
              System.getTxGasLimit(), System.getTxGasPrice()
            )
            confirmHarvestPopup.open()
          }
        }
      }
    }
  }

  AVMEButton {
    id: btnBack
    width: parent.width / 6
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      margins: 20
    }
    text: "Back"
    onClicked: {
      reloadRewardTimer.stop()
      System.setScreen(content, "qml/screens/StatsScreen.qml")
    }
  }

  // Popup for confirming approval to stake
  AVMEPopupApprove {
    id: approveStakePopup
    confirmBtn.onClicked: {
      if (System.checkWalletPass(pass)) {
        reloadRewardTimer.stop()
        System.setTxOperation("Approve Staking")
        System.setScreen(content, "qml/screens/ProgressScreen.qml")
        System.txStart(pass)
      } else {
        approveExchangePopup.showErrorMsg()
      }
    }
  }

  // Popup for confirming LP (un)staking
  AVMEPopupConfirmStake {
    id: confirmStakePopup
    confirmBtn.onClicked: {
      if (System.checkWalletPass(pass)) {
        System.setTxReceiverLPAmount(stakeInput.text)
        System.setTxOperation((isStaking) ? "Stake LP" : "Unstake LP")
        System.setScreen(content, "qml/screens/ProgressScreen.qml")
        System.txStart(pass)
      } else {
        confirmStakePopup.showErrorMsg()
      }
    }
  }

  // Popup for confirming harvest
  AVMEPopupConfirmHarvest {
    id: confirmHarvestPopup
    confirmBtn.onClicked: {
      if (System.checkWalletPass(pass)) {
        System.setTxReceiverTokenAmount(reward)
        if (isExiting) { System.setTxReceiverLPAmount(System.getTxSenderLPLockedAmount()) }
        System.setTxOperation((isExiting) ? "Exit Staking" : "Harvest AVME")
        System.setScreen(content, "qml/screens/ProgressScreen.qml")
        System.txStart(pass)
      } else {
        confirmHarvestPopup.showErrorMsg()
      }
    }
  }

  // Popup for warning about insufficient funds
  AVMEPopupInfo {
    id: fundsPopup
    icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your transaction values."
  }
}

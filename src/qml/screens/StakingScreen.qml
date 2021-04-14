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

  // Panel for staking/unstaking LP
  AVMEPanel {
    id: stakingPanel
    width: (parent.width * 0.45)
    height: (parent.height * 0.85)
    anchors {
      left: parent.left
      verticalCenter: parent.verticalCenter
      margins: 40
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
        enabled: (allowance != "")
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
          text: "Max Amount"
          onClicked: {
            var acc = System.getAccountBalances(System.getTxSenderAccount())
            stakeInput.text = (isStaking) ? acc.balanceLPFree : acc.balanceLPLocked
          }
        }

        AVMEButton {
          id: btnStake
          width: (stakingDetailsColumn.width * 0.5) - parent.spacing
          enabled: (allowance != "" && stakeInput.acceptableInput)
          text: {
            if (allowance == "") {
              text: "Checking approval..."
            } else if (isStaking && System.isApproved(System.getTxSenderLPFreeAmount(), allowance)) {
              text: "Stake"
            } else if (!isStaking && System.isApproved(System.getTxSenderLPLockedAmount(), allowance)) {
              text: "Unstake"
            } else {
              text: "Approve"
            }
          }
          /*
          // TODO
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
          */
        }
      }
    }
  }

  // Panel for harvesting/exiting
  AVMEPanel {
    id: harvestPanel
    width: (parent.width * 0.45)
    height: (parent.height * 0.85)
    anchors {
      right: parent.right
      verticalCenter: parent.verticalCenter
      margins: 40
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
        enabled: (reward != "") // TODO: reward > 0 && locked LP > 0
        text: "Harvest " + System.getCurrentToken() + " & Unstake LP"
        /*
        // TODO
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
        */
      }

      AVMEButton {
        id: btnHarvest
        width: (parent.width * 0.75)
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (reward != "") // TODO: reward > 0
        text: "Harvest " + System.getCurrentToken()
        /*
        // TODO
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
        */
      }
    }
  }

  /*
  // TODO: remove those
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
  */
}

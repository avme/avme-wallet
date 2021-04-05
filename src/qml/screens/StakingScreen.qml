import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Screen for staking tokens with a given Account

Item {
  id: stakingScreen
  property bool isStaking

  Component.onCompleted: {
    isStaking = true
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
          text: "Max Amount"
          onClicked: stakeInput.text = (isStaking)
          ? System.getTxSenderLPFreeAmount()
          : System.getTxSenderLPLockedAmount()
        }

        AVMEButton {
          id: btnSwitchOrder
          width: stakeRect.width * 0.35
          text: "Switch to " + ((isStaking) ? "Unstake" : "Stake")
          onClicked: {
            isStaking = !isStaking
            stakeInput.text = ""
          }
        }

        AVMEButton {
          id: btnStake
          width: stakeRect.width * 0.25
          text: (isStaking) ? "Stake" : "Unstake"
          enabled: (stakeInput.text != "")  // TODO: stakeInput <= total amount
          onClicked: {} // TODO
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

      // TODO: real value here
      Text {
        id: unharvestedAmount
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: "Unharvested " + System.getCurrentToken() + ": <b>0.123thisvalueisfakeforme</b>"
      }

      // TODO: enable condition for this button
      AVMEButton {
        id: btnExitStake
        width: parent.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Harvest All " + System.getCurrentToken() + " & Unstake All LP"
        onClicked: {} // TODO
      }

      // TODO: approval part
      AVMEButton {
        id: btnHarvest
        width: parent.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Harvest All " + System.getCurrentToken()
        onClicked: {}  // TODO
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
    onClicked: System.setScreen(content, "qml/screens/StatsScreen.qml")
  }
}

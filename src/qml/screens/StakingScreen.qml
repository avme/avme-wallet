import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "qrc:/qml/components"

// Screen for staking tokens with a given Account
// TODO: the approval part

Item {
  id: stakingScreen

  Column {
    id: items
    anchors.fill: parent
    spacing: 20
    topPadding: 40

    Text {
      id: info
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      text: "Staking details for the Account<br><b>" + System.getTxSenderAccount() + "</b>"
      font.pointSize: 18.0
    }

    Row {
      id: stakeRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Rectangle {
        id: stakeRect
        color: "#44F66986"
        radius: 5
        width: (items.width / 2) - 20
        height: (items.height / 2) + 60

        Image {
          id: stakeCoinLogo
          width: 64
          height: 64
          anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 20
            horizontalCenterOffset: -64
          }
          source: "qrc:/img/avax_logo.png"
        }

        Image {
          id: stakeTokenLogo
          width: 64
          height: 64
          anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 20
            horizontalCenterOffset: 64
          }
          source: "qrc:/img/avme_logo.png"
        }

        Text {
          id: unstakedAmount
          anchors {
            top: stakeCoinLogo.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: 20
          }
          horizontalAlignment: Text.AlignHCenter
          text: "<b>" + System.getTxSenderLPFreeAmount() + "</b><br> Free (unstaked) "
          + System.getCurrentCoin() + "/" + System.getCurrentToken() + " LP Tokens"
          font.pointSize: 14.0
        }

        Text {
          id: stakedAmount
          anchors {
            top: unstakedAmount.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: 20
          }
          horizontalAlignment: Text.AlignHCenter
          text: "<b>" + System.getTxSenderLPLockedAmount() + "</b><br> Locked (staked) "
          + System.getCurrentCoin() + "/" + System.getCurrentToken() + " LP Tokens"
          font.pointSize: 14.0
        }

        AVMEInput {
          id: stakeInput
          anchors {
            top: stakedAmount.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: 40
          }
          width: parent.width - 40
          validator: RegExpValidator { regExp: /[0-9]{1,}(?:\.[0-9]{1,18})?/ }
          label: "LP Token Amount to Stake/Unstake"
          placeholder: "Fixed point amount (e.g. 0.5)"
        }

        // TODO: enabled conditions for buttons (stakeInput is not empty AND is less than the total amount)
        AVMEButton {
          id: btnUnstake
          width: parent.width / 3
          anchors {
            bottom: parent.bottom
            bottomMargin: 70
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: -150
          }
          text: "Unstake"
          onClicked: {} // TODO
        }

        AVMEButton {
          id: btnUnstakeAll
          width: parent.width / 3
          anchors {
            bottom: parent.bottom
            bottomMargin: 10
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: -150
          }
          text: "Unstake All"
          onClicked: stakeInput.text = System.getTxSenderLPLockedAmount() // TODO: automatic tx
        }

        AVMEButton {
          id: btnStake
          width: parent.width / 3
          anchors {
            bottom: parent.bottom
            bottomMargin: 70
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: 150
          }
          text: "Stake"
          onClicked: {} // TODO
        }

        AVMEButton {
          id: btnStakeAll
          width: parent.width / 3
          anchors {
            bottom: parent.bottom
            bottomMargin: 10
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: 150
          }
          text: "Stake All"
          onClicked: stakeInput.text = System.getTxSenderLPFreeAmount() // TODO: automatic tx
        }
      }

      Rectangle {
        id: harvestRect
        color: "#44F66986"
        radius: 5
        width: (items.width / 2) - 20
        height: (items.height / 2) + 60

        Image {
          id: harvestTokenLogo
          width: 64
          height: 64
          anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 20
          }
          source: "qrc:/img/avme_logo.png"
        }

        Text {
          id: unharvestedAmount
          anchors {
            top: harvestTokenLogo.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: 20
          }
          horizontalAlignment: Text.AlignHCenter
          // TODO: real value here
          text: "<b>0.123thisvalueisfakeforme</b>"
          + "<br>Unharvested " + System.getCurrentToken()
          font.pointSize: 14.0
        }

        AVMEButton {
          id: btnHarvest
          width: parent.width - 20
          anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 10
          }
          text: "Harvest"
          onClicked: {}  // TODO
        }
      }
    }

    // TODO: enable condition for this button
    AVMEButton {
      id: btnExitStake
      width: parent.width / 2
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Harvest " + System.getCurrentToken() + " & Unstake "
      + System.getCurrentCoin() + "/" + System.getCurrentToken() + " LP Tokens"
      onClicked: {} // TODO
    }

    AVMEButton {
      id: btnBack
      width: parent.width / 6
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Back"
      onClicked: System.setScreen(content, "qml/screens/StatsScreen.qml")
    }
  }
}

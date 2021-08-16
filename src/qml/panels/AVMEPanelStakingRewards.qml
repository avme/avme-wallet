/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Panel for classic staking rewards
AVMEPanel {
  id: stakingRewardsPanel
  property string reward
  title: "Classic Staking Rewards"

  Column {
    id: stakingRewardsDetailsColumn
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
      // TODO
      /*
      enabled: {
        var acc = qmlSystem.getAccountBalances(qmlSystem.getCurrentAccount())
        enabled: (
          reward != "" && !qmlSystem.balanceIsZero(reward, 18) &&
          !qmlSystem.balanceIsZero(acc.balanceLPLocked, 18)
        )
      }
      */
      text: (reward != "") ? "Harvest AVME & Unstake LP" : "Querying reward..."
      // TODO: transaction logic
    }

    AVMEButton {
      id: btnHarvest
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (reward != "" && !qmlSystem.balanceIsZero(reward, 18))
      text: (reward != "") ? "Harvest AVME" : "Querying reward..."
      // TODO: transaction logic
    }
  }
}

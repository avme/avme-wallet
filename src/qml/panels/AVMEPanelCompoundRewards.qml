/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Panel for compound staking rewards
AVMEPanel {
  id: compoundRewardsPanel
  property string reward
  title: "Compound Staking Rewards"

  Column {
    id: compoundRewardsDetailsColumn
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
      text: "You will <b>reinvest AVME</b> rewards (OPTIONAL)"
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
      text: "Unreinvested rewards:<br><b>" + reward + " AVME</b>"
    }

    Text {
      id: reinvestRewardText
      anchors.horizontalCenter: parent.horizontalCenter
      width: 128
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Reinvesting returns:<br><b>" + (reward * 0.05) + " AVME</b>"
    }

    AVMEButton {
      id: btnreinvest
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (reward != "" && !qmlSystem.balanceIsZero(reward, 18))
      text: (reward != "") ? "Reinvest AVME" : "Querying Reinvest..."
      // TODO: transaction logic
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

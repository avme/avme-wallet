/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Panel for classic staking (AVME smart contract)
AVMEPanel {
  id: stakingPanel
  property string allowance
  //property string lowerToken
  property string lowerReserves
  property string higherReserves
  title: "Classic Staking"

  Column {
    id: stakingHeaderColumn
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      topMargin: 80
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 30

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 20

      Text {
        id: stakeTitle
        anchors.verticalCenter: parent.verticalCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "You will <b>" + ((isStaking) ? "stake" : "unstake") + " AVAX/AVME LP</b>"
      }
      AVMEButton {
        id: btnSwitchOrder
        width: 200
        anchors.verticalCenter: parent.verticalCenter
        text: "Switch to " + ((isStaking) ? "Unstake" : "Stake")
        onClicked: {
          isStaking = !isStaking
          stakeInput.text = ""
        }
      }
    }

    Image {
      id: stakeLogo
      anchors.horizontalCenter: parent.horizontalCenter
      height: 48
      antialiasing: true
      smooth: true
      fillMode: Image.PreserveAspectFit
      source: "qrc:/img/pangolin.png"
    }

    // TODO: fix balances to fix this
    Text {
      id: stakeBalance
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 18.0
      /*
      text: {
        var acc = qmlSystem.getAccountBalances(qmlSystem.getCurrentAccount())
        text: (isStaking)
        ? "Free (unstaked) LP:<br><b>" + acc.balanceLPFree + "</b>"
        : "Locked (staked) LP:<br><b>" + acc.balanceLPLocked + "</b>"
      }
      */
    }
  }

  Column {
    id: stakingApprovalColumn
    visible: !stakingDetailsColumn.visible
    anchors {
      top: stakingHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: 20
      bottomMargin: 20
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 30

    Text {
      id: stakingApprovalText
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "You need to approve your Account in order to stake<br>"
      + "<b>AVAX/AVME LP</b> in the staking contract."
      + "<br>This operation will have a total gas cost of:<br><b>"
      + qmlSystem.calculateTransactionCost("0", "180000", qmlSystem.getAutomaticFee())
      + " AVAX</b>"
    }

    AVMEButton {
      id: btnApprove
      width: parent.width
      enabled: (+accountHeader.coinRawBalance >=
        +qmlSystem.calculateTransactionCost("0", "180000", qmlSystem.getAutomaticFee())
      )
      anchors.horizontalCenter: parent.horizontalCenter
      text: (enabled) ? "Approve" : "Not enough funds"
    }
  }

  Column {
    id: stakingDetailsColumn
    visible: false
    anchors {
      top: stakingHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: 20
      bottomMargin: 20
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 30

    AVMEInput {
      id: stakeInput
      width: (parent.width * 0.8)
      anchors.left: parent.left
      enabled: (allowance != "")
      validator: RegExpValidator { regExp: /[0-9]{1,}(?:\.[0-9]{1,18})?/ }
      label: "Amount of AVAX/AVME LP to " + ((isStaking) ? "stake" : "unstake")
      placeholder: "Fixed point amount (e.g. 0.5)"

      AVMEButton {
        id: btnMaxAmount
        width: (parent.parent.width * 0.2) - anchors.leftMargin
        anchors {
          left: parent.right
          leftMargin: 10
        }
        text: "Max"
        // TODO
        //onClicked: {
        //  var acc = qmlSystem.getAccountBalances(qmlSystem.getCurrentAccount())
        //  stakeInput.text = (isStaking) ? acc.balanceLPFree : acc.balanceLPLocked
        //}
      }
    }

    Text {
      id: classicLPReturnsText
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      // TODO
      /*
      text: "Locked LP Estimates:"
        + "<br><b>" + qmlSystem.weiToFixedPoint(
          (("AVAX" == lowerToken) ? lowerReserves : higherReserves), 18
        ) + " AVAX"
        + "<br>" + qmlSystem.weiToFixedPoint(
          (("AVME" == lowerToken) ? lowerReserves : higherReserves), 18
        ) + " AVME" + "</b>"
      */
    }

    AVMEButton {
      id: btnStake
      width: parent.width
      enabled: (allowance != "" && stakeInput.acceptableInput)
      // TODO
      /*
      text: {
        var acc = qmlSystem.getAccountBalances(qmlSystem.getCurrentAccount())
        if (allowance == "") {
          text: "Checking approval..."
        } else if (isStaking && qmlSystem.isApproved(acc.balanceLPFree, allowance)) {
          text: "Stake"
        } else if (!isStaking && qmlSystem.isApproved(acc.balanceLPLocked, allowance)) {
          text: "Unstake"
        } else {
          text: "Approve"
        }
      }
      */
      // TODO: transaction logic
    }
  }
}

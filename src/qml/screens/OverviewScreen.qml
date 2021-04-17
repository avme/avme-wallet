/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Screen for showing an overview for the Wallet, Account, etc.
Item {
  id: overviewScreen

  // Timer for reloading the Account balances
  Timer {
    id: listReloadTimer
    interval: 1000
    repeat: true
    onTriggered: reloadBalances()
  }

  Component.onCompleted: {
    reloadBalances()
    listReloadTimer.start()
  }

  function reloadBalances() {
    var acc = System.getAccountBalances(System.getTxSenderAccount())
    var wal = System.getAllAccountBalances()
    accountCoinBalance.text = (acc.balanceAVAX) ? acc.balanceAVAX : "Loading..."
    accountTokenBalance.text = (acc.balanceAVME) ? acc.balanceAVME : "Loading..."
    stakingLockedBalance.text = (acc.balanceLPLocked) ? acc.balanceLPLocked : "Loading..."
    walletCoinBalance.text = (wal.balanceAVAX) ? wal.balanceAVAX : "Loading..."
    walletTokenBalance.text = (wal.balanceAVME) ? wal.balanceAVME : "Loading..."
  }

  AVMEAccountHeader {
    id: accountHeader
  }

  AVMEPanel {
    id: accountBalancesPanel
    anchors {
      top: accountHeader.bottom
      left: parent.left
      margins: 10
    }
    width: parent.width * 0.3
    height: 200
    title: "Account Balances"

    Column {
      anchors {
        top: parent.header.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        topMargin: 20
      }
      spacing: 20

      Row {
        id: accountCoinBalanceRow
        width: parent.width * 0.95
        anchors.horizontalCenter: parent.horizontalCenter
        height: 50
        spacing: 20

        Image {
          id: accountCoinLogo
          height: parent.height
          antialiasing: true
          smooth: true
          source: "qrc:/img/avax_logo.png"
          fillMode: Image.PreserveAspectFit
        }

        Text {
          id: accountCoinBalance
          width: parent.width * 0.3
          anchors.verticalCenter: parent.verticalCenter
          color: "#FFFFFF"
          elide: Text.ElideRight
        }

        Rectangle {
          width: 2
          height: parent.height
          color: "#4E525D"
        }

        Text {
          id: accountCoinPrice
          width: parent.width * 0.3
          anchors.verticalCenter: parent.verticalCenter
          color: "#FFFFFF"
          text: "$999999999.99"
          elide: Text.ElideRight
        }
      }

      Row {
        id: accountTokenBalanceRow
        width: parent.width * 0.95
        anchors.horizontalCenter: parent.horizontalCenter
        height: 50
        spacing: 20

        Image {
          id: accountTokenLogo
          height: parent.height
          antialiasing: true
          smooth: true
          source: "qrc:/img/avme_logo.png"
          fillMode: Image.PreserveAspectFit
        }

        Text {
          id: accountTokenBalance
          width: parent.width * 0.3
          anchors.verticalCenter: parent.verticalCenter
          color: "#FFFFFF"
          elide: Text.ElideRight
        }

        Rectangle {
          width: 2
          height: parent.height
          color: "#4E525D"
        }

        Text {
          id: accountTokenPrice
          width: parent.width * 0.3
          anchors.verticalCenter: parent.verticalCenter
          color: "#FFFFFF"
          text: "$99999.99"
          elide: Text.ElideRight
        }
      }
    }
  }

  AVMEPanel {
    id: walletBalancesPanel
    anchors {
      top: accountHeader.bottom
      left: accountBalancesPanel.right
      right: parent.right
      margins: 10
    }
    height: 200
    title: "Total Wallet Balances"

    Column {
      anchors {
        top: parent.header.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        topMargin: 20
      }
      spacing: 20

      Row {
        id: walletCoinBalanceRow
        width: parent.width * 0.95
        anchors.horizontalCenter: parent.horizontalCenter
        height: 50
        spacing: 20

        Image {
          id: walletCoinLogo
          height: parent.height
          antialiasing: true
          smooth: true
          source: "qrc:/img/avax_logo.png"
          fillMode: Image.PreserveAspectFit
        }

        Text {
          id: walletCoinBalance
          width: parent.width * 0.3
          anchors.verticalCenter: parent.verticalCenter
          color: "#FFFFFF"
          text: "54321.123456789123456789"
          elide: Text.ElideRight
        }

        Rectangle {
          width: 2
          height: parent.height
          color: "#4E525D"
        }

        Text {
          id: walletCoinPrice
          width: parent.width * 0.3
          anchors.verticalCenter: parent.verticalCenter
          color: "#FFFFFF"
          text: "$999999999.99"
          elide: Text.ElideRight
        }
      }

      Row {
        id: walletTokenBalanceRow
        width: parent.width * 0.95
        anchors.horizontalCenter: parent.horizontalCenter
        height: 50
        spacing: 20

        Image {
          id: walletTokenLogo
          height: parent.height
          antialiasing: true
          smooth: true
          source: "qrc:/img/avme_logo.png"
          fillMode: Image.PreserveAspectFit
        }

        Text {
          id: walletTokenBalance
          width: parent.width * 0.3
          anchors.verticalCenter: parent.verticalCenter
          color: "#FFFFFF"
          text: "987654321.123456789123456789"
          elide: Text.ElideRight
        }

        Rectangle {
          width: 2
          height: parent.height
          color: "#4E525D"
        }

        Text {
          id: walletTokenPrice
          width: parent.width * 0.3
          anchors.verticalCenter: parent.verticalCenter
          color: "#FFFFFF"
          text: "$99999.99"
          elide: Text.ElideRight
        }
      }
    }
  }

  AVMEPanel {
    id: stakingPanel
    anchors {
      top: accountBalancesPanel.bottom
      left: parent.left
      margins: 10
    }
    width: parent.width * 0.45
    height: 420
    title: "Staking Statistics"

    Rectangle {
      id: stakingLockedRect
      width: parent.width * 0.9
      height: 50
      anchors {
        horizontalCenter: parent.horizontalCenter
        top: parent.header.bottom
        margins: 10
      }
      color: "#3E4653"
      radius: 10

      Text {
        id: stakingLockedBalance
        anchors {
          verticalCenter: parent.verticalCenter
          left: parent.left
          leftMargin: 10
        }
        width: parent.width * 0.75
        color: "#FFFFFF"
        elide: Text.ElideRight
      }

      Text {
        id: stakingLockedText
        anchors {
          verticalCenter: parent.verticalCenter
          right: parent.right
          rightMargin: 10
        }
        color: "#FFFFFF"
        text: "Locked LP"
      }
    }

    Text {
      id: rewardCurrentTitle
      anchors {
        top: stakingLockedRect.bottom
        horizontalCenter: parent.horizontalCenter
        topMargin: 10
      }
      color: "#FFFFFF"
      text: "Current AVME Reward"
    }

    Text {
      id: rewardAmount
      width: parent.width * 0.9
      anchors {
        top: rewardCurrentTitle.bottom
        horizontalCenter: parent.horizontalCenter
      }
      color: "#FFFFFF"
      font.pointSize: 18.0
      text: "6329897479843233.887376387564877632"
      elide: Text.ElideRight
    }

    Text {
      id: rewardFutureTitle
      anchors {
        top: rewardAmount.bottom
        horizontalCenter: parent.horizontalCenter
        topMargin: 20
      }
      color: "#FFFFFF"
      text: "Future Rewards"
    }

    Column {
      id: rewardFutureTable
      width: parent.width * 0.9
      anchors {
        top: rewardFutureTitle.bottom
        bottom: stakingBtnRow.top
        horizontalCenter: parent.horizontalCenter
      }
      spacing: 10

      Text {
        anchors.left: parent.left
        width: parent.width
        color: "#FFFFFF"
        text: "30 days"
        elide: Text.ElideRight
        Text {
          anchors.right: parent.right
          color: "#FFFFFF"
          text: "...%"
        }
      }

      Text {
        anchors.left: parent.left
        width: parent.width
        color: "#FFFFFF"
        text: "60 days"
        elide: Text.ElideRight
        Text {
          anchors.right: parent.right
          color: "#FFFFFF"
          text: "...%"
        }
      }

      Text {
        anchors.left: parent.left
        width: parent.width
        color: "#FFFFFF"
        text: "90 days"
        elide: Text.ElideRight
        Text {
          anchors.right: parent.right
          color: "#FFFFFF"
          text: "...%"
        }
      }

      Text {
        anchors.left: parent.left
        width: parent.width
        color: "#FFFFFF"
        text: "180 days"
        elide: Text.ElideRight
        Text {
          anchors.right: parent.right
          color: "#FFFFFF"
          text: "...%"
        }
      }

      Text {
        anchors.left: parent.left
        width: parent.width
        color: "#FFFFFF"
        text: "360 days"
        elide: Text.ElideRight
        Text {
          anchors.right: parent.right
          color: "#FFFFFF"
          text: "...%"
        }
      }
    }

    Row {
      id: stakingBtnRow
      anchors {
        horizontalCenter: parent.horizontalCenter
        bottom: parent.bottom
        margins: 10
      }
      spacing: 20

      AVMEButton {
        id: btnGetReward
        width: stakingPanel.width * 0.4
        text: "Get Reward"
      }
      AVMEButton {
        id: btnStakingInfo
        width: stakingPanel.width * 0.4
        text: "Staking Info"
      }
    }
  }

  AVMEPanel {
    id: marketDataPanel
    anchors {
      top: walletBalancesPanel.bottom
      left: stakingPanel.right
      right: parent.right
      margins: 10
    }
    height: 420
    title: "Market Data"
  }
}

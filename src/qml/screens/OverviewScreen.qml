import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Screen for showing an overview for the Wallet, Account, etc.

Item {
  id: overviewScreen

  Component.onCompleted: {
    if (!window.menu.visible) {
      window.menu.visible = true
    }
  }

  Rectangle {
    id: accountHeaderRow
    x: window.menu.width + 10
    width: (parent.width * 0.9) + 20
    height: 50
    color: "#1D212A"
    radius: 10
    anchors.top: parent.top
    anchors.topMargin: 10

    Text {
      id: addressText
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      anchors.leftMargin: 10
      color: "#FFFFFF"
      text: "Account: 0x1234567890123456789012345678901234567890"
      font.pointSize: 18.0
    }

    AVMEButton {
      id: btnChangeAccount
      width: parent.width * 0.1
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: btnCopyToClipboard.left
      anchors.rightMargin: 10
      text: "Change"
    }

    AVMEButton {
      id: btnCopyToClipboard
      width: parent.width * 0.2
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: parent.right
      anchors.rightMargin: 10
      enabled: (!btnChangeAccountTimer.running)
      text: (enabled) ? "Copy to Clipboard" : "Copied!"
      Timer { id: btnChangeAccountTimer; interval: 2000 }
      onClicked: {
        System.copyToClipboard(System.getTxSenderAccount())
        btnChangeAccountTimer.start()
      }
    }
  }

  AVMEPanel {
    id: accountBalancesPanel
    x: window.menu.width + 10
    anchors.top: accountHeaderRow.bottom
    anchors.topMargin: 20
    width: parent.width * 0.45
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
          width: parent.width * 0.5
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
          width: parent.width * 0.5
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
    x: accountBalancesPanel.x + accountBalancesPanel.width + 20
    anchors.top: accountHeaderRow.bottom
    anchors.topMargin: 20
    width: parent.width * 0.45
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
          width: parent.width * 0.5
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
          width: parent.width * 0.5
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
    x: window.menu.width + 10
    anchors.top: accountBalancesPanel.bottom
    anchors.topMargin: 20
    width: parent.width * 0.45
    height: 400
    title: "Staking Statistics"

    Rectangle {
      id: stakingLockedRect
      width: parent.width * 0.9
      height: 50
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.header.bottom
      anchors.margins: 10
      color: "#3E4653"
      radius: 10

      Text {
        id: stakingLockedBalance
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        width: parent.width * 0.75
        color: "#FFFFFF"
        text: "34373827243243235.893729889472394325"
        elide: Text.ElideRight
      }

      Text {
        id: stakingLockedText
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        color: "#FFFFFF"
        text: "Locked LP"
      }
    }

    Text {
      id: rewardCurrentTitle
      anchors.top: stakingLockedRect.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.topMargin: 10
      color: "#FFFFFF"
      text: "Current AVME Reward"
    }

    Text {
      id: rewardAmount
      width: parent.width * 0.9
      anchors.top: rewardCurrentTitle.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      color: "#FFFFFF"
      font.pointSize: 18.0
      text: "6329897479843233.887376387564877632"
      elide: Text.ElideRight
    }

    Text {
      id: rewardFutureTitle
      anchors.top: rewardAmount.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.topMargin: 20
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
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.margins: 10
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
    x: stakingPanel.x + stakingPanel.width + 20
    anchors.top: walletBalancesPanel.bottom
    anchors.topMargin: 20
    width: parent.width * 0.45
    height: 400
    title: "Market Data"
  }
}

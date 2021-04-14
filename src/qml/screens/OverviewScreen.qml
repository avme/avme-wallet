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

  Rectangle {
    id: accountHeaderRow
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      margins: 10
    }
    height: 50
    color: "#1D212A"
    radius: 10

    Text {
      id: addressText
      anchors {
        verticalCenter: parent.verticalCenter
        left: parent.left
        leftMargin: 10
      }
      color: "#FFFFFF"
      text: System.getTxSenderAccount()
      font.pointSize: 16.0
    }

    AVMEButton {
      id: btnChangeWallet
      width: parent.width * 0.15
      anchors {
        verticalCenter: parent.verticalCenter
        right: btnChangeAccount.left
        rightMargin: 10
      }
      text: "Change Wallet"
      onClicked: {
        System.hideMenu()
        System.setScreen(content, "qml/screens/StartScreen.qml")
      }
    }

    AVMEButton {
      id: btnChangeAccount
      width: parent.width * 0.15
      anchors {
        verticalCenter: parent.verticalCenter
        right: btnCopyToClipboard.left
        rightMargin: 10
      }
      text: "Change Account"
      onClicked: {
        System.hideMenu()
        System.setScreen(content, "qml/screens/AccountsScreen.qml")
      }
    }

    /*
    // TODO: move those somewhere else
    AVMEButton {
      id: btnViewPrivKey
      width: parent.width * 0.15
      anchors {
        verticalCenter: parent.verticalCenter
        right: btnViewSeed.left
        rightMargin: 10
      }
      text: "View Private Key"
      onClicked: {
        viewPrivKeyPopup.account = System.getTxSenderAccount()
        viewPrivKeyPopup.open()
      }
    }

    AVMEButton {
      id: btnViewSeed
      width: parent.width * 0.15
      anchors {
        verticalCenter: parent.verticalCenter
        right: btnCopyToClipboard.left
        rightMargin: 10
      }
      text: "View Wallet Seed"
      onClicked: viewSeedPopup.open()
    }
    */

    AVMEButton {
      id: btnCopyToClipboard
      width: parent.width * 0.2
      anchors {
        verticalCenter: parent.verticalCenter
        right: parent.right
        rightMargin: 10
      }
      enabled: (!btnClipboardTimer.running)
      text: (enabled) ? "Copy to Clipboard" : "Copied!"
      Timer { id: btnClipboardTimer; interval: 2000 }
      onClicked: {
        System.copyToClipboard(System.getTxSenderAccount())
        btnClipboardTimer.start()
      }
    }
  }

  AVMEPanel {
    id: accountBalancesPanel
    anchors {
      top: accountHeaderRow.bottom
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
      top: accountHeaderRow.bottom
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

  /**
  // TODO: move those somewhere else
  // Popup for viewing the Account's private key
  AVMEPopupViewPrivKey {
    id: viewPrivKeyPopup
    showBtn.onClicked: {
      if (System.checkWalletPass(pass)) {
        viewPrivKeyPopup.showPrivKey()
      } else {
        viewPrivKeyPopup.showErrorMsg()
      }
    }
  }

  // Popup for viewing the Wallet's seed
  AVMEPopupViewSeed {
    id: viewSeedPopup
    showBtn.onClicked: {
      if (System.checkWalletPass(pass)) {
        viewSeedPopup.showSeed()
      } else {
        viewSeedPopup.showErrorMsg()
      }
    }
  }
  */
}

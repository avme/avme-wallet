import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

/**
 * Screen for listing an Account's stats and transaction history
 * as well as several transaction actions for it
 */

Item {
  id: statsScreen

  // Background icon
  Image {
    id: bgIcon
    width: 256
    height: 256
    anchors.centerIn: parent
    fillMode: Image.PreserveAspectFit
    source: "qrc:/img/avme_logo.png"
  }

  // Account and copy/change buttons
  Row {
    id: statsHeaderRow
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      topMargin: 10
      leftMargin: 10
    }
    spacing: 10

    AVMEButton {
      id: btnChangeAccount
      width: (parent.width / 4) - parent.spacing
      text: "Change Account"
      onClicked: System.setScreen(content, "qml/screens/AccountsScreen.qml")
    }
    Text {
      id: accountText
      width: (parent.width / 2) - parent.spacing
      horizontalAlignment: Text.AlignHCenter
      text: "Stats for the Account:<br><b>" + System.getTxSenderAccount() + "</b>"
    }
    AVMEButton {
      id: btnCopyAddress
      width: (parent.width / 4) - parent.spacing
      Timer { id: textTimer; interval: 2000 }
      enabled: (!textTimer.running)
      text: (!textTimer.running) ? "Copy to Clipboard" : "Copied!"
      onClicked: {
        System.copyToClipboard(System.getTxSenderAccount())
        textTimer.start()
      }
    }
  }

  // List of sent transactions (left)
  Rectangle {
    id: listRect
    width: (parent.width * 0.35)
    anchors {
      top: statsHeaderRow.bottom
      bottom: parent.bottom
      left: parent.left
      margins: 10
    }
    radius: 5
    color: "#4458A0C9"

    AVMETxHistoryList {
      id: historyList
      anchors.fill: parent
      // TODO: put real data here later
      model: ListModel {
        id: historyModel
        ListElement {
          txlink: "https://etherscan.io/"
          operation: "Unlock AVAX/AVME"
          from: "0x1234567890123456789012345678901234567890"
          to: "0x9876543210987654321098765432109876543210"
          value: "11111.123456789123456789"
          gas: "21000"
          price: "470"
          datetime: "01/01/1970 00:00:00"
          confirmed: true
        }
        ListElement {
          txlink: "https://blockchair.com/"
          operation: "Send AVAX"
          from: "0x1234567890123456789012345678901234567890"
          to: "0x9876543210987654321098765432109876543210"
          value: "99999.987654321987654321"
          gas: "21000"
          price: "470"
          datetime: "02/02/1970 00:00:00"
          confirmed: false
        }
        ListElement {
          txlink: "https://explorer.avax.network"
          operation: "Get AVME Rewards"
          from: "0x1234567890123456789012345678901234567890"
          to: "0x9876543210987654321098765432109876543210"
          value: "12345.123456789987654321"
          gas: "21000"
          price: "470"
          datetime: "03/03/1970 00:00:00"
          confirmed: true
        }
      }
    }
  }

  // Account stats and actions (top right)
  Rectangle {
    id: statsRect
    height: (parent.height * 0.45)
    anchors {
      top: statsHeaderRow.bottom
      left: listRect.right
      right: parent.right
      margins: 10
    }
    radius: 5
    color: "#CC9A4FAD"

    Text {
      id: balanceTitle
      anchors {
        top: parent.top
        horizontalCenter: parent.horizontalCenter
        margins: 10
      }
      text: "Account Balances"
    }

    Text {
      id: balanceCoinText
      anchors {
        top: balanceTitle.bottom
        left: parent.left
        margins: 10
      }
      font.bold: true
      font.pointSize: 14.0
      text: System.getTxSenderCoinAmount()
    }

    Text {
      id: balanceCoinType
      anchors {
        top: balanceTitle.bottom
        right: parent.right
        margins: 10
      }
      font.pointSize: 14.0
      text: System.getCurrentCoin()
    }

    Text {
      id: balanceTokenText
      anchors {
        top: balanceCoinText.bottom
        left: parent.left
        margins: 10
      }
      font.bold: true
      font.pointSize: 14.0
      text: System.getTxSenderTokenAmount()
    }

    Text {
      id: balanceTokenType
      anchors {
        top: balanceCoinText.bottom
        right: parent.right
        margins: 10
      }
      font.pointSize: 14.0
      text: System.getCurrentToken()
    }

    Text {
      id: balanceLPFreeText
      anchors {
        top: balanceTokenText.bottom
        left: parent.left
        margins: 10
      }
      font.bold: true
      font.pointSize: 14.0
      text: System.getTxSenderLPFreeAmount()
    }

    Text {
      id: balanceLPFreeType
      anchors {
        top: balanceTokenText.bottom
        right: parent.right
        margins: 10
      }
      font.pointSize: 14.0
      text: "LP (Free)"
    }

    Text {
      id: balanceLPLockedText
      anchors {
        top: balanceLPFreeText.bottom
        left: parent.left
        margins: 10
      }
      font.bold: true
      font.pointSize: 14.0
      text: System.getTxSenderLPLockedAmount()
    }

    Text {
      id: balanceLPLockedType
      anchors {
        top: balanceLPFreeText.bottom
        right: parent.right
        margins: 10
      }
      font.pointSize: 14.0
      text: "LP (Locked)"
    }

    AVMEButton {
      id: btnSendCoinTx
      anchors {
        bottom: parent.bottom
        left: parent.left
        margins: 10
      }
      width: (parent.width / 4) - anchors.margins
      text: "Send " + System.getCurrentCoin()
      onClicked: {
        System.setTxTokenFlag(false)
        System.setScreen(content, "qml/screens/CoinTransactionScreen.qml")
      }
    }
    AVMEButton {
      id: btnSendTokenTx
      anchors {
        bottom: parent.bottom
        left: btnSendCoinTx.right
        margins: 10
      }
      width: (parent.width / 4) - anchors.margins
      text: "Send " + System.getCurrentToken()
      onClicked: {
        System.setTxTokenFlag(true)
        System.setScreen(content, "qml/screens/TokenTransactionScreen.qml")
      }
    }
    AVMEButton {
      id: btnStaking
      anchors {
        bottom: parent.bottom
        left: btnSendTokenTx.right
        margins: 10
      }
      width: (parent.width / 4) - anchors.margins
      text: "Staking"
      onClicked: System.setScreen(content, "qml/screens/StakingScreen.qml")
    }
    AVMEButton {
      id: btnViewKey
      anchors {
        bottom: parent.bottom
        left: btnStaking.right
        right: parent.right
        margins: 10
      }
      width: (parent.width / 4) - anchors.margins
      text: "View Private Key"
      onClicked: {
        viewPrivKeyPopup.account = System.getTxSenderAccount()
        viewPrivKeyPopup.open()
      }
    }
  }

  // Transaction details (bottom right)
  Rectangle {
    id: txDetailsRect
    height: (parent.height * 0.45)
    anchors {
      top: statsRect.bottom
      left: listRect.right
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
    radius: 5
    color: "#CC9A4FAD"

    Text {
      id: detailsTitle
      anchors {
        top: parent.top
        horizontalCenter: parent.horizontalCenter
        margins: 10
      }
      text: "Transaction Details"
    }

    Text {
      id: detailsText
      anchors {
        top: detailsTitle.bottom
        left: parent.left
        right: parent.right
        margins: 10
      }
      font.pointSize: 14.0
      elide: Text.ElideRight
      text: "<b>Operation:</b> " + historyList.currentItem.itemOperation + "<br>"
      + "<b>From:</b> " + historyList.currentItem.itemFrom + "<br>"
      + "<b>To:</b> " + historyList.currentItem.itemTo + "<br>"
      + "<b>Value:</b> " + historyList.currentItem.itemValue + "<br>"
      + "<b>Gas:</b> " + historyList.currentItem.itemGas + "<br>"
      + "<b>Price:</b> " + historyList.currentItem.itemPrice + "<br>"
      + "<b>Timestamp:</b> " + historyList.currentItem.itemDateTime + "<br>"
      + "<b>Confirmed:</b> " + historyList.currentItem.itemConfirmed
    }

    AVMEButton {
      id: btnOpenLink
      anchors {
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: 10
      }
      text: "Open Transaction in Block Explorer"
      onClicked: Qt.openUrlExternally(historyList.currentItem.itemTxLink)
    }
  }

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
}

























/*
Item {
  id: statsScreen

  Column {
    id: items
    anchors.fill: parent
    spacing: 20
    topPadding: 20

    Text {
      id: info
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      text: "Transaction history for the Account<br><b>" + System.getTxSenderAccount() + "</b>"
      font.pointSize: 18.0
    }

    // Transaction list
    Rectangle {
      id: historyListRect
      width: parent.width - parent.spacing
      height: parent.height * 0.75
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.margins: parent.spacing
      radius: 5
      color: "#4458A0C9"

      AVMETxHistoryList {
        id: historyList
        anchors.fill: parent
        // TODO: fill with real data later
        model: ListModel {
          id: historyModel
          ListElement {
            txlink: "https://explorer.avax.network/"
            to: "0x1234567890123456789012345678901234567890"
            from: "0x9876543210987654321098765432109876543210"
            value: "11111.123456789123456789"
            gas: "240"
            price: "21000"
            datetime: "01/01/1970 00:00:00"
            operation: "Send AVAX"
            confirmed: true
          }
          ListElement {
            txlink: "https://etherscan.io/"
            to: "0x1234567890123456789012345678901234567890"
            from: "0x9876543210987654321098765432109876543210"
            value: "99999.987654321987654321"
            gas: "240"
            price: "21000"
            datetime: "02/02/1970 00:00:00"
            operation: "Unlock AVAX/AVME"
            confirmed: false
          }
        }
      }
    }

    // Buttons
    Row {
      id: btnRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btnDetails
        width: items.width / 4
        text: "See Tx Details"
        onClicked: txDetailsPopup.open()
      }
      AVMEButton {
        id: btnLink
        width: items.width / 4
        text: "Open Tx in Explorer"
        onClicked: Qt.openUrlExternally(historyList.currentItem.itemTxLink)
      }
      AVMEButton {
        id: btnBack
        width: items.width / 4
        text: "Back to Accounts"
        onClicked: System.setScreen(content, "qml/screens/AccountsScreen.qml")
      }
    }
  }

  // Popup for showing transaction details
  Popup {
    id: txDetailsPopup
    width: window.width * 0.75
    height: window.height * 0.75
    x: (window.width / 2) - (width / 2)
    y: (window.height / 2) - (height / 2)
    modal: true
    focus: true
    padding: 0  // Remove white borders
    closePolicy: Popup.NoAutoClose

    Rectangle {
      anchors.fill: parent
      color: "#9A4FAD"

      Text {
        id: stats
        anchors.fill: parent
        anchors.margins: 20
        elide: Text.ElideRight
        text: "<b>Operation:</b><br>" + historyList.currentItem.itemOperation + "<br><br>"
        + "<b>From:</b><br>" + historyList.currentItem.itemFrom + "<br><br>"
        + "<b>To:</b><br>" + historyList.currentItem.itemTo + "<br><br>"
        + "<b>Value:</b><br>" + historyList.currentItem.itemValue + "<br><br>"
        + "<b>Gas:</b><br>" + historyList.currentItem.itemGas + "<br><br>"
        + "<b>Price:</b><br>" + historyList.currentItem.itemPrice + "<br><br>"
        + "<b>Timestamp:</b><br>" + historyList.currentItem.itemDateTime + "<br><br>"
        + "<b>Confirmed:</b><br>" + historyList.currentItem.itemConfirmed
      }

      AVMEButton {
        id: btnOk
        anchors {
          horizontalCenter: parent.horizontalCenter
          bottom: parent.bottom
          bottomMargin: 20
        }
        text: "OK"
        onClicked: txDetailsPopup.close()
      }
    }
  }
}
*/

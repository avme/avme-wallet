import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Screen for sending/receiving transactions.

Item {
  id: transactionScreen
  property string txTotalCoinStr
  property string txTotalTokenStr
  property string txTotalLPStr
  property string txOperationStr
  property string txReceiverAccountStr
  property string txAmountCoinStr
  property string txAmountTokenStr
  property string txAmountLPStr
  property string txGasLimitStr
  property string txGasPriceStr

  function updateTxCost() {
    txTotalCoinStr = System.calculateTransactionCost(
      txAmountCoinInput.text, txGasLimitInput.text, txGasPriceInput.text
    )
    txTotalTokenStr = System.calculateTransactionCost(
      txAmountTokenInput.text, "0", "0"
    )
    txTotalLPStr = System.calculateTransactionCost(
      txAmountLPInput.text, "0", "0"
    )
  }

  Component.onCompleted: {
    txGasPriceInput.text = System.getAutomaticFee()
    updateTxCost()
  }

  // Panel for the transaction inputs
  AVMEPanel {
    id: txDetailsPanel
    width: (parent.width * 0.5)
    anchors {
      left: parent.left
      top: parent.top
      bottom: parent.bottom
      margins: 10
    }
    title: "Transaction Details"

    Column {
      id: txDetailsColumn
      anchors {
        top: parent.header.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: 20
      }
      spacing: 40

      Text {
        id: txOperation
        verticalAlignment: Text.AlignVCenter
        width: (txDetailsColumn.width * 0.2)
        color: "#FFFFFF"
        text: "Operation:"

        ComboBox {
          id: txOperationSelector
          width: (txDetailsColumn.width * 0.4)
          anchors {
            left: parent.right
            verticalCenter: parent.verticalCenter
          }
          model: [
            "Send AVAX", "Send AVME",
            "Approve Exchange", "Approve Liquidity", "Approve Staking",
            "Swap AVAX -> AVME", "Swap AVME -> AVAX",
            "Add Liquidity", "Remove Liquidity",
            "Stake LP", "Unstake LP", "Harvest AVME", "Exit Staking"
          ]
          onActivated: txOperationStr = txOperationSelector.currentText
          Component.onCompleted: txOperationStr = txOperationSelector.currentText
        }
      }

      AVMEInput {
        id: txFromInput
        anchors.left: parent.left
        width: (txDetailsColumn.width * 0.8)
        readOnly: true
        label: "From"
        text: System.getTxSenderAccount()

        AVMEButton {
          id: btnCopyToClipboard
          width: (txDetailsColumn.width * 0.2) - anchors.leftMargin
          anchors {
            left: parent.right
            leftMargin: 10
          }
          enabled: (!btnClipboardTimer.running)
          text: (enabled) ? "Copy" : "Copied!"
          Timer { id: btnClipboardTimer; interval: 2000 }
          onClicked: {
            System.copyToClipboard(System.getTxSenderAccount())
            btnClipboardTimer.start()
          }
        }
      }

      AVMEInput {
        id: txToInput
        width: txDetailsColumn.width
        validator: RegExpValidator { regExp: /0x[0-9a-fA-F]{40}/ }
        label: "To"
        placeholder: "Receiver address - e.g. 0x123456789ABCDEF..."
        onTextEdited: txReceiverAccountStr = txToInput.text
      }

      // TODO: clean+disable depending on operation
      AVMEInput {
        id: txAmountCoinInput
        width: (txDetailsColumn.width * 0.8)
        validator: RegExpValidator { regExp: System.createCoinRegExp() }
        label: System.getCurrentCoin() + " Amount"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: {
          txAmountCoinStr = txAmountCoinInput.text
          updateTxCost()
        }

        AVMEButton {
          id: btnAmountCoinMax
          width: (txDetailsColumn.width * 0.2) - anchors.leftMargin
          anchors {
            left: parent.right
            leftMargin: 10
          }
          text: "Max"
          onClicked: {
            // TODO: take gas limit and price into consideration
            var acc = System.getAccountBalances(System.getTxSenderAccount())
            txAmountCoinInput.text = acc.balanceAVAX
            txAmountCoinStr = txAmountCoinInput.text
            updateTxCost()
          }
        }
      }

      // TODO: clean+disable depending on operation
      AVMEInput {
        id: txAmountTokenInput
        width: (txDetailsColumn.width * 0.8)
        validator: RegExpValidator { regExp: System.createTokenRegExp() }
        label: System.getCurrentToken() + " Amount"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: {
          txAmountTokenStr = txAmountTokenInput.text
          updateTxCost()
        }

        AVMEButton {
          id: btnAmountTokenMax
          width: (txDetailsColumn.width * 0.2) - anchors.leftMargin
          anchors {
            left: parent.right
            leftMargin: 10
          }
          text: "Max"
          onClicked: {
            // TODO: take gas limit and price into consideration
            var acc = System.getAccountBalances(System.getTxSenderAccount())
            txAmountTokenInput.text = acc.balanceAVME
            txAmountTokenStr = txAmountTokenInput.text
            updateTxCost()
          }
        }
      }

      // TODO: clean+disable depending on operation
      AVMEInput {
        id: txAmountLPInput
        width: (txDetailsColumn.width * 0.8)
        validator: RegExpValidator { regExp: System.createCoinRegExp() }  // TODO: make this right later
        label: "LP Amount"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: {
          txAmountLPStr = txAmountLPInput.text
          updateTxCost()
        }

        AVMEButton {
          id: btnAmountLPMax
          width: (txDetailsColumn.width * 0.2) - anchors.leftMargin
          anchors {
            left: parent.right
            leftMargin: 10
          }
          text: "Max"
          onClicked: {
            // TODO: take gas limit, price and locked LP into consideration
            var acc = System.getAccountBalances(System.getTxSenderAccount())
            txAmountLPInput.text = acc.balanceLPFree
            txAmountLPStr = txAmountLPInput.text
            updateTxCost()
          }
        }
      }

      Row {
        width: parent.width
        spacing: 10

        AVMEInput {
          id: txGasLimitInput
          width: (txDetailsColumn.width * 0.5)
          validator: RegExpValidator { regExp: /[0-9]+/ }
          label: "Gas Limit (in Wei)"
          text: "21000" // TODO: change according to operation
          enabled: !autoLimitCheck.checked
          onTextEdited: {
            txGasLimitStr = txGasLimitInput.text
            updateTxCost()
          }
          Component.onCompleted: txGasLimitStr = txGasLimitInput.text
        }

        CheckBox {
          id: autoLimitCheck
          property string prev
          width: (txDetailsColumn.width * 0.5) - anchors.leftMargin
          checked: true
          enabled: true
          text: "Automatic Limit"
          contentItem: Text {
            text: parent.text
            font: parent.font
            color: parent.checked ? "#FFFFFF" : "#888888"
            verticalAlignment: Text.AlignVCenter
            leftPadding: parent.indicator.width + parent.spacing
          }
          onClicked: {
            if (!txGasLimitInput.enabled) {
              // Disabled field (auto limit on)
              txGasLimitInput.text = prev
              prev = ""
            } else {
              // Enabled field (auto limit off)
              prev = txGasLimitInput.text
              txGasLimitInput.text = ""
            }
            txGasLimitStr = txGasLimitInput.text
            updateTxCost()
          }
        }
      }

      Row {
        width: parent.width
        spacing: 10

        AVMEInput {
          id: txGasPriceInput
          width: (txDetailsColumn.width * 0.5)
          validator: RegExpValidator { regExp: /[0-9]+/ }
          enabled: !autoGasCheck.checked
          label: "Gas Price (in Gwei)"
          onTextEdited: {
            txGasPriceStr = txGasPriceInput.text
            updateTxCost()
          }
          Component.onCompleted: txGasPriceStr = txGasPriceInput.text
        }

        CheckBox {
          id: autoGasCheck
          property string prev
          width: (txDetailsColumn.width * 0.5) - anchors.leftMargin
          checked: true
          enabled: true
          text: "Recommended Fee"
          contentItem: Text {
            text: parent.text
            font: parent.font
            color: parent.checked ? "#FFFFFF" : "#888888"
            verticalAlignment: Text.AlignVCenter
            leftPadding: parent.indicator.width + parent.spacing
          }
          onClicked: {
            if (!txGasPriceInput.enabled) {
              // Disabled field (auto fee on)
              txGasPriceInput.text = prev
              prev = ""
            } else {
              // Enabled field (auto fee off)
              prev = txGasPriceInput.text
              txGasPriceInput.text = ""
            }
            txGasPriceStr = txGasPriceInput.text
            updateTxCost()
          }
        }
      }
    }
  }

  // Panel for the summary and auth
  AVMEPanel {
    id: txSummaryPanel
    width: (parent.width * 0.5)
    anchors {
      right: parent.right
      top: parent.top
      bottom: parent.bottom
      margins: 10
    }
    title: "Transaction Summary"

    Column {
      id: txSummaryColumn
      anchors {
        top: parent.header.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: 20
      }
      spacing: 20

      Text {
        id: txSummaryOperationHeader
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        color: "#FFFFFF"
        text: "You will"
      }

      Text {
        id: txSummaryOperation
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        color: "#FFFFFF"
        font.pointSize: 18.0
        font.bold: true
        text: txOperationStr
      }

      Text {
        id: txSummaryOperationFooter
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        color: "#FFFFFF"
        text: {
          switch (txOperationStr) {
            case "Send AVAX":
            case "Send AVME":
              text: "to the address<br><b>" + txReceiverAccountStr + "</b>"
              break;
            case "Approve Exchange":
              text: "(give approval to Pangolin to use your Account's"
              + "<br>currencies for exchanging/swapping between each other)";
              break;
            case "Approve Liquidity":
              text: "(give approval to Pangolin to use your Account's"
              + "<br>currencies for managing pool liquidity)";
              break;
            case "Approve Staking":
              text: "(give approval to the staking contract to use your"
              + "<br>Account's currencies for staking and harvesting rewards)";
              break;
            case "Swap AVAX -> AVME":
            case "Swap AVME -> AVAX":
              text: "via Pangolin";
              break;
            case "Add Liquidity":
              text: "to the " + System.getCurrentCoin() + "/" + System.getCurrentToken() + " pool";
              break;
            case "Remove Liquidity":
              text: "from the " + System.getCurrentCoin() + "/" + System.getCurrentToken() + " pool";
              break;
            case "Stake LP":
              text: "in the staking contract";
              break;
            case "Unstake LP":
            case "Harvest AVME":
              text: "from the staking contract";
              break;
            case "Exit Staking":
              text: "(harvest all of the available reward and unstake"
              + "<br>all of the LP tokens from the staking contract)";
              break;
          }
        }
      }

      Text {
        id: txSummaryAmountsHeader
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        color: "#FFFFFF"
        text: {
          switch (txOperationStr) {
            case "Send AVAX":
            case "Send AVME":
              text: "Costs for the transaction:"
              break;
            case "Approve Exchange":
            case "Approve Liquidity":
            case "Approve Staking":
              text: "Costs for the approval:"
              break;
            case "Swap AVAX -> AVME":
            case "Swap AVME -> AVAX":
            case "Add Liquidity":
            case "Remove Liquidity":
              text: "Expecting to pay/receive:";
              break;
            case "Stake LP":
              text: "Expecting to pay:";
              break;
            case "Unstake LP":
            case "Harvest AVME":
            case "Exit Staking":
              text: "Expecting to receive:";
              break;
          }
        }
      }

      Text {
        id: txSummaryAmounts
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        font.bold: true
        color: "#FFFFFF"
        text: {
          switch (txOperationStr) {
            case "Send AVAX":
            case "Swap AVAX -> AVME":
              text: txAmountCoinStr + " " + System.getCurrentCoin()
              + "<br>Gas Limit: " + System.weiToFixedPoint(txGasLimitStr, 18)
              + " " + System.getCurrentCoin()
              + "<br>Gas Price: " + System.weiToFixedPoint(txGasPriceStr, 9)
              + " " + System.getCurrentCoin();
              break;
            case "Send AVME":
            case "Swap AVME -> AVAX":
              text: txAmountTokenStr + " " + System.getCurrentToken()
              + "<br>Gas Limit: " + System.weiToFixedPoint(txGasLimitStr, 18)
              + " " + System.getCurrentCoin()
              + "<br>Gas Price: " + System.weiToFixedPoint(txGasPriceStr, 9)
              + " " + System.getCurrentCoin();
              break;
            case "Approve Exchange":
            case "Approve Liquidity":
            case "Approve Staking":
            case "Harvest AVME":
            case "Exit Staking":
              text: "Gas Limit: " + System.weiToFixedPoint(txGasLimitStr, 18)
              + " " + System.getCurrentCoin()
              + "<br>Gas Price: " + System.weiToFixedPoint(txGasPriceStr, 9)
              + " " + System.getCurrentCoin();
              break;
            case "Add Liquidity":
              text: txAmountCoinStr + " " + System.getCurrentCoin()
              + "<br>" + txAmountTokenStr + " " + System.getCurrentToken()
              + "<br>Gas Limit: " + System.weiToFixedPoint(txGasLimitStr, 18)
              + " " + System.getCurrentCoin()
              + "<br>Gas Price: " + System.weiToFixedPoint(txGasPriceStr, 9)
              + " " + System.getCurrentCoin();
              break;
            case "Remove Liquidity":
            case "Stake LP":
            case "Unstake LP":
              text: txAmountLPStr + " LP"
              + "<br>Gas Limit: " + System.weiToFixedPoint(txGasLimitStr, 18)
              + " " + System.getCurrentCoin()
              + "<br>Gas Price: " + System.weiToFixedPoint(txGasPriceStr, 9)
              + " " + System.getCurrentCoin();
              break;
          }
        }
      }

      Text {
        id: txTotalCostsHeader
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        color: "#FFFFFF"
        text: "Total costs to make the transaction:"
      }

      Text {
        id: txTotalCosts
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        font.bold: true
        color: "#FFFFFF"
        text: {
          switch (txOperationStr) {
            case "Send AVAX":
            case "Approve Exchange":
            case "Approve Liquidity":
            case "Approve Staking":
            case "Swap AVAX -> AVME":
            case "Harvest AVME":
            case "Exit Staking":
              text: txTotalCoinStr + " " + System.getCurrentCoin();
              break;
            case "Send AVME":
            case "Swap AVME -> AVAX":
            case "Add Liquidity":
              text: txTotalCoinStr + " " + System.getCurrentCoin()
              + "<br>" + txTotalTokenStr + " " + System.getCurrentToken();
              break;
            case "Remove Liquidity":
            case "Stake LP":
            case "Unstake LP":
              text: txTotalCoinStr + " " + System.getCurrentCoin()
              + "<br>" + txTotalLPStr + " LP";
              break;
          }
        }
      }

      Text {
        id: txPass
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        color: "#FFFFFF"
        text: "Enter your passphrase to confirm the transaction."
      }

      AVMEInput {
        id: txPassInput
        width: (txDetailsColumn.width * 0.5)
        anchors.horizontalCenter: parent.horizontalCenter
        echoMode: TextInput.Password
        passwordCharacter: "*"
        placeholder: "Your Wallet's passphrase"
      }

      AVMEButton {
        id: btnMakeTx
        width: (txDetailsColumn.width * 0.5)
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Make Transaction"
        onClicked: {} // TODO
      }
    }
  }
}

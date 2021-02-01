import QtQuick 2.9
import QtQuick.Controls 2.2

import "../components"

Item {
  AVMEWalletList {
    id: walletList
    height: 670
    anchors.fill: parent
    anchors.bottomMargin: 50
    boundsBehavior: Flickable.StopAtBounds
    model: listModel
  }

  // Test model for the list
  ListModel {
    id: listModel
    ListElement { account: "0x0000000000000000000000000000000000000000"; eth: "0.123456789123456789"; taex: "0.1234" }
    ListElement { account: "0x1111111111111111111111111111111111111111"; eth: "0.123456789123456789"; taex: "0.1234" }
    ListElement { account: "0x2222222222222222222222222222222222222222"; eth: "0.123456789123456789"; taex: "0.1234" }
    ListElement { account: "0x3333333333333333333333333333333333333333"; eth: "0.123456789123456789"; taex: "0.1234" }
    ListElement { account: "0x4444444444444444444444444444444444444444"; eth: "0.123456789123456789"; taex: "0.1234" }
    ListElement { account: "0x5555555555555555555555555555555555555555"; eth: "0.123456789123456789"; taex: "0.1234" }
    ListElement { account: "0x6666666666666666666666666666666666666666"; eth: "0.123456789123456789"; taex: "0.1234" }
    ListElement { account: "0x7777777777777777777777777777777777777777"; eth: "0.123456789123456789"; taex: "0.1234" }
    ListElement { account: "0x8888888888888888888888888888888888888888"; eth: "0.123456789123456789"; taex: "0.1234" }
    ListElement { account: "0x9999999999999999999999999999999999999999"; eth: "0.123456789123456789"; taex: "0.1234" }
    ListElement { account: "0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"; eth: "0.123456789123456789"; taex: "0.1234" }
    ListElement { account: "0xBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"; eth: "0.123456789123456789"; taex: "0.1234" }
    ListElement { account: "0xCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"; eth: "0.123456789123456789"; taex: "0.1234" }
    ListElement { account: "0xDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD"; eth: "0.123456789123456789"; taex: "0.1234" }
    ListElement { account: "0xEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"; eth: "0.123456789123456789"; taex: "0.1234" }
    ListElement { account: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"; eth: "0.123456789123456789"; taex: "0.1234" }
  }

  Row {
    id: buttons
    height: 50
    spacing: 5
    anchors {
      top: walletList.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
    }

    AVMEButton {
      id: btnSendETH
      width: (parent.width / 4) - parent.spacing
      text: "Send ETH from this Account"
    }

    AVMEButton {
      id: btnSendTAEX
      width: (parent.width / 4) - parent.spacing
      text: "Send TAEX from this Account"
    }

    AVMEButton {
      id: btnNewAccount
      width: (parent.width / 4) - parent.spacing
      text: "Create a new Account"
    }

    AVMEButton {
      id: btnEraseAccount
      width: (parent.width / 4) - parent.spacing
      text: "Erase this Account"
    }
  }
}

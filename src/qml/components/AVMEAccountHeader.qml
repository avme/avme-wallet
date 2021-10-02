/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/popups"

/**
 * Header that shows the current Account and stores details about it
 * (e.g. balances, QR code, buttons for changing Account/Wallet, etc.)
 */
//Rectangle {
Item {
  id: accountHeader
  property string currentAddress
  property string coinRawBalance
  property string coinFiatValue
  property string coinUSDPrice
  property string coinUSDPriceChart
  property string totalFiatBalance
  property string accountNonce
  property string gasPrice
  property string website
  property bool isLedger: qmlSystem.getLedgerFlag()
  property var tokenList: ({})

  //height: 50
  //radius: 10
  //color: "transparent"
  signal updatedBalances()

  Timer { id: addressTimer; interval: 1000 }
  Timer { id: balancesTimer; interval: 1000; repeat: true; onTriggered: refreshBalances() }
  // TODO: Remove all "useless" ledger calls
  Timer { id: ledgerRetryTimer; interval: 250; onTriggered: checkLedger() }

  Connections {
    target: qmlSystem
    function onAccountAllBalancesUpdated(address, tokenJsonListStr, coinInformationJsonStr, gasPriceStr) {
      var coinInformation = JSON.parse(coinInformationJsonStr)
      coinRawBalance = coinInformation["coinBalance"]
      coinFiatValue = coinInformation["coinFiatBalance"]
      coinUSDPrice = coinInformation["coinFiatPrice"]
      coinUSDPriceChart = coinInformation["coinPriceChart"]

      totalFiatBalance = coinInformation["coinFiatBalance"]
      tokenList = ({})
      if (address == currentAddress) {
        var tokenJsonList = JSON.parse(tokenJsonListStr)
        for (var i = 0; i < tokenJsonList.length; ++i) {
          var tokenInformation = ({})
          tokenInformation["rawBalance"] = tokenJsonList[i]["tokenRawBalance"]
          tokenInformation["fiatValue"] = tokenJsonList[i]["tokenFiatValue"]
          tokenInformation["derivedValue"] = tokenJsonList[i]["tokenDerivedValue"]
          tokenInformation["symbol"] = tokenJsonList[i]["tokenSymbol"]
          tokenInformation["coinWorth"] = tokenJsonList[i]["coinWorth"]
          tokenInformation["chartData"] = tokenJsonList[i]["tokenChartData"]
          tokenInformation["USDprice"] = tokenJsonList[i]["tokenUSDPrice"]
          tokenInformation["decimals"] = tokenJsonList[i]["tokenDecimals"]
          tokenInformation["name"] = tokenJsonList[i]["tokenName"]
          tokenList[tokenJsonList[i]["tokenAddress"]] = tokenInformation
          // Use only two digits precision.
          totalFiatBalance = Math.round((+totalFiatBalance + +tokenInformation["fiatValue"]) * 100) / 100
        }
        gasPrice = String(Math.round(+gasPriceStr))
        updatedBalances()
      }
    }
    function onAskForPermission(website_) {
      website = website_
      confirmWebsiteAllowance.open()
      window.requestActivate()
    }
    function onAskForTransaction(data,from,gas,to,value,website_) {
      confirmRT.setData(
        to,
        qmlApi.weiToFixedPoint(qmlApi.parseHex(value,["uint"]),18),
        data,
        qmlApi.parseHex(gas,["uint"]),
        +gasPrice + 20,
        true,
        "The following website is requesting a transaction: <b> " + website_ + "</b>" +
        "<br>Total Value: <b>" + qmlApi.weiToFixedPoint(qmlApi.parseHex(value,["uint"]),18) + "</b>",
        "Tx from: <b> " + website_ + "</b>"
        )
      confirmRT.open()
      window.requestActivate()
    }
    function onAccountNonceUpdate(nonce) { accountNonce = nonce }
  }

  // TODO: find a way to remove this
  function getAddress() {
    currentAddress = qmlSystem.getCurrentAccount()
    refreshBalances()
    balancesTimer.start()
  }

  function refreshBalances() {
    qmlSystem.getAccountAllBalances(currentAddress)
  }

  function checkLedger() {
    var data = qmlSystem.checkForLedger()
    if (data.state) {
      ledgerFailPopup.close()
      ledgerRetryTimer.stop()
    } else {
      ledgerFailPopup.info = data.message
      ledgerRetryTimer.start()
    }
  }

  // TODO: remove those and migrate their actions somewhere else
  /*
  AVMEButton {
    id: btnChangeAccount
    width: parent.width * 0.15
    anchors {
      verticalCenter: parent.verticalCenter
      right: btnChangeWallet.left
      rightMargin: 10
    }
    text: "Change Account"
    onClicked: {
      qmlSystem.setLedgerFlag(false)
      qmlSystem.hideMenu()
      qmlSystem.cleanAndCloseAccount()
      qmlSystem.setScreen(content, "qml/screens/AccountsScreen.qml")
    }
  }

  AVMEButton {
    id: btnChangeWallet
    width: parent.width * 0.15
    anchors {
      verticalCenter: parent.verticalCenter
      right: parent.right
      rightMargin: 10
    }
    text: "Change Wallet"
    onClicked: {
      qmlSystem.setLedgerFlag(false)
      qmlSystem.deleteLastWalletPath()
      qmlSystem.hideMenu()
      qmlSystem.cleanAndClose()
      qmlSystem.setScreen(content, "qml/screens/StartScreen.qml")
    }
  }
  */

  // Popup for Ledger accounts
  AVMEPopupLedger {
    id: ledgerPopup
  }

  // Info popup for if communication with Ledger fails
  AVMEPopupInfo {
    id: ledgerFailPopup
    icon: "qrc:/img/warn.png"
    onAboutToHide: ledgerRetryTimer.stop()
    okBtn.text: "Close"
  }

  AVMEPopup {
    id: confirmWebsiteAllowance
    width: parent.width * 0.66
    height: parent.width * 0.1
    z: 9999
    Column {
      id: confirmWebsiteAllowanceColumn
      anchors.centerIn: parent
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width
      height: parent.height * 0.9
      spacing: 30
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        id: websiteText
        color: "#FFFFFF"
        font.pixelSize: 17.0
        text: "Allow <b>" + website + "</b> to connect?"
      }
      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: confirmWebsiteAllowanceColumn.width * 0.1
        AVMEButton {
          id: refuseWebsiteBtn
          width: confirmWebsiteAllowanceColumn.width * 0.4
          text: "No"
          onClicked: {
            qmlSystem.addToPermissionList(website, false)
            confirmWebsiteAllowance.close()
          }
        }
        AVMEButton {
          id: approveWebsiteBtn
          width: confirmWebsiteAllowanceColumn.width * 0.4
          text: "Yes"
          onClicked: {
            qmlSystem.addToPermissionList(website, true)
            confirmWebsiteAllowance.close()
          }
        }
      }
    }
  }

  AVMEPopupConfirmTx {
    id: confirmRT
    backBtn.onClicked: {
      confirmRT.close()
      qmlSystem.requestedTransactionStatus(false, "")
    }
  }

  AVMEPopupTxProgress {
    id: txProgressPopup
    requestedFromWS: true
  }
}

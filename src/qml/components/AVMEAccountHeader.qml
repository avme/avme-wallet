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
Rectangle {
  id: accountHeader
  property string currentAddress
  property string coinRawBalance
  property string coinFiatValue
  property string coinUSDPrice
  property string coinUSDPriceChart
  property string totalFiatBalance
  property string gasPrice
  property string website
  property bool isLedger: qmlSystem.getLedgerFlag()
  property var tokenList: ({})

  height: 50
  radius: 10
  color: "transparent"
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
  }
  Connections {
    target: qmlSystem
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
        "The following website is requesting a transaction: <b> " + website_ + "</b>", 
        "Tx from: <b> " + website_ + "</b>"
        ) 
      confirmRT.open()
      window.requestActivate()
    }
  }

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

  function qrEncode() {
    qrcodePopup.qrModel.clear()
    var qrData = qmlSystem.getQRCodeFromAddress(currentAddress)
    for (var i = 0; i < qrData.length; i++) {
      qrcodePopup.qrModel.set(i, JSON.parse(qrData[i]))
    }
  }

  Rectangle {
    id: qrCodeRect
    anchors {
      top: parent.top
      left: parent.left
      leftMargin: 10
      verticalCenter: parent.verticalCenter
    }
    color: "transparent"
    radius: 5
    height: addressText.height
    width: height

    Image {
      id: qrCodeImage
      anchors.centerIn: parent
      height: parent.height * 0.8
      width: parent.width * 0.8
      fillMode: Image.PreserveAspectFit
      antialiasing: true
      smooth: true
      source: "qrc:/img/icons/qrcode.png"
    }
    MouseArea {
      id: qrCodeMouseArea
      anchors.fill: parent
      hoverEnabled: true
      onEntered: {
        parent.color = "#3F434C"
        qrCodeImage.source = "qrc:/img/icons/qrcodeSelect.png"
      }
      onExited: {
        parent.color = "transparent"
        qrCodeImage.source = "qrc:/img/icons/qrcode.png"
      }
      onClicked: {
        qrEncode()
        qrcodePopup.open()
      }
    }
  }

  Rectangle {
    id: copyClipRect
    anchors {
      top: parent.top
      left: qrCodeRect.right
      leftMargin: 10
      verticalCenter: parent.verticalCenter
    }
    enabled: (!addressTimer.running)
    color: "transparent"
    radius: 5
    height: addressText.height
    width: height

    Image {
      id: copyClipImage
      anchors.centerIn: parent
      height: parent.height * 0.8
      width: parent.width * 0.8
      fillMode: Image.PreserveAspectFit
      antialiasing: true
      smooth: true
      source: "qrc:/img/icons/Icon_Clipboard.png"
    }
    MouseArea {
      id: copyClipMouseArea
      anchors.fill: parent
      hoverEnabled: true
      onEntered: {
        parent.color = "#3F434C"
        copyClipImage.source = "qrc:/img/icons/Icon_Clipboard_On.png"
      }
      onExited: {
        parent.color = "transparent"
        copyClipImage.source = "qrc:/img/icons/Icon_Clipboard.png"
      }
      onClicked: {
        qmlSystem.copyToClipboard(currentAddress)
        addressTimer.start()
      }
    }
  }

  Text {
    id: addressText
    anchors {
      verticalCenter: parent.verticalCenter
      left: copyClipRect.right
      leftMargin: 10
    }
    color: "#FFFFFF"
    text: (!addressTimer.running) ? currentAddress : "Copied to clipboard!"
    font.bold: true
    font.pixelSize: 17.0

    Rectangle {
      id: addressRect
      anchors.fill: parent
      anchors.margins: -10
      color: "transparent"
      z: parent.z - 1
      radius: 5
      MouseArea {
        id: addressMouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: (!addressTimer.running)
        onEntered: parent.color = "#3F434C"
        onExited: parent.color = "transparent"
        onClicked: {
          parent.color = "transparent"
          qmlSystem.copyToClipboard(currentAddress)
          addressTimer.start()
        }
      }
    }
  }

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
      qmlSystem.hideMenu()
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
      qmlSystem.hideMenu()
      qmlSystem.cleanAndClose()
      qmlSystem.setScreen(content, "qml/screens/StartScreen.qml")
    }
  }

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

  // "qrcodeWidth = 0" makes the program not even open, so leave it at 1
  AVMEPopupQRCode {
    id: qrcodePopup
    qrcodeWidth: (currentAddress != "") ? qmlSystem.getQRCodeSize(currentAddress) : 1
    textAddress.text: currentAddress
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

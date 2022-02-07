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
  property string accountNonce
  property string gasPrice
  property string website
  property bool isLedger
  property int assetCt: 0
  property var tokenList: ({})
  width: 750
  height: 48
  color: "#1C2029"
  radius: 5

  signal updatedBalances()

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
          tokenInformation["fiatValue"] = +tokenJsonList[i]["tokenFiatValue"]
          tokenInformation["fiatValue"] = tokenInformation["fiatValue"].toFixed(2)
          tokenInformation["derivedValue"] = tokenJsonList[i]["tokenDerivedValue"]
          tokenInformation["symbol"] = tokenJsonList[i]["tokenSymbol"]
          tokenInformation["chartData"] = tokenJsonList[i]["tokenChartData"]
          tokenInformation["USDprice"] = tokenJsonList[i]["tokenUSDPrice"]
          tokenInformation["decimals"] = tokenJsonList[i]["tokenDecimals"]
          tokenInformation["name"] = tokenJsonList[i]["tokenName"]
          tokenList[tokenJsonList[i]["tokenAddress"]] = tokenInformation
          totalFiatBalance = (Math.round(
            (+totalFiatBalance + +tokenInformation["fiatValue"]) * 100
          ) / 100).toFixed(2) // Use only two digits precision for fiat
        }
        gasPrice = String(Math.round(+gasPriceStr))
        updatedBalances()
      }
    }
    function onAskForPermission(website_) {
      website = website_
      confirmWebsiteAllowance.open()
      qmlSystem.bringAppToFront()
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
      qmlSystem.bringAppToFront()
    }
    function onAskForSign(address, message, _website, requestType) {
      confirmSign.setData(address, message, requestType)
      confirmSign.open()
      qmlSystem.bringAppToFront()
    }
    function onAccountNonceUpdate(nonce) { accountNonce = nonce }
    function onLedgerFlagSet(_isLedger) { isLedger = _isLedger }
  }

  function qrEncode() {
    qrcodePopup.qrModel.clear()
    var qrData = qmlSystem.getQRCodeFromAddress(currentAddress)
    for (var i = 0; i < qrData.length; i++) {
      qrcodePopup.qrModel.set(i, JSON.parse(qrData[i]))
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

  Rectangle {
    id: copyClipRect
    property alias timer: addressTimer
    enabled: (!addressTimer.running)
    visible: (currentAddress != "")
    color: "transparent"
    radius: 5
    width: 32
    height: 32
    anchors {
      left: parent.left
      leftMargin: 10
      verticalCenter: parent.verticalCenter
    }
    Timer { id: addressTimer; interval: 1000 }
    ToolTip {
      id: copyClipTooltip
      parent: copyClipRect
      visible: (copyClipMouseArea.hovering || copyClipRect.timer.running)
      contentItem: Text {
        font.pixelSize: 12.0
        color: "#FFFFFF"
        text: (copyClipRect.timer.running) ? "Copied!" : "Copy to Clipboard"
      }
      background: Rectangle { color: "#1C2029" }
    }
    AVMEAsyncImage {
      id: copyClipImage
      width: parent.width
      height: parent.height
      loading: false
      anchors.centerIn: parent
      imageSource: "qrc:/img/icons/clipboard.png"
    }
    MouseArea {
      id: copyClipMouseArea
      property bool hovering
      anchors.fill: parent
      hoverEnabled: true
      onEntered: {
        copyClipImage.imageSource = "qrc:/img/icons/clipboardSelect.png"
        hovering = true
      }
      onExited: {
        copyClipImage.imageSource = "qrc:/img/icons/clipboard.png"
        hovering = false
      }
      onClicked: {
        qmlSystem.copyToClipboard(currentAddress)
        parent.timer.start()
      }
    }
  }

  Rectangle {
    id: qrCodeRect
    color: "transparent"
    radius: 5
    width: 32
    height: 32
    visible: (currentAddress != "")
    anchors {
      left: copyClipRect.right
      leftMargin: 10
      verticalCenter: parent.verticalCenter
    }
    ToolTip {
      id: qrCodeTooltip
      parent: qrCodeRect
      contentItem: Text {
        font.pixelSize: 12.0
        color: "#FFFFFF"
        text: "Show QR Code"
      }
      background: Rectangle { color: "#1C2029" }
    }
    AVMEAsyncImage {
      id: qrCodeImage
      width: parent.width
      height: parent.height
      loading: false
      anchors.centerIn: parent
      imageSource: "qrc:/img/icons/qrcode.png"
    }
    MouseArea {
      id: qrCodeMouseArea
      anchors.fill: parent
      hoverEnabled: true
      onEntered: {
        qrCodeImage.imageSource = "qrc:/img/icons/qrcodeSelect.png"
        qrCodeTooltip.visible = true
      }
      onExited: {
        qrCodeImage.imageSource = "qrc:/img/icons/qrcode.png"
        qrCodeTooltip.visible = false
      }
      onClicked: {
        qrEncode()
        qrcodePopup.open()
      }
    }
  }

  Text {
    id: account
    anchors.centerIn: parent
    color: "#FFFFFF"
    font.pixelSize: 18.0
    font.bold: true
    text: (currentAddress != "") ? currentAddress : "No account selected."
  }

  Rectangle {
    id: privKeyRect
    color: "transparent"
    radius: 5
    width: 32
    height: 32
    visible: (currentAddress != "" && !isLedger)
    anchors {
      right: seedRect.left
      rightMargin: 10
      verticalCenter: parent.verticalCenter
    }
    ToolTip {
      id: privKeyTooltip
      parent: privKeyRect
      contentItem: Text {
        font.pixelSize: 12.0
        color: "#FFFFFF"
        text: "Show Private Key"
      }
      background: Rectangle { color: "#1C2029" }
    }
    AVMEAsyncImage {
      id: privKeyImage
      width: parent.width
      height: parent.height
      loading: false
      anchors.centerIn: parent
      imageSource: "qrc:/img/icons/key-f.png"
    }
    MouseArea {
      id: privKeyMouseArea
      anchors.fill: parent
      hoverEnabled: true
      onEntered: {
        privKeyImage.imageSource = "qrc:/img/icons/key-fSelect.png"
        privKeyTooltip.visible = true
      }
      onExited: {
        privKeyImage.imageSource = "qrc:/img/icons/key-f.png"
        privKeyTooltip.visible = false
      }
      onClicked: viewPrivKeyPopup.open()
    }
  }

  Rectangle {
    id: seedRect
    color: "transparent"
    radius: 5
    width: 32
    height: 32
    visible: (currentAddress != "")
    anchors {
      right: websiteRect.left
      rightMargin: 10
      verticalCenter: parent.verticalCenter
    }
    ToolTip {
      id: seedTooltip
      parent: seedRect
      contentItem: Text {
        font.pixelSize: 12.0
        color: "#FFFFFF"
        text: "Show Wallet Seed"
      }
      background: Rectangle { color: "#1C2029" }
    }
    AVMEAsyncImage {
      id: seedImage
      width: parent.width
      height: parent.height
      loading: false
      anchors.centerIn: parent
      imageSource: "qrc:/img/icons/seed.png"
    }
    MouseArea {
      id: seedMouseArea
      anchors.fill: parent
      hoverEnabled: true
      onEntered: {
        seedImage.imageSource = "qrc:/img/icons/seedSelect.png"
        seedTooltip.visible = true
      }
      onExited: {
        seedImage.imageSource = "qrc:/img/icons/seed.png"
        seedTooltip.visible = false
      }
      onClicked: viewSeedPopup.open()
    }
  }

  Rectangle {
    id: websiteRect
    color: "transparent"
    radius: 5
    width: 32
    height: 32
    visible: (currentAddress != "")
    anchors {
      right: parent.right
      rightMargin: 10
      verticalCenter: parent.verticalCenter
    }
    ToolTip {
      id: websiteTooltip
      parent: websiteRect
      contentItem: Text {
        font.pixelSize: 12.0
        color: "#FFFFFF"
        text: "Show Website Permissions"
      }
      background: Rectangle { color: "#1C2029" }
    }
    AVMEAsyncImage {
      id: websiteImage
      width: parent.width
      height: parent.height
      loading: false
      anchors.centerIn: parent
      imageSource: "qrc:/img/icons/world.png"
    }
    MouseArea {
      id: websiteMouseArea
      anchors.fill: parent
      hoverEnabled: true
      onEntered: {
        websiteImage.imageSource = "qrc:/img/icons/worldSelect.png"
        websiteTooltip.visible = true
      }
      onExited: {
        websiteImage.imageSource = "qrc:/img/icons/world.png"
        websiteTooltip.visible = false
      }
      onClicked: viewWebsitePermissionPopup.open()
    }
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
    width: window.width * 0.66
    height: window.height * 0.2
    y: ((window.height / 2) - (height / 2))
    z: 9999
    onAboutToHide: qmlSystem.resetWindowFlags()
    Column {
      id: confirmWebsiteAllowanceColumn
      anchors.centerIn: parent
      width: parent.width
      spacing: 30
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        id: websiteText
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Allow <b>" + website + "</b> to connect?"
      }
      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: confirmWebsiteAllowanceColumn.width * 0.1
        AVMEButton {
          id: refuseWebsiteBtn
          width: confirmWebsiteAllowanceColumn.width * 0.25
          text: "No"
          onClicked: {
            qmlSystem.addToPermissionList(website, false)
            confirmWebsiteAllowance.close()
          }
        }
        AVMEButton {
          id: approveWebsiteBtn
          width: confirmWebsiteAllowanceColumn.width * 0.25
          text: "Yes"
          onClicked: {
            qmlSystem.addToPermissionList(website, true)
            confirmWebsiteAllowance.close()
          }
        }
      }
    }
  }

  // "qrcodeWidth = 0" doesn't let the program open, leave it at 1.
  // width/height/y are overrides to properly size the popup.
  AVMEPopupQRCode {
    id: qrcodePopup
    width: window.width * 0.3
    height: window.height * 0.6
    y: ((window.height / 2) - (height / 2))
    qrcodeWidth: (currentAddress != "")
    ? qmlSystem.getQRCodeSize(currentAddress) : 1
    textAddress.text: currentAddress
  }


  AVMEPopupViewPrivKey {
    id: viewPrivKeyPopup
    width: window.width * 0.75
    height: window.height * 0.6
    y: ((window.height / 2) - (height / 2))
  }

  AVMEPopupViewSeed {
    id: viewSeedPopup
    width: window.width * 0.75
    height: window.height * 0.6
    y: ((window.height / 2) - (height / 2))
  }

  AVMEPopupWebsitePermission {
    id: viewWebsitePermissionPopup
    width: window.width * 0.4
    height: window.height * 0.9
    y: ((window.height / 2) - (height / 2))
  }

  AVMEPopupConfirmTx {
    id: confirmRT
    width: window.width * 0.6
    height: window.height * 0.7
    y: ((window.height / 2) - (height / 2))
    onAboutToHide: qmlSystem.resetWindowFlags()
    backBtn.onClicked: {
      confirmRT.close()
      qmlSystem.requestedTransactionStatus(false, "")
    }
  }

  AVMEPopupTxProgress {
    width: window.width * 0.7
    height: window.height * 0.8
    y: ((window.height / 2) - (height / 2))
    id: txProgressPopup
    requestedFromWS: true
  }

  AVMEPopupConfirmSign {
    id: confirmSign
    width: window.width * 0.6
    height: window.height * 0.7
    isWebserver: true
    y: ((window.height / 2) - (height / 2))
    onAboutToHide: qmlSystem.resetWindowFlags()
    backBtn.onClicked: {
      confirmSign.close()
      qmlSystem.requestedTransactionStatus(false, "")
    }
  }
}

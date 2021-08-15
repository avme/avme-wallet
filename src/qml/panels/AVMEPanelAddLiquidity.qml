/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import QmlApi 1.0

import "qrc:/qml/components"

// Panel for adding liquidity to a pool.
AVMEPanel {
  id: addLiquidityPanel
  title: "Add Liquidity"
  property string asset1Allowance
  property string asset2Allowance
  property string asset1Reserves
  property string asset2Reserves
  property bool asset1Approved
  property bool asset2Approved
  property string pairAddress
  property alias add1Amount: addAsset1Input.text
  property alias add2Amount: addAsset2Input.text
  property alias addBtn: addLiquidityBtn

  QmlApi { id: qmlApi }

  Connections {
    target: accountHeader
    function onUpdatedBalances() { refreshAssetBalance() }
  }

  Connections {
    target: qmlApi
    function onApiRequestAnswered(answer, requestID) {
      if (requestID == "QmlAddLiquidity_fetchAllowance") {
        var resp = JSON.parse(answer)
        asset1Allowance = qmlApi.parseHex(resp[0].result, ["uint"])
        asset2Allowance = qmlApi.parseHex(resp[1].result, ["uint"])
        pairAddress = qmlApi.parseHex(resp[2].result, ["address"])
        // AVAX doesn't need approval, tokens do (and individually)
        if (addAsset1Popup.chosenAssetSymbol == "AVAX") {
          asset1Approved = true
        } else {
          var asset1 = accountHeader.tokenList[addAsset1Popup.chosenAssetAddress]
          asset1Approved = (+asset1Allowance >= +qmlSystem.fixedPointToWei(
            asset1["rawBalance"], addAsset1Popup.chosenAssetDecimals
          ))
        }
        if (addAsset2Popup.chosenAssetSymbol == "AVAX") {
          asset2Approved = true
        } else {
          var asset2 = accountHeader.tokenList[addAsset2Popup.chosenAssetAddress]
          asset2Approved = (+asset2Allowance >= +qmlSystem.fixedPointToWei(
            asset2["rawBalance"], addAsset2Popup.chosenAssetDecimals
          ))
        }
        qmlApi.clearAPIRequests("QmlExchange_refreshReserves")
        qmlApi.buildGetReservesReq(pairAddress, "QmlExchange_refreshReserves")
        qmlApi.doAPIRequests("QmlExchange_refreshReserves")
      } else if (requestID == "QmlExchange_refreshReserves") {
        var resp = JSON.parse(answer)
        var reserves = qmlApi.parseHex(resp[0].result, ["uint", "uint", "uint"])
        var lowerAddress = qmlSystem.getFirstFromPair(
          addAsset1Popup.chosenAssetAddress, addAsset2Popup.chosenAssetAddress
        )
        if (lowerAddress == addAsset1Popup.chosenAssetAddress) {
          asset1Reserves = reserves[0]
          asset2Reserves = reserves[1]
        } else if (lowerAddress == addAsset2Popup.chosenAssetAddress) {
          asset1Reserves = reserves[1]
          asset2Reserves = reserves[0]
        }
      }
    }
  }

  function fetchAllowance() {
    refreshAssetBalance()
    addAsset1Input.text = addAsset2Input.text = asset1Reserves = asset2Reserves = ""
    qmlApi.clearAPIRequests("QmlAddLiquidity_fetchAllowance")
    qmlApi.buildGetAllowanceReq(
      addAsset1Popup.chosenAssetAddress,
      qmlSystem.getCurrentAccount(),
      qmlSystem.getContract("router"),
      "QmlAddLiquidity_fetchAllowance"
    )
    qmlApi.buildGetAllowanceReq(
      addAsset2Popup.chosenAssetAddress,
      qmlSystem.getCurrentAccount(),
      qmlSystem.getContract("router"),
      "QmlAddLiquidity_fetchAllowance"
    )
    qmlApi.buildGetPairReq(
      addAsset1Popup.chosenAssetAddress,
      addAsset2Popup.chosenAssetAddress,
      "QmlAddLiquidity_fetchAllowance"
    )
    qmlApi.doAPIRequests("QmlAddLiquidity_fetchAllowance")
  }

  function refreshAssetBalance() {
    var asset1Symbol = addAsset1Popup.chosenAssetSymbol
    var asset2Symbol = addAsset2Popup.chosenAssetSymbol
    var asset1Balance, asset2Balance
    if (asset1Symbol == "AVAX") {
      asset1Balance = accountHeader.coinRawBalance
    } else {
      var asset1 = accountHeader.tokenList[addAsset1Popup.chosenAssetAddress]
      asset1Balance = (asset1 != undefined) ? asset1["rawBalance"] : ""
    }
    if (asset2Symbol == "AVAX") {
      asset2Balance = accountHeader.coinRawBalance
    } else {
      var asset2 = accountHeader.tokenList[addAsset2Popup.chosenAssetAddress]
      asset2Balance = (asset2 != undefined) ? asset2["rawBalance"] : ""
    }
    assetBalance.text = (asset1Balance != "" && asset2Balance != "")
      ? "Balances:<br><b>"
        + asset1Balance + " " + asset1Symbol + "<br>"
        + asset2Balance + " " + asset2Symbol + "</b>"
      : "Loading asset balances..."
  }

  // For manual inputs on amounts
  function calculateAddLiquidityAmount() {
    var lowerAddress = qmlSystem.getFirstFromPair(
      addAsset1Popup.chosenAssetAddress, addAsset2Popup.chosenAssetAddress
    )
    if (lowerAddress == addAsset1Popup.chosenAssetAddress) {
      addAsset2Input.text = qmlSystem.calculateAddLiquidityAmount(
        addAsset1Input.text, asset1Reserves, asset2Reserves
      )
    } else if (lowerAddress == addAsset2Popup.chosenAssetAddress) {
      addAsset1Input.text = qmlSystem.calculateAddLiquidityAmount(
        addAsset2Input.text, asset2Reserves, asset1Reserves
      )
    }
  }

  // For the Max Amounts button
  function calculateMaxAddLiquidityAmount() {
    // Get the max asset amounts, check who is lower and calculate accordingly
    var asset1Max = (addAsset1Popup.chosenAssetSymbol == "AVAX")
      ? qmlSystem.getRealMaxAVAXAmount("250000", qmlSystem.getAutomaticFee())
      : accountHeader.tokenList[addAsset1Popup.chosenAssetAddress]["balance"]
    var asset2Max = (addAsset1Popup.chosenAssetSymbol == "AVAX")
      ? qmlSystem.getRealMaxAVAXAmount("250000", qmlSystem.getAutomaticFee())
      : accountHeader.tokenList[addAsset2Popup.chosenAssetAddress]["balance"]
    var lowerAddress = qmlSystem.getFirstFromPair(
      addAsset1Popup.chosenAssetAddress, addAsset2Popup.chosenAssetAddress
    )
    var asset1Amount, asset2Amount
    if (lowerAddress == addAsset1Popup.chosenAssetAddress) {
      asset1Amount = qmlSystem.calculateAddLiquidityAmount(asset2Max, asset2Reserves, asset1Reserves)
      asset2Amount = qmlSystem.calculateAddLiquidityAmount(asset1Max, asset1Reserves, asset2Reserves)
    } else if (lowerAddress == addAsset2Popup.chosenAssetAddress) {
      asset1Amount = qmlSystem.calculateAddLiquidityAmount(asset2Max, asset1Reserves, asset2Reserves)
      asset2Amount = qmlSystem.calculateAddLiquidityAmount(asset1Max, asset2Reserves, asset1Reserves)
    }
    // Limit the max amount to the lowest the user has, then set the right
    // values afterwards. If asset1Amount is higher than the balance in asset1Max,
    // then that balance is limiting. Same with asset2Amount and asset2Max.
    if (qmlSystem.firstHigherThanSecond(asset1Amount, asset1Max)) {
      asset2Max = asset2Amount
    }
    if (qmlSystem.firstHigherThanSecond(asset2Amount, asset2Max)) {
      asset1Max = asset1Amount
    }
    if (lowerAddress == addAsset1Popup.chosenAssetAddress) {
      asset1Input.text = asset1Max
      asset2Input.text = qmlSystem.calculateAddLiquidityAmount(
        asset1Max, asset1Reserves, asset2Reserves
      )
    } else if (lowerAddress == addAsset2Popup.chosenAssetAddress) {
      asset2Input.text = asset2Max
      asset1Input.text = qmlSystem.calculateAddLiquidityAmount(
        asset2Max, asset2Reserves, asset1Reserves
      )
      liquidityTokenInput.text = maxAmountAVME
      liquidityCoinInput.text = qmlSystem.calculateAddLiquidityAmount(
        maxAmountAVME, lowerReserves, higherReserves
      )
    }
  }

  Column {
    id: addLiquidityHeaderColumn
    height: (parent.height * 0.5) - anchors.topMargin
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      topMargin: 80
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 20

    Text {
      id: addLiquidityHeader
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "You will add liquidity to the <b>" +
      addAsset1Popup.chosenAssetSymbol + "/" + addAsset2Popup.chosenAssetSymbol
      + "</b> pool"
    }

    Row {
      id: addLiquidityLogos
      height: 64
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.margins: 20

      Image {
        id: addAsset1Logo
        height: 48
        antialiasing: true
        smooth: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        fillMode: Image.PreserveAspectFit
        source: {
          var avmeAddress = qmlSystem.getAVMEAddress()
          if (addAsset1Popup.chosenAssetSymbol == "AVAX") {
            source: "qrc:/img/avax_logo.png"
          } else if (addAsset1Popup.chosenAssetAddress == avmeAddress) {
            source: "qrc:/img/avme_logo.png"
          } else {
            var img = qmlSystem.getARC20TokenImage(addAsset1Popup.chosenAssetAddress)
            source: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
          }
        }
      }

      Image {
        id: addAsset2Logo
        height: 48
        antialiasing: true
        smooth: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        fillMode: Image.PreserveAspectFit
        source: {
          var avmeAddress = qmlSystem.getAVMEAddress()
          if (addAsset2Popup.chosenAssetSymbol == "AVAX") {
            source: "qrc:/img/avax_logo.png"
          } else if (addAsset2Popup.chosenAssetAddress == avmeAddress) {
            source: "qrc:/img/avme_logo.png"
          } else {
            var img = qmlSystem.getARC20TokenImage(addAsset2Popup.chosenAssetAddress)
            source: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
          }
        }
      }

      Text {
        id: addLiquidityOrder
        anchors.verticalCenter: parent.verticalCenter
        color: "#FFFFFF"
        font.pixelSize: 48.0
        text: " -> "
      }

      Image {
        id: addPangolinLogo
        height: 48
        antialiasing: true
        smooth: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        fillMode: Image.PreserveAspectFit
        source: "qrc:/img/pangolin.png"
      }
    }

    Text {
      id: assetBalance
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Loading asset balances..."
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btnChangeAdd1
        width: (parent.parent.width * 0.5) - (parent.spacing / 2)
        text: "Change Asset 1"
        onClicked: addAsset1Popup.open()
      }
      AVMEButton {
        id: btnChangeAdd2
        width: (parent.parent.width * 0.5) - (parent.spacing / 2)
        text: "Change Asset 2"
        onClicked: addAsset2Popup.open()
      }
    }
  }

  Column {
    id: addLiquidityApprovalColumn
    visible: !addLiquidityDetailsColumn.visible
    anchors {
      top: addLiquidityHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: 20
      bottomMargin: 20
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 20

    Text {
      id: addLiquidityApprovalText
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "You need to approve your Account in order to add<br><b>"
      + (!asset1Approved) ? addAsset1Popup.chosenAssetSymbol : ""
      + (!asset1Approved && !asset2Approved) ? " and " : ""
      + (!asset2Approved) ? addAsset2Popup.chosenAssetSymbol : ""
      + "</b> to the pool."
      + "<br>This operation will have a total gas cost of:<br><b>"
      + qmlSystem.calculateTransactionCost("0",
        (!addAsset1Approved && !addAsset2Approved) ? "320000" : "180000",
        qmlSystem.getAutomaticFee()
      ) + " AVAX</b>"
    }

    AVMEButton {
      id: approveBtn
      width: parent.width
      enabled: (+accountHeader.coinRawBalance >=
        +qmlSystem.calculateTransactionCost("0", "180000", qmlSystem.getAutomaticFee())
      )
      anchors.horizontalCenter: parent.horizontalCenter
      text: (enabled) ? "Approve" : "Not enough funds"
      onClicked: confirmAddApprovalPopup.open()
    }
  }

  Column {
    id: addLiquidityDetailsColumn
    enabled: (asset1Approved && asset2Approved)
    anchors {
      top: addLiquidityHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: 40
      bottomMargin: 20
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 25

    AVMEInput {
      id: addAsset1Input
      width: parent.width
      enabled: (asset1Reserves != "" && asset2Reserves != "")
      validator: RegExpValidator {
        regExp: qmlSystem.createTxRegExp(addAsset1Popup.chosenAssetDecimals)
      }
      label: addAsset1Popup.chosenAssetSymbol + " Amount"
      placeholder: "Fixed point amount (e.g. 0.5)"
      onTextEdited: calculateAddLiquidityAmount()
    }

    AVMEInput {
      id: addAsset2Input
      width: parent.width
      enabled: (asset1Reserves != "" && asset2Reserves != "")
      validator: RegExpValidator {
        regExp: qmlSystem.createTxRegExp(addAsset2Popup.chosenAssetDecimals)
      }
      label: addAsset2Popup.chosenAssetSymbol + " Amount"
      placeholder: "Fixed point amount (e.g. 0.5)"
      onTextEdited: calculateAddLiquidityAmount()
    }

    AVMEButton {
      id: addMaxBtn
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Max Amounts"
      enabled: (asset1Reserves != "" && asset2Reserves != "")
      onClicked: calculateMaxAddLiquidityAmount()
    }

    AVMEButton {
      id: addLiquidityBtn
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (addAsset1Input.acceptableInput && addAsset2Input.acceptableInput)
      text: "Add to the pool"
      // TODO: transaction logic
    }
  }
}

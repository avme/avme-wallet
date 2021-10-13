/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.15
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/popups"

AVMEPanel {
  id: exchangeScreenPanel
  title: "Exchange"

  /**
   *  Holds information about the assets, as follows:
   *  {
   *    "left" : {
   *      "allowance"  : "...",
   *      "decimals"   : "...",
   *      "contract"   : "...",
   *      "symbol"     : "...",
   *      "imageSource": "...",
   *      "approved"   : "..."
   *    },
   *    "right" : {
   *      "allowance"  : "...",
   *      "decimals"   : "...",
   *      "contract"   : "...",
   *      "symbol"     : "...",
   *      "imageSource": "...",
   *      "approved"   : "..."
   *    },
   *  }
   */

  // We need properties for information used inside objects,
  // as when you open a new screen it cannot load objects inside the
  // "exchangeInfo" property.
  property var exchangeInfo: ({})
  property string leftSymbol: ""
  property string leftImageSource: ""
  property string leftDecimals: ""
  property string leftAllowance: ""
  property string leftContract: ""
  property string rightSymbol: ""
  property string rightImageSource: ""
  property string rightDecimals: ""
  property string rightAllowance: ""
  property string rightContract: ""
  property double swapImpact: 0

  // Transaction information
  property string desiredSlippage: slippageSettings.slippage
  property string to
  property string coinValue
  property string txData
  property string gas
  property string gasPrice: qmlApi.sum(accountHeader.gasPrice, 15)
  property bool automaticGas: true
  property string info
  property string historyInfo

  // Helper properties
  property string randomID
  property bool loading: true
  property bool transactionReady: false
  property bool reachedPriceImpact: false

  // Timers for constantly updating values
  Timer { id: allowanceTimer; interval: 100; repeat: true; onTriggered: fetchAllowance(false) }
  Timer { id: getPriceOnEditLeftTimer; interval: 500; repeat: false; onTriggered: getPriceOnEditLeft() }
  Timer { id: balanceTimer; interval: 10; repeat: true; onTriggered: updateBalances() }

  Connections {
    target: qmlSystem
    function onGotParaSwapTokenPrices(answer, answerId) {
      if (answerId == "ExchangeGetPrice" + randomID) { 
        var priceRoute = JSON.parse(answer)
        rightInput.enabled = true
        rightInput.text = qmlApi.weiToFixedPoint(priceRoute["priceRoute"]["destAmount"],priceRoute["priceRoute"]["destDecimals"])
        transactionReady = false

        if (!priceRoute["priceRoute"]["maxImpactReached"]) {
          qmlSystem.getParaSwapTransactionData(answer,
                                               desiredSlippage,
                                               accountHeader.currentAddress,
                                               15,
                                               "ExchangeGetTransaction" + randomID)
        } else {
          reachedPriceImpact = true
        }
      }
    }
    function onGotParaSwapTransactionData(answer, answerId) {
      if (answerId == "ExchangeGetTransaction" + randomID) {
        var transactionData = JSON.parse(answer)
        to = transactionData["to"]
        console.log(transactionData["value"])
        coinValue = qmlApi.weiToFixedPoint(transactionData["value"], 18)
        txData = transactionData["data"]
        info = "Swap <b>" + leftInput.text + exchangeInfo["left"]["symbol"] + "<\b> to <b>" + rightInput.text + exchangeInfo["right"]["symbol"] + "<\b>"
        historyInfo = "Swap <b>" + exchangeInfo["left"]["symbol"] + "<\b> to <b>" + exchangeInfo["right"]["symbol"]
        gas = 750000
        transactionReady = true
      }
    }
  }
  // Connections to handle API answers
  Connections {
    target: qmlApi
    function onApiRequestAnswered(answer, requestID) {
      if (requestID == "ExchangePanelAllowance_" + randomID) {
        // Parse the answer as a JSON
        var respArr = JSON.parse(answer)
        var leftAllowance = ""
        var rightAllowance = ""
        for (var answerItem in respArr) {
          if (respArr[answerItem]["id"] == 1) {
            // Allowance for leftAsset
            leftAllowance = qmlApi.parseHex(respArr[answerItem].result, ["uint"])
          }
          if (respArr[answerItem]["id"] == 2) {
            // Allowance for rightAsset
            rightAllowance = qmlApi.parseHex(respArr[answerItem].result, ["uint"])
          }
        }

        exchangeInfo["left"]["allowance"] = leftAllowance
        exchangeInfo["right"]["allowance"] = rightAllowance
        if (!(exchangeInfo["left"]["symbol"] == "AVAX")) {
          var asset = accountHeader.tokenList[exchangeInfo["left"]["contract"]]
          if (+qmlApi.fixedPointToWei(asset["rawBalance"], asset["decimals"]) >= +leftAllowance) {
            exchangeInfo["left"]["approved"] = false
          } else {
            exchangeInfo["left"]["approved"] = true
          }
        } else {
          // WAVAX does not require approval
          exchangeInfo["left"]["approved"] = true
        }

        if (!(exchangeInfo["right"]["symbol"] == "AVAX")) {
          var asset = accountHeader.tokenList[exchangeInfo["right"]["contract"]]
          if (+qmlApi.fixedPointToWei(asset["rawBalance"], asset["decimals"]) >= +rightAllowance) {
            exchangeInfo["right"]["approved"] = false
          } else {
            exchangeInfo["right"]["approved"] = true
          }
        } else {
          // WAVAX does not require approval
          exchangeInfo["right"]["approved"] = true
        }

        // Check allowance to see if we can proceed collecting further information.
        // Only check if it is a token and not WAVAX, as WAVAX does NOT require allowance.
        if (!exchangeInfo["left"]["approved"]) {
          // Required allowance on the input asset!
          exchangePanelApprovalColumn.visible = true
          exchangePanelDetailsColumn.visible = false
          exchangePanelLoadingPng.visible = false
          allowanceTimer.start()
        } else {
          exchangePanelApprovalColumn.visible = false
          exchangePanelDetailsColumn.visible = true
          exchangePanelLoadingPng.visible = false
          allowanceTimer.stop()
        }
      }
    }
  }

  Connections {
    target: exchangeLeftAssetCombobox
    function onActivated() {
      // No need to reload in case of the same asset is selected
      if (exchangeInfo["left"]["contract"] == exchangeLeftAssetCombobox.chosenAsset.address) {
        return
      }

      // Edge case for WAVAX
      if (exchangeInfo["left"]["contract"] == "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE" && 
          exchangeLeftAssetCombobox.chosenAsset.address == "0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7") {
        return
      }

      // Edge case for WAVAX
      if (exchangeLeftAssetCombobox.chosenAsset.symbol == "AVAX") {
        // WAVAX does not require allowance
        exchangeInfo["left"]["allowance"] = qmlApi.MAX_U256_VALUE();
      } else {
        exchangeInfo["left"]["allowance"] = "0";
      }
      exchangeInfo["left"]["decimals"] = exchangeLeftAssetCombobox.chosenAsset.decimals
      if (exchangeLeftAssetCombobox.chosenAsset.symbol == "AVAX") {
        exchangeInfo["left"]["contract"] = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"
      } else {
        exchangeInfo["left"]["contract"] = exchangeLeftAssetCombobox.chosenAsset.address
      }
      exchangeInfo["left"]["symbol"] = exchangeLeftAssetCombobox.chosenAsset.symbol

      var img = ""
      if (exchangeLeftAssetCombobox.chosenAsset.symbol == "AVAX") {
        img = "qrc:/img/avax_logo.png"
      } else if (exchangeLeftAssetCombobox.chosenAsset.address == "0x1ECd47FF4d9598f89721A2866BFEb99505a413Ed") {
        img = "qrc:/img/avme_logo.png"
      } else {
        var tmpImg = qmlApi.getARC20TokenImage(exchangeLeftAssetCombobox.chosenAsset.address)
        img = (tmpImg != "") ? "file:" + tmpImg : "qrc:/img/unknown_token.png"
      }

      exchangeInfo["left"]["imageSource"] = img

      // Prevent selecting the same two assets
      if (exchangeInfo["right"]["contract"] == exchangeInfo["left"]["contract"] ) {
        exchangeRightAssetCombobox.currentIndex = (exchangeLeftAssetCombobox.currentIndex == 0) ? 1 : 0
        exchangeRightAssetCombobox.activated(exchangeRightAssetCombobox.currentIndex)
        return
      }

      updateDisplay()
      fetchAllowance(true)
    }
  }

  Connections {
    target: exchangeRightAssetCombobox
    function onActivated() {
      // No need to reload in case of the same asset is selected
      if (exchangeInfo["right"]["contract"] == exchangeRightAssetCombobox.chosenAsset.address) {
        return
      }

      // Edge case for WAVAX
      if (exchangeInfo["right"]["contract"] == "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE" && 
          exchangeRightAssetCombobox.chosenAsset.address == "0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7") {
        return
      }

      // Edge case for WAVAX
      if (exchangeRightAssetCombobox.chosenAsset.symbol == "AVAX") {
        // WAVAX does not require allowance
        exchangeInfo["right"]["allowance"] = qmlApi.MAX_U256_VALUE();
      } else {
        exchangeInfo["right"]["allowance"] = "0";
      }
      exchangeInfo["right"]["decimals"] = exchangeRightAssetCombobox.chosenAsset.decimals
      if (exchangeRightAssetCombobox.chosenAsset.symbol == "AVAX") {
        exchangeInfo["right"]["contract"] = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"
      } else {
        exchangeInfo["right"]["contract"] = exchangeRightAssetCombobox.chosenAsset.address
      }
      exchangeInfo["right"]["symbol"] = exchangeRightAssetCombobox.chosenAsset.symbol

      var img = ""
      if (exchangeRightAssetCombobox.chosenAsset.address == "AVAX") {
        img = "qrc:/img/avax_logo.png"
      } else if (exchangeRightAssetCombobox.chosenAsset.address == "0x1ECd47FF4d9598f89721A2866BFEb99505a413Ed") {
        img = "qrc:/img/avme_logo.png"
      } else {
        var tmpImg = qmlApi.getARC20TokenImage(exchangeRightAssetCombobox.chosenAsset.address)
        img = (tmpImg != "") ? "file:" + tmpImg : "qrc:/img/unknown_token.png"
      }

      exchangeInfo["right"]["imageSource"] = img

      // Prevent selecting the same two assets
      if (exchangeInfo["left"]["contract"] == exchangeInfo["right"]["contract"]) {
        exchangeLeftAssetCombobox.currentIndex = (exchangeRightAssetCombobox.currentIndex == 0) ? 1 : 0
        exchangeLeftAssetCombobox.activated(exchangeLeftAssetCombobox.currentIndex)
        return
      }

      updateDisplay()
      fetchAllowance(true)
    }
  }

  // Initiallize and set assets to default to AVAX -> AVME
  Component.onCompleted: {
    exchangeInfo["left"] = ({});
    exchangeInfo["right"] = ({});
    exchangeInfo["pairs"] = ([]);
    exchangeInfo["routing"] = ([]);
    exchangeInfo["reserves"] = ([]);
    exchangeInfo["left"]["allowance"] = qmlApi.MAX_U256_VALUE(); // WAVAX does not require allowance
    exchangeInfo["left"]["decimals"] = "18";
    exchangeInfo["left"]["contract"] = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";
    exchangeInfo["left"]["symbol"] = "AVAX";
    exchangeInfo["left"]["imageSource"] = "qrc:/img/avax_logo.png";
    exchangeInfo["right"]["allowance"] = "0";
    exchangeInfo["right"]["decimals"] = "18";
    exchangeInfo["right"]["contract"] = "0x1ECd47FF4d9598f89721A2866BFEb99505a413Ed";
    exchangeInfo["right"]["symbol"] = "AVME";
    exchangeInfo["right"]["imageSource"] = "qrc:/img/avme_logo.png";
    // Information displayed to the user needs to be kept on their own variable
    // as a string. For that reason there's an updateDisplay() function which
    // will provide these variables with the new information from "exchangeInfo"
    balanceTimer.start()
    updateDisplay()
    fetchAllowance(true)
  }

  function fetchAllowance(updateAssets) {
    if (updateAssets) {
      randomID = qmlApi.getRandomID()
      exchangePanelApprovalColumn.visible = false
      exchangePanelDetailsColumn.visible = false
      exchangePanelUnavailablePair.visible = false
      exchangePanelLoadingPng.visible = true
      loading = true
    }

    qmlApi.clearAPIRequests("ExchangePanelAllowance_" + randomID)
    // Get allowance for inToken and reserves for all, including reserves for
    // both in/out tokens against WAVAX.
    // Allowance for leftAsset
    qmlApi.buildGetAllowanceReq(
      exchangeInfo["left"]["contract"],
      accountHeader.currentAddress,
      tokenProxy,
      "ExchangePanelAllowance_" + randomID
    )
    // Allowance for rightAsset
    qmlApi.buildGetAllowanceReq(
      exchangeInfo["right"]["contract"],
      accountHeader.currentAddress,
      tokenProxy,
      "ExchangePanelAllowance_" + randomID
    )
    // id 1: allowance for left
    // id 2: allowance for right
    qmlApi.doAPIRequests("ExchangePanelAllowance_" + randomID)
  }

  function updateDisplay() {
    randomID = qmlApi.getRandomID()
    rightInput.text    = ""
    leftInput.text     = ""
    leftSymbol         = exchangeInfo["left"]["symbol"]
    leftImageSource    = exchangeInfo["left"]["imageSource"]
    leftDecimals       = exchangeInfo["left"]["decimals"]
    leftAllowance      = exchangeInfo["left"]["allowance"]
    leftContract       = exchangeInfo["left"]["contract"]
    rightSymbol        = exchangeInfo["right"]["symbol"]
    rightImageSource   = exchangeInfo["right"]["imageSource"]
    rightDecimals      = exchangeInfo["right"]["decimals"]
    rightAllowance     = exchangeInfo["right"]["allowance"]
    rightContract      = exchangeInfo["right"]["contract"]
    transactionReady   = false
    reachedPriceImpact = false

    // Check allowance to see if we should ask the user to allow it.
    // Only check if it is a token and not WAVAX, as WAVAX does NOT require allowance.
    if (!exchangeInfo["left"]["approved"]) {
      // Reset the randomID, if there is a reserves request pending on the C++ side
      // it won't set the screens to visible again.
      // Required allowance on the input asset!
      exchangePanelApprovalColumn.visible = true
      exchangePanelDetailsColumn.visible = false
      exchangePanelLoadingPng.visible = false
      exchangePanelUnavailablePair.visible = false
    } else {
      // Set the screens back to visible, if allowed.
      exchangePanelApprovalColumn.visible = false
      exchangePanelDetailsColumn.visible = true
      exchangePanelLoadingPng.visible = false
      exchangePanelUnavailablePair.visible = false
    }
  }

  function updateBalances() {
    if (exchangeInfo["left"]["symbol"] == "AVAX") {
      assetBalance.text = "<b>" + accountHeader.coinRawBalance + " " + exchangeInfo["left"]["symbol"] + "</b>"
    } else {
      var asset = accountHeader.tokenList[exchangeInfo["left"]["contract"]]
      assetBalance.text = "<b>" + asset["rawBalance"] + " " + exchangeInfo["left"]["symbol"] + "</b>"
    }
  }

  function swapOrder() {
    var tmpLeft = ({})
    var tmpRight = ({})
    tmpLeft = exchangeInfo["right"]
    tmpRight = exchangeInfo["left"]

    exchangeInfo["left"] = ({})
    exchangeInfo["right"] = ({})
    exchangeInfo["left"] = tmpLeft
    exchangeInfo["right"] = tmpRight

    // Invert comboBox
    var leftIndex = exchangeLeftAssetCombobox.currentIndex
    var rightIndex = exchangeRightAssetCombobox.currentIndex

    exchangeLeftAssetCombobox.currentIndex = rightIndex
    exchangeRightAssetCombobox.currentIndex = leftIndex

    updateDisplay()
  }

  function getPriceOnEditLeft() {
    randomID = qmlApi.getRandomID()
    rightInput.enabled = false
    rightInput.text = ""
    rightInput.placeholder = "Loading..."

    qmlSystem.getParaSwapTokenPrices(exchangeInfo["left"]["contract"],
                                     exchangeInfo["left"]["decimals"],
                                     exchangeInfo["right"]["contract"],
                                     exchangeInfo["right"]["decimals"],
                                     qmlApi.fixedPointToWei(leftInput.text, exchangeInfo["left"]["decimals"]),
                                     "43114",
                                     "SELL",
                                     "ExchangeGetPrice" + randomID
    )
  }
  // ======================================================================
  // TRANSACTION RELATED FUNCTIONS
  // ======================================================================

  function approveTx() {
    to = exchangeInfo["left"]["contract"]
    coinValue = 0
    gas = 70000
    info = "You will Approve <b>" + exchangeInfo["left"]["symbol"] + "</b> on ParaSwap proxy Contract"
    historyInfo = "Approve <b>" + exchangeInfo["left"]["symbol"] + "</b> on ParaSwap"

    // approve(address,uint256)
    var ethCallJson = ({})
    ethCallJson["function"] = "approve(address,uint256)"
    ethCallJson["args"] = []
    ethCallJson["args"].push(tokenProxy)
    ethCallJson["args"].push(qmlApi.MAX_U256_VALUE())
    ethCallJson["types"] = []
    ethCallJson["types"].push("address")
    ethCallJson["types"].push("uint*")
    var ethCallString = JSON.stringify(ethCallJson)
    var ABI = qmlApi.buildCustomABI(ethCallString)
    txData = ABI
  }

  function swapTx(amountIn, amountOut) {

  }

  function calculateTransactionCost(gasLimit, amountIn) {
    var transactionFee = qmlApi.floor(qmlApi.mul(gasLimit, (+gasPrice * 1000000000)))
    var WeiWAVAXBalance = qmlApi.floor(qmlApi.fixedPointToWei(accountHeader.coinRawBalance,18))
    if (+transactionFee > +WeiWAVAXBalance) {
      return false
    }
    // Edge case for WAVAX
    if (exchangeInfo["left"]["symbol"] == "AVAX") {
      var totalCost = qmlApi.weiToFixedPoint(qmlApi.sum(transactionFee, qmlApi.fixedPointToWei(amountIn,18)),18)
      if (+totalCost > +accountHeader.coinRawBalance) {
        return false
      }
    } else {
      if (+amountIn > +accountHeader.tokenList[exchangeInfo["left"]["contract"]]["rawBalance"]) {
        return false
      }
    }
    return true
  }

  // ======================================================================
  // HEADER
  // ======================================================================

  Column {
    id: exchangePanelHeaderColumn
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
      id: exchangeHeaderText
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "You will swap from <b>" + leftSymbol
      + "</b> to <b>" + rightSymbol + "</b>"
    }

    Row {
      id: exchangeLogos
      height: 64
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.margins: 20

      AVMEAssetCombobox {
        id: exchangeLeftAssetCombobox
        height: parent.height
        width: exchangePanelHeaderColumn.width / 2.5
      }

      Rectangle {
        id: swapOrderRectangle
        height: 64
        width: 80
        anchors.verticalCenter: parent.verticalCenter
        color: "transparent"
        radius: 5

        Image {
          id: swapOrderImage
          height: 48
          width: 48
          anchors.verticalCenter: parent.verticalCenter
          anchors.horizontalCenter: parent.horizontalCenter
          fillMode: Image.PreserveAspectFit
          source: "qrc:/img/icons/arrow.png"
        }
        MouseArea {
          id: swapOrderMouseArea
          anchors.fill: parent
          hoverEnabled: true
          enabled: (!loading)
          onEntered: swapOrderRectangle.color = "#1d1827"
          onExited: swapOrderRectangle.color = "transparent"
          onClicked: { swapOrder() }
        }
      }

      AVMEAssetCombobox {
        id: exchangeRightAssetCombobox
        height: parent.height
        width: exchangePanelHeaderColumn.width / 2.5
        defaultToAVME: true
      }
    }
    Text {
      id: assetBalance
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Loading asset balance..."
    }
  }

  // ======================================================================
  // LOADING IMAGE
  // ======================================================================

  Image {
    id: exchangePanelLoadingPng
    anchors {
      top: exchangePanelHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: 0
      bottomMargin: 50
    }
    fillMode: Image.PreserveAspectFit
    source: "qrc:/img/icons/loading.png"
    RotationAnimator {
      target: exchangePanelLoadingPng
      from: 0
      to: 360
      duration: 1000
      loops: Animation.Infinite
      easing.type: Easing.InOutQuad
      running: true
    }
  }

  // ======================================================================
  // APPROVAL
  // ======================================================================

  Column {
    id: exchangePanelApprovalColumn
    anchors {
      top: exchangePanelHeaderColumn.bottom
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
      id: exchangeApprovalText
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "You need to approve your <br>Account in order to swap <b>"
      + leftSymbol + "</b>."
      + "<br>This operation will have <br>a total gas cost of:<br><b>"
      + qmlApi.weiToFixedPoint(qmlApi.floor(qmlApi.mul("70000", (gasPrice * 1000000000))),18)
      + " AVAX</b>"
    }

    AVMEButton {
      id: btnApprove
      width: parent.width
      enabled: (+accountHeader.coinRawBalance >=
        +qmlApi.weiToFixedPoint(qmlApi.floor(qmlApi.mul("70000", (gasPrice * 1000000000))),18)
      )
      anchors.horizontalCenter: parent.horizontalCenter
      text: (enabled) ? "Approve" : "Not enough funds"
      onClicked: {
        approveTx()
        if (calculateTransactionCost(70000, "0")) {
          confirmTransactionPopup.setData(
            to,
            coinValue,
            txData,
            gas,
            gasPrice,
            true,
            info,
            historyInfo
          )
          confirmTransactionPopup.open()
        } else {
          fundsPopup.open();
        }
      }
    }
  }

  // ======================================================================
  // PAIR UNAVAILABLE
  // ======================================================================

  Column {
    id: exchangePanelUnavailablePair
    anchors {
      top: exchangePanelHeaderColumn.bottom
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
      id: exchangePanelUnavailablePairText
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      color: "#FFFFFF"
      font.pixelSize: 18.0
      text: "The desired pair is unavailable<br>Please select other"
    }
  }

  // ======================================================================
  // DETAILS
  // ======================================================================

  Column {
    id: exchangePanelDetailsColumn
    anchors {
      top: exchangePanelHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: -20
      bottomMargin: 20
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 20

    AVMEInput {
      id: leftInput
      width: (parent.width * 0.8)
      label: leftSymbol + " Amount"
      validator: RegExpValidator { regExp: qmlApi.createRegExp("[0-9]{1,99}(?:\\.[0-9]{1," + leftDecimals + "})?") }
      placeholder: "Amount (e.g. 0.5)"
      onTextEdited: { 
        transactionReady = false
        reachedPriceImpact = false
        getPriceOnEditLeftTimer.stop()
        getPriceOnEditLeftTimer.start()
      }
      AVMEButton {
        id: swapMaxBtn
        width: (parent.parent.width * 0.2) - 10
        anchors {
          left: parent.right
          leftMargin: 10
        }
        text: "Max"
        onClicked: {
          // AVAX Edge Case
          if (leftSymbol == "AVAX") {
            var totalFees = qmlApi.floor(qmlApi.mul(500000, (+gasPrice * 1000000000)))
            var maxWeiWAVAX = qmlApi.floor(qmlApi.sub(qmlApi.fixedPointToWei(accountHeader.coinRawBalance,18),totalFees))
            var maxWAVAX = qmlApi.weiToFixedPoint(maxWeiWAVAX, 18)
            if (+maxWAVAX > 0) {
              leftInput.text = maxWAVAX
            }
          } else {
            leftInput.text = accountHeader.tokenList[exchangeInfo["left"]["contract"]]["rawBalance"]
          }
          getPriceOnEditLeft()
        }
      }
    }

    AVMEInput {
      id: rightInput
      width: parent.width
      label: rightSymbol + " Amount"
      validator: RegExpValidator { regExp: qmlApi.createRegExp("[0-9]{1,99}(?:\\.[0-9]{1," + rightDecimals + "})?") }
      placeholder: "Amount (e.g. 0.5)"
      onTextEdited: { }
    }

    AVMEButton {
      id: btnSwap
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      visible: true
      enabled: ((rightInput.acceptableInput && (swapImpact <= 10.0 || ignoreImpactCheck.checked)) && +rightInput.text != 0 && transactionReady)
      text: (!reachedPriceImpact) ? "Make Swap" : "Price impact too high"
      onClicked: {
        swapTx(leftInput.text, rightInput.text)
        if (calculateTransactionCost(500000, leftInput.text)) {
          confirmTransactionPopup.setData(
            to,
            coinValue,
            txData,
            gas,
            gasPrice,
            true,
            info,
            historyInfo
          )
          confirmTransactionPopup.open()
        } else {
          fundsPopup.open();
        }
      }
    }
  }
  Rectangle {
    id: settingsRectangle
    height: 48
    width: 48
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.topMargin: 16
    anchors.rightMargin: 16
    color: "transparent"
    radius: 5
    Image {
      id: slippageSettingsImage
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      width: 32
      height: 32
      source: "qrc:/img/icons/Icon_Settings.png"
    }
    MouseArea {
      id: settingsMouseArea
      anchors.fill: parent
      hoverEnabled: true
      onEntered: settingsRectangle.color = "#1d1827"
      onExited: settingsRectangle.color = "transparent"
      onClicked: {
        slippageSettings.open();
      }
    }
  }
}

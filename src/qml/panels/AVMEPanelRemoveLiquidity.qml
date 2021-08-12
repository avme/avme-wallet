/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import QmlApi 1.0

import "qrc:/qml/components"

// Panel for removing liquidity to a pool.
AVMEPanel {
  id: removeLiquidityPanel
  title: "Remove Liquidity"
  property string allowance
  property string pairAddress
  property string asset1Reserves
  property string asset2Reserves
  property string liquidity
  property string userAsset1Reserves
  property string userAsset2Reserves
  property string userLPSharePercentage // TODO: find out where this should be used
  property string removeLowerEstimate
  property string removeHigherEstimate
  property string removeLPEstimate

  QmlApi { id: qmlApi }

  Connections {
    target: qmlApi
    function onApiRequestAnswered(answer, requestID) {
      if (requestID == "QmlRemoveLiquidity_fetchPairAndReserves") {
        var resp = JSON.parse(answer)
        pairAddress = qmlApi.parseHex(resp[0].result, ["address"])
        asset1Reserves = qmlApi.parseHex(resp[1].result, ["uint"])
        asset2Reserves = qmlApi.parseHex(resp[2].result, ["uint"])
        qmlApi.clearAPIRequests()
        qmlApi.buildGetAllowanceReq(
          pairAddress,
          qmlSystem.getCurrentAccount(),
          qmlSystem.getContract("router")
        )
        qmlApi.buildGetReservesReq(pairAddress)
        qmlApi.doAPIRequests("QmlRemoveLiquidity_fetchAllowanceAndBalance")
      } else if (requestID == "QmlRemoveLiquidity_fetchAllowanceAndBalance") {
        var resp = JSON.parse(answer)
        allowance = qmlApi.parseHex(resp[0].result, ["uint"])
        liquidity = qmlApi.parseHex(resp[1].result, ["uint"])
        var userShares = qmlSystem.calculatePoolShares(
          asset1Reserves, asset2Reserves, liquidity
        )
        userAsset1Reserves = userShares.lower
        userAsset2Reserves = userShares.higher
        userLPSharePercentage = userShares.liquidity
        removeLiquidityDetailsColumn.visible = (+allowance >=
          +qmlSystem.fixedPointToWei(liquidity, 18)
        )
      }
    }
  }

  function fetchPairAndReserves() {
    pairAddress = allowance = liquidity = asset1Reserves = asset2Reserves = ""
    qmlApi.clearAPIRequests()
    qmlApi.buildGetPairReq(
      removeAsset1Popup.chosenAssetAddress,
      removeAsset2Popup.chosenAssetAddress
    )
    qmlApi.buildGetReservesReq(removeAsset1Popup.chosenAssetAddress)
    qmlApi.buildGetReservesReq(removeAsset2Popup.chosenAssetAddress)
    qmlApi.doAPIRequests("QmlRemoveLiquidity_fetchPairAndReserves")
  }

  Column {
    id: removeLiquidityHeaderColumn
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
      id: removeLiquidityHeader
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "You will remove liquidity from the <b>" +
      removeAsset1Popup.chosenAssetSymbol + "/" + removeAsset2Popup.chosenAssetSymbol
      + "</b> pool"
    }

    Row {
      id: removeLiquidityLogos
      height: 64
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.margins: 20

      Image {
        id: removePangolinLogo
        height: 48
        antialiasing: true
        smooth: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        fillMode: Image.PreserveAspectFit
        source: "qrc:/img/pangolin.png"
      }

      Text {
        id: removeLiquidityOrder
        anchors.verticalCenter: parent.verticalCenter
        color: "#FFFFFF"
        font.pixelSize: 48.0
        text: " -> "
      }

      Image {
        id: removeAsset1Logo
        height: 48
        antialiasing: true
        smooth: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        fillMode: Image.PreserveAspectFit
        source: {
          var avmeAddress = qmlSystem.getAVMEAddress()
          if (removeAsset1Popup.chosenAssetSymbol == "AVAX") {
            source: "qrc:/img/avax_logo.png"
          } else if (removeAsset1Popup.chosenAssetAddress == avmeAddress) {
            source: "qrc:/img/avme_logo.png"
          } else {
            var img = qmlSystem.getARC20TokenImage(removeAsset1Popup.chosenAssetAddress)
            source: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
          }
        }
      }

      Image {
        id: removeAsset2Logo
        height: 48
        antialiasing: true
        smooth: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        fillMode: Image.PreserveAspectFit
        source: {
          var avmeAddress = qmlSystem.getAVMEAddress()
          if (removeAsset2Popup.chosenAssetSymbol == "AVAX") {
            source: "qrc:/img/avax_logo.png"
          } else if (removeAsset2Popup.chosenAssetAddress == avmeAddress) {
            source: "qrc:/img/avme_logo.png"
          } else {
            var img = qmlSystem.getARC20TokenImage(removeAsset2Popup.chosenAssetAddress)
            source: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
          }
        }
      }
    }

    Text {
      id: assetBalance
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: (liquidity != "")
      ? "Balance: <b>" + liquidity + " " + removeAsset1Popup.chosenAssetSymbol
      + "/" + removeAsset2Popup.chosenAssetSymbol + " LP</b>"
      : "Loading asset balance..."
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMEButton {
        id: btnChangeRemove1
        width: (parent.parent.width * 0.5) - (parent.spacing / 2)
        text: "Change Asset 1"
        onClicked: removeAsset1Popup.open()
      }
      AVMEButton {
        id: btnChangeRemove2
        width: (parent.parent.width * 0.5) - (parent.spacing / 2)
        text: "Change Asset 2"
        onClicked: removeAsset2Popup.open()
      }
    }
  }

  Column {
    id: removeLiquidityApprovalColumn
    visible: !removeLiquidityDetailsColumn.visible
    anchors {
      top: removeLiquidityHeaderColumn.bottom
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
      id: removeLiquidityApprovalText
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "You need to approve your Account in order to remove <b>"
      + removeAsset1Popup.chosenAssetSymbol + "/"
      + removeAssetPopup2.chosenAssetSymbol + " LP</b> from the pool."
      + "<br>This operation will have a total gas cost of:<br><b>"
      + qmlSystem.calculateTransactionCost("0", "180000", qmlSystem.getAutomaticFee())
      + " AVAX</b>"
    }

    AVMEButton {
      id: approveBtn
      width: parent.width
      enabled: (+accountHeader.coinRawBalance >=
        +qmlSystem.calculateTransactionCost("0", "180000", qmlSystem.getAutomaticFee())
      )
      anchors.horizontalCenter: parent.horizontalCenter
      text: (enabled) ? "Approve" : "Not enough funds"
      onClicked: confirmRemoveApprovalPopup.open()
    }
  }

  Column {
    id: removeLiquidityDetailsColumn
    anchors {
      top: parent.top
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: 80
      bottomMargin: 20
      leftMargin: 40
      rightMargin: 40
    }
    spacing: 25

    Slider {
      id: liquidityLPSlider
      from: 0
      value: 0
      to: 100
      stepSize: 1
      snapMode: Slider.SnapAlways
      width: parent.width * 0.8
      anchors.left: parent.left
      anchors.margins: 20
      enabled: (allowance != "" && asset1Reserves != "" && asset2Reserves != "" && liquidity != "")
      onMoved: {
        var estimates = qmlSystem.calculateRemoveLiquidityAmount(
          userAsset1Reserves, userAsset2Reserves, value
        )
        removeLowerEstimate = estimates.lower
        removeHigherEstimate = estimates.higher
        removeLPEstimate = estimates.lp
      }
      Text {
        id: sliderText
        anchors.left: parent.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        color: (parent.enabled) ? "#FFFFFF" : "#444444"
        font.pixelSize: 24.0
        text: parent.value + "%"
      }
    }

    Row {
      id: sliderBtnRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 20

      AVMEButton {
        id: sliderBtn25
        enabled: (allowance != "" && asset1Reserves != "" && asset2Reserves != "" && liquidity != "")
        width: (parent.parent.width * 0.2)
        text: "25%"
        onClicked: { liquidityLPSlider.value = 25; liquidityLPSlider.moved(); }
      }

      AVMEButton {
        id: sliderBtn50
        enabled: (allowance != "" && asset1Reserves != "" && asset2Reserves != "" && liquidity != "")
        width: (parent.parent.width * 0.2)
        text: "50%"
        onClicked: { liquidityLPSlider.value = 50; liquidityLPSlider.moved(); }
      }

      AVMEButton {
        id: sliderBtn75
        enabled: (allowance != "" && asset1Reserves != "" && asset2Reserves != "" && liquidity != "")
        width: (parent.parent.width * 0.2)
        text: "75%"
        onClicked: { liquidityLPSlider.value = 75; liquidityLPSlider.moved(); }
      }

      AVMEButton {
        id: sliderBtn100
        enabled: (allowance != "" && asset1Reserves != "" && asset2Reserves != "" && liquidity != "")
        width: (parent.parent.width * 0.2)
        text: "100%"
        onClicked: { liquidityLPSlider.value = 100; liquidityLPSlider.moved(); }
      }
    }

    Text {
      id: removeEstimate
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "<b>" + ((removeLPEstimate) ? removeLPEstimate : "0") + " LP</b>"
      + "<br><br>Estimated returns:<br>"
      + "<b>" + qmlSystem.weiToFixedPoint(
        ((removeAsset1Popup.chosenAssetSymbol == lowerToken)
        ? removeLowerEstimate : removeHigherEstimate), removeAsset1Popup.chosenAssetDecimals)
      + " " + removeAsset1Popup.chosenAssetSymbol
      + "<br>" + qmlSystem.weiToFixedPoint(
        ((removeAsset2Popup.chosenAssetSymbol == lowerToken)
        ? removeLowerEstimate : removeHigherEstimate), removeAsset2Popup.chosenAssetDecimals)
      + " " + removeAsset2Popup.chosenAssetSymbol + "</b>"
    }

    AVMEButton {
      id: liquidityBtn
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (allowance != "" && (
        !qmlSystem.isApproved(removeAsset2Input.text, allowance) ||
        liquidityLPSlider.value > 0
      ))
      text: {
        if (allowance == "") {
          text: "Checking approval..."
        } else if (qmlSystem.isApproved(removeAsset2Input.text, allowance)) {
          text: "Remove from the pool"
        } else {
          text: "Approve"
        }
      }
      /*
      // TODO: this
      onClicked: {
        var acc = qmlSystem.getAccountBalances(qmlSystem.getCurrentAccount())
        if (addToPool) {
          if (!qmlSystem.isApproved(liquidityTokenInput.text, addAllowance)) {
            qmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
            qmlSystem.operationOverride("Approve Exchange", "", "", "")
          } else if (
            qmlSystem.hasInsufficientFunds(
              "Coin", qmlSystem.getRealMaxAVAXAmount("250000", qmlSystem.getAutomaticFee()),
              liquidityCoinInput.text
            ) || qmlSystem.hasInsufficientFunds("Token", acc.balanceAVME, liquidityTokenInput.text)
          ) {
            fundsPopup.open()
          } else {
            qmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
            qmlSystem.operationOverride("Add Liquidity", liquidityCoinInput.text, liquidityTokenInput.text, "")
          }
        } else {
          if (!qmlSystem.isApproved(removeLPEstimate, allowance)) {
            qmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
            qmlSystem.operationOverride("Approve Liquidity", "", "", "")
          } else {
            qmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
            qmlSystem.operationOverride("Remove Liquidity", "", "", removeLPEstimate)
          }
        }
      }
      */
    }
  }
}

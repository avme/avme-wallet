/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import QmlApi 1.0

import "qrc:/qml/components"

// Panel for removing liquidity from: a pool.
AVMEPanel {
  id: removeLiquidityPanel
  title: "Remove Liquidity"
  property string pairAddress
  property string pairBalance
  property string pairAllowance
  property string asset1Reserves
  property string asset2Reserves
  property string userAsset1Reserves
  property string userAsset2Reserves
  property string userLPSharePercentage // TODO: find out where this should be used
  property string removeAsset1Estimate
  property string removeAsset2Estimate
  property string removeLPEstimate
  property alias removeBtn: removeLiquidityBtn

  Connections {
    target: qmlApi
    function onApiRequestAnswered(answer, requestID) {
      var resp = JSON.parse(answer)
      if (requestID == "QmlRemoveLiquidity_fetchPair") {
        pairAddress = qmlApi.parseHex(resp[0].result, ["address"])
        if (pairAddress != "0x0000000000000000000000000000000000000000") {
          fetchBalance()
        } else {
          // TODO: display "no pair available" here
        }
      } else if (requestID == "QmlRemoveLiquidity_fetchBalance") {
        pairBalance = qmlApi.parseHex(resp[0].result, ["uint"])
        fetchAllowance()
      } else if (requestID == "QmlRemoveLiquidity_fetchAllowance") {
        pairAllowance = qmlApi.parseHex(resp[0].result, ["uint"])
        if (+pairAllowance > +pairBalance) { // TODO: block if balance is zero, check with >=
          fetchReserves()
        } else {
          removeLiquidityDetailsColumn.visible = false
        }
      } else if (requestID == "QmlRemoveLiquidity_fetchReserves") {
        var reserves = qmlApi.parseHex(resp[0].result, ["uint", "uint", "uint"])
        var lowerAddress = qmlSystem.getFirstFromPair(
          removeAsset1Popup.chosenAssetAddress, removeAsset2Popup.chosenAssetAddress
        )
        if (lowerAddress == removeAsset1Popup.chosenAssetAddress) {
          asset1Reserves = reserves[0]
          asset2Reserves = reserves[1]
        } else {
          asset2Reserves = reserves[0]
          asset1Reserves = reserves[1]
        }
        var userShares = qmlSystem.calculatePoolShares(
          asset1Reserves, asset2Reserves, pairBalance
        )
        userAsset1Reserves = userShares.lower
        userAsset2Reserves = userShares.higher
        userLPSharePercentage = userShares.liquidity
        removeLiquidityDetailsColumn.visible = (+pairAllowance >= +pairBalance)
      }
    }
  }

  function fetchPair() {
    pairAddress = ""
    qmlApi.clearAPIRequests("QmlRemoveLiquidity_fetchPair")
    qmlApi.buildGetPairReq(
      removeAsset1Popup.chosenAssetAddress,
      removeAsset2Popup.chosenAssetAddress,
      "QmlRemoveLiquidity_fetchPair"
    )
    qmlApi.doAPIRequests("QmlRemoveLiquidity_fetchPair")
  }

  function fetchBalance() {
    pairBalance = ""
    qmlApi.clearAPIRequests("QmlRemoveLiquidity_fetchBalance")
    qmlApi.buildGetTokenBalanceReq(
      pairAddress,
      accountHeader.currentAddress,
      "QmlRemoveLiquidity_fetchBalance"
    )
    qmlApi.doAPIRequests("QmlRemoveLiquidity_fetchBalance")
  }

  function fetchAllowance() {
    pairAllowance = ""
    qmlApi.clearAPIRequests("QmlRemoveLiquidity_fetchAllowance")
    qmlApi.buildGetAllowanceReq(
      pairAddress,
      accountHeader.currentAddress,
      qmlSystem.getContract("router"),
      "QmlRemoveLiquidity_fetchAllowance"
    )
    qmlApi.doAPIRequests("QmlRemoveLiquidity_fetchAllowance")
  }

  function fetchReserves() {
    asset1Reserves = asset2Reserves = ""
    qmlApi.clearAPIRequests("QmlRemoveLiquidity_fetchReserves")
    qmlApi.buildGetReservesReq(pairAddress, "QmlRemoveLiquidity_fetchReserves")
    qmlApi.doAPIRequests("QmlRemoveLiquidity_fetchReserves")
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
      text: (pairBalance != "")
      ? "Balance: <b>" + pairBalance + " " + removeAsset1Popup.chosenAssetSymbol
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
      text: "You need to approve your Account in order to remove <br><b>"
      + removeAsset1Popup.chosenAssetSymbol + "/"
      + removeAsset2Popup.chosenAssetSymbol + " LP</b> from the pool."
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
      top: removeLiquidityHeaderColumn.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      topMargin: 0
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
      enabled: (pairAllowance != "" && asset1Reserves != "" && asset2Reserves != "" && pairBalance != "")
      onMoved: {
        var estimates = qmlSystem.calculateRemoveLiquidityAmount(
          userAsset1Reserves, userAsset2Reserves, value
        )
        removeAsset1Estimate = estimates.lower
        removeAsset2Estimate = estimates.higher
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
        enabled: (pairAllowance != "" && asset1Reserves != "" && asset2Reserves != "" && pairBalance != "")
        width: (parent.parent.width * 0.2)
        text: "25%"
        onClicked: { liquidityLPSlider.value = 25; liquidityLPSlider.moved(); }
      }

      AVMEButton {
        id: sliderBtn50
        enabled: (pairAllowance != "" && asset1Reserves != "" && asset2Reserves != "" && pairBalance != "")
        width: (parent.parent.width * 0.2)
        text: "50%"
        onClicked: { liquidityLPSlider.value = 50; liquidityLPSlider.moved(); }
      }

      AVMEButton {
        id: sliderBtn75
        enabled: (pairAllowance != "" && asset1Reserves != "" && asset2Reserves != "" && pairBalance != "")
        width: (parent.parent.width * 0.2)
        text: "75%"
        onClicked: { liquidityLPSlider.value = 75; liquidityLPSlider.moved(); }
      }

      AVMEButton {
        id: sliderBtn100
        enabled: (pairAllowance != "" && asset1Reserves != "" && asset2Reserves != "" && pairBalance != "")
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
        removeAsset1Estimate, removeAsset1Popup.chosenAssetDecimals
      )
      + " " + removeAsset1Popup.chosenAssetSymbol
      + "<br>" + qmlSystem.weiToFixedPoint(
        removeAsset2Estimate, removeAsset2Popup.chosenAssetDecimals
      )
      + " " + removeAsset2Popup.chosenAssetSymbol + "</b>"
    }

    AVMEButton {
      id: removeLiquidityBtn
      width: parent.width
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (
        pairAllowance != "" && liquidityLPSlider.value > 0 &&
        !qmlSystem.isApproved(removeLPEstimate, pairAllowance)
      )
      text: "Remove from the pool"
      // TODO: transaction logic
    }
  }
}

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
  property string removeAllowance
  property string lowerReserves
  property string higherReserves
  property string liquidity
  property string userLowerReserves
  property string userHigherReserves
  property string removeLowerEstimate
  property string removeHigherEstimate
  property string removeLPEstimate

  QmlApi { id: qmlApi }

  Connections {
    target: accountHeader
    function onUpdatedBalances() { refreshAssetBalance() }  // TODO
  }

  // TODO: connections to QmlApi here

  // TODO: fetchAllowance(?) here

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

    // TODO: total LP amount here

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

  // TODO: column for approval here

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
      enabled: (removeAllowance != "" && lowerReserves != "" && higherReserves != "" && liquidity != "")
      onMoved: {
        var estimates = qmlSystem.calculateRemoveLiquidityAmount(
          userLowerReserves, userHigherReserves, value
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
        enabled: (removeAllowance != "" && lowerReserves != "" && higherReserves != "" && liquidity != "")
        width: (parent.parent.width * 0.2)
        text: "25%"
        onClicked: { liquidityLPSlider.value = 25; liquidityLPSlider.moved(); }
      }

      AVMEButton {
        id: sliderBtn50
        enabled: (removeAllowance != "" && lowerReserves != "" && higherReserves != "" && liquidity != "")
        width: (parent.parent.width * 0.2)
        text: "50%"
        onClicked: { liquidityLPSlider.value = 50; liquidityLPSlider.moved(); }
      }

      AVMEButton {
        id: sliderBtn75
        enabled: (removeAllowance != "" && lowerReserves != "" && higherReserves != "" && liquidity != "")
        width: (parent.parent.width * 0.2)
        text: "75%"
        onClicked: { liquidityLPSlider.value = 75; liquidityLPSlider.moved(); }
      }

      AVMEButton {
        id: sliderBtn100
        enabled: (removeAllowance != "" && lowerReserves != "" && higherReserves != "" && liquidity != "")
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
      enabled: (removeAllowance != "" && (
        !qmlSystem.isApproved(removeAsset2Input.text, removeAllowance) ||
        liquidityLPSlider.value > 0
      ))
      text: {
        if (removeAllowance == "") {
          text: "Checking approval..."
        } else if (qmlSystem.isApproved(removeAsset2Input.text, removeAllowance)) {
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
          if (!qmlSystem.isApproved(removeLPEstimate, removeAllowance)) {
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

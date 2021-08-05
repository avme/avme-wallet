/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Screen for adding/removing liquidity to/from Pangolin pools.
Item {
  id: liquidityScreen
  property string addAllowance
  property string removeAllowance
  property string lowerToken
  property string removeHigherEstimate
  property string removeLPEstimate
  /*
  property string lowerReserves
  property string higherToken
  property string higherReserves
  property string liquidity
  property string userLowerReserves
  property string userHigherReserves
  property string userLPSharePercentage
  property string removeLowerEstimate
  */

  // TODO: get liquidity allowances
  /*
  std::string liquidityAllowance = Pangolin::allowance(
    Pangolin::contracts["AVAX-AVME"],
    this->w.getCurrentAccount().first,
    Pangolin::contracts["router"]
  );
  */

  AVMEPanel {
    id: addLiquidityPanel
    width: (parent.width * 0.5) - (anchors.margins / 2)
    anchors {
      top: parent.top
      left: parent.left
      bottom: parent.bottom
      margins: 10
    }
    title: "Add Liquidity"

    Column {
      id: addLiquidityDetailsColumn
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
            var avmeAddress = QmlSystem.getAVMEAddress()
            if (addAsset1Popup.chosenAssetSymbol == "AVAX") {
              source: "qrc:/img/avax_logo.png"
            } else if (addAsset1Popup.chosenAssetAddress == avmeAddress) {
              source: "qrc:/img/avme_logo.png"
            } else {
              var img = QmlSystem.getARC20TokenImage(addAsset1Popup.chosenAssetAddress)
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
            var avmeAddress = QmlSystem.getAVMEAddress()
            if (addAsset2Popup.chosenAssetSymbol == "AVAX") {
              source: "qrc:/img/avax_logo.png"
            } else if (addAsset2Popup.chosenAssetAddress == avmeAddress) {
              source: "qrc:/img/avme_logo.png"
            } else {
              var img = QmlSystem.getARC20TokenImage(addAsset2Popup.chosenAssetAddress)
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

      Text {
        id: assetBalance
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Total amounts: <br><b>"
        + ((addAsset1Popup.chosenAssetSymbol == "AVAX")
        ? accountHeader.coinRawBalance
        : +accountHeader.tokenList[addAsset1Popup.chosenAssetAddress]["rawBalance"])
        + " " + addAsset1Popup.chosenAssetSymbol + "<br>"
        + ((addAsset2Popup.chosenAssetSymbol == "AVAX")
        ? accountHeader.coinRawBalance
        : +accountHeader.tokenList[addAsset2Popup.chosenAssetAddress]["rawBalance"])
        + " " + addAsset2Popup.chosenAssetSymbol + "</b>"
      }

      AVMEInput {
        id: addAsset1Input
        width: parent.width
        enabled: (addAllowance != "")
        validator: RegExpValidator {
          regExp: QmlSystem.createTxRegExp(addAsset1Popup.chosenAssetDecimals)
        }
        label: addAsset1Popup.chosenAssetSymbol + " Amount"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: calculateAddLiquidityAmount(true)
      }

      AVMEInput {
        id: addAsset2Input
        width: parent.width
        enabled: (addAllowance != "")
        validator: RegExpValidator {
          regExp: QmlSystem.createTxRegExp(addAsset2Popup.chosenAssetDecimals)
        }
        label: addAsset2Popup.chosenAssetSymbol + " Amount"
        placeholder: "Fixed point amount (e.g. 0.5)"
        onTextEdited: calculateAddLiquidityAmount(false)
      }

      AVMEButton {
        id: addMaxBtn
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Max Amounts"
        enabled: (addAllowance != "")
        onClicked: calculateMaxAddLiquidityAmount()
      }

      // TODO: change asset input for checks for both assets
      AVMEButton {
        id: addLiquidityBtn
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (addAllowance != "" && (
          !QmlSystem.isApproved(addAsset2Input.text, addAllowance) ||
          (addAsset1Input.acceptableInput && addAsset2Input.acceptableInput)
        ))
        text: {
          if (addAllowance == "") {
            text: "Checking approval..."
          } else if (QmlSystem.isApproved(addAsset2Input.text, addAllowance)) {
            text: "Add to the pool"
          } else {
            text: "Approve"
          }
        }
        /*
        // TODO: this
        onClicked: {
          var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
          if (addToPool) {
            if (!QmlSystem.isApproved(liquidityTokenInput.text, addAllowance)) {
              QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              QmlSystem.operationOverride("Approve Exchange", "", "", "")
            } else if (
              QmlSystem.hasInsufficientFunds(
                "Coin", QmlSystem.getRealMaxAVAXAmount("250000", QmlSystem.getAutomaticFee()),
                liquidityCoinInput.text
              ) || QmlSystem.hasInsufficientFunds("Token", acc.balanceAVME, liquidityTokenInput.text)
            ) {
              fundsPopup.open()
            } else {
              QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              QmlSystem.operationOverride("Add Liquidity", liquidityCoinInput.text, liquidityTokenInput.text, "")
            }
          } else {
            if (!QmlSystem.isApproved(removeLPEstimate, removeAllowance)) {
              QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              QmlSystem.operationOverride("Approve Liquidity", "", "", "")
            } else {
              QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              QmlSystem.operationOverride("Remove Liquidity", "", "", removeLPEstimate)
            }
          }
        }
        */
      }
    }
  }

  AVMEPanel {
    id: removeLiquidityPanel
    width: (parent.width * 0.5) - (anchors.margins / 2)
    anchors {
      top: parent.top
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
    title: "Remove Liquidity"

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
            var avmeAddress = QmlSystem.getAVMEAddress()
            if (removeAsset1Popup.chosenAssetSymbol == "AVAX") {
              source: "qrc:/img/avax_logo.png"
            } else if (removeAsset1Popup.chosenAssetAddress == avmeAddress) {
              source: "qrc:/img/avme_logo.png"
            } else {
              var img = QmlSystem.getARC20TokenImage(removeAsset1Popup.chosenAssetAddress)
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
            var avmeAddress = QmlSystem.getAVMEAddress()
            if (removeAsset2Popup.chosenAssetSymbol == "AVAX") {
              source: "qrc:/img/avax_logo.png"
            } else if (removeAsset2Popup.chosenAssetAddress == avmeAddress) {
              source: "qrc:/img/avme_logo.png"
            } else {
              var img = QmlSystem.getARC20TokenImage(removeAsset2Popup.chosenAssetAddress)
              source: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
            }
          }
        }
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

      // TODO: total LP amount here

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
          var estimates = QmlSystem.calculateRemoveLiquidityAmount(
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

      // TODO: "advanced" mode (manual input instead of a slider)
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
        + "<b>" + QmlSystem.weiToFixedPoint(
          ((removeAsset1Popup.chosenAssetSymbol == lowerToken)
          ? removeLowerEstimate : removeHigherEstimate), removeAsset1Popup.chosenAssetDecimals)
        + " " + removeAsset1Popup.chosenAssetSymbol
        + "<br>" + QmlSystem.weiToFixedPoint(
          ((removeAsset2Popup.chosenAssetSymbol == lowerToken)
          ? removeLowerEstimate : removeHigherEstimate), removeAsset2Popup.chosenAssetDecimals)
        + " " + removeAsset2Popup.chosenAssetSymbol + "</b>"
      }

      AVMEButton {
        id: liquidityBtn
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (removeAllowance != "" && (
          !QmlSystem.isApproved(removeAsset2Input.text, removeAllowance) ||
          liquidityLPSlider.value > 0
        ))
        text: {
          if (removeAllowance == "") {
            text: "Checking approval..."
          } else if (QmlSystem.isApproved(removeAsset2Input.text, removeAllowance)) {
            text: "Remove from the pool"
          } else {
            text: "Approve"
          }
        }
        /*
        // TODO: this
        onClicked: {
          var acc = QmlSystem.getAccountBalances(QmlSystem.getCurrentAccount())
          if (addToPool) {
            if (!QmlSystem.isApproved(liquidityTokenInput.text, addAllowance)) {
              QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              QmlSystem.operationOverride("Approve Exchange", "", "", "")
            } else if (
              QmlSystem.hasInsufficientFunds(
                "Coin", QmlSystem.getRealMaxAVAXAmount("250000", QmlSystem.getAutomaticFee()),
                liquidityCoinInput.text
              ) || QmlSystem.hasInsufficientFunds("Token", acc.balanceAVME, liquidityTokenInput.text)
            ) {
              fundsPopup.open()
            } else {
              QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              QmlSystem.operationOverride("Add Liquidity", liquidityCoinInput.text, liquidityTokenInput.text, "")
            }
          } else {
            if (!QmlSystem.isApproved(removeLPEstimate, removeAllowance)) {
              QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              QmlSystem.operationOverride("Approve Liquidity", "", "", "")
            } else {
              QmlSystem.setScreen(content, "qml/screens/TransactionScreen.qml")
              QmlSystem.operationOverride("Remove Liquidity", "", "", removeLPEstimate)
            }
          }
        }
        */
      }
    }
  }

  // Popups for choosing the assets for adding/removing liquidity.
  // Defaults to the "AVAX/AVME" pool for both cases.
  AVMEPopupAssetSelect { id: addAsset1Popup; defaultToAVME: false }
  AVMEPopupAssetSelect { id: addAsset2Popup; defaultToAVME: true }
  AVMEPopupAssetSelect { id: removeAsset1Popup; defaultToAVME: false }
  AVMEPopupAssetSelect { id: removeAsset2Popup; defaultToAVME: true }
}

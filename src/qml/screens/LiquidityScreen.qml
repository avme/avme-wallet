/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

// Screen for adding/removing liquidity to/from Pangolin pools.
Item {
  id: liquidityScreen

  AVMEPanelAddLiquidity {
    id: addLiquidityPanel
    width: (parent.width * 0.5) - (anchors.margins / 2)
    anchors {
      top: parent.top
      left: parent.left
      bottom: parent.bottom
      margins: 10
    }
  }

  AVMEPanelRemoveLiquidity {
    id: removeLiquidityPanel
    width: (parent.width * 0.5) - (anchors.margins / 2)
    anchors {
      top: parent.top
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
  }

  // Popups for choosing the assets for adding/removing liquidity.
  // Defaults to the "AVAX/AVME" pool for both cases.
  // TODO: activate fetch allowances on panels
  // (can't use Component.onCompleted, there has to be another way)
  AVMEPopupAssetSelect {
    id: addAsset1Popup
    defaultToAVME: false
    onAboutToHide: {
      if (chosenAssetAddress == addAsset2Popup.chosenAssetAddress) {
        if (chosenAssetAddress == qmlSystem.getContract("AVAX")) {
          addAsset2Popup.forceAVME()
        } else {
          addAsset2Popup.forceAVAX()
        }
      }
      addLiquidityPanel.fetchAllowance()
    }
  }
  AVMEPopupAssetSelect {
    id: addAsset2Popup
    defaultToAVME: true
    onAboutToHide: {
      if (chosenAssetAddress == addAsset1Popup.chosenAssetAddress) {
        if (chosenAssetAddress == qmlSystem.getContract("AVAX")) {
          addAsset1Popup.forceAVME()
        } else {
          addAsset1Popup.forceAVAX()
        }
      }
      addLiquidityPanel.fetchAllowance()
    }
  }
  AVMEPopupAssetSelect {
    id: removeAsset1Popup
    defaultToAVME: false
    onAboutToHide: {
      if (chosenAssetAddress == removeAsset2Popup.chosenAssetAddress) {
        if (chosenAssetAddress == qmlSystem.getContract("AVAX")) {
          removeAsset2Popup.forceAVME()
        } else {
          removeAsset2Popup.forceAVAX()
        }
      }
      removeLiquidityPanel.fetchPairAndReserves()
    }
  }
  AVMEPopupAssetSelect {
    id: removeAsset2Popup
    defaultToAVME: true
    onAboutToHide: {
      if (chosenAssetAddress == removeAsset1Popup.chosenAssetAddress) {
        if (chosenAssetAddress == qmlSystem.getContract("AVAX")) {
          removeAsset1Popup.forceAVME()
        } else {
          removeAsset1Popup.forceAVAX()
        }
      }
      removeLiquidityPanel.fetchPairAndReserves()
    }
  }

  // Popup for insufficient funds
  AVMEPopupInfo {
    id: fundsPopup
    icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your inputs."
  }

  // Popups for confirming approval/add/removal, respectively
  AVMEPopupConfirmTx {
    id: confirmAddApprovalPopup
    info: "You will approve "
    + (!addLiquidityPanel.asset1Approved) ? addAsset1Popup.chosenAssetSymbol : ""
    + (!addLiquidityPanel.asset1Approved && !addLiquidityPanel.asset2Approved) ? " and " : ""
    + (!addLiquidityPanel.asset2Approved) ? addAsset2Popup.chosenAssetSymbol : ""
    + " to be added to the pool for the current address<br>"
    + "<br>Gas Limit: <b>"
    + qmlSystem.weiToFixedPoint(
      (!addLiquidityPanel.asset1Approved && !addLiquidityPanel.asset2Approved)
      ? "320000" : "180000", 18
    ) + " AVAX</b>"
    + "<br>Gas Price: <b>"
    + qmlSystem.weiToFixedPoint(qmlSystem.getAutomaticFee(), 9) + " AVAX</b>"
    okBtn.onClicked: {} // TODO
  }
  AVMEPopupConfirmTx {
    id: confirmRemoveApprovalPopup
    info: "You will approve "
    + "<b>" + removeAsset1Popup.chosenAssetSymbol + "/"
    + removeAsset2Popup.chosenAssetSymbol + " LP</b>"
    + " to be removed from the pool for the current address<br>"
    + "<br>Gas Limit: <b>"
    + qmlSystem.weiToFixedPoint("180000", 18) + " AVAX</b>"
    + "<br>Gas Price: <b>"
    + qmlSystem.weiToFixedPoint(qmlSystem.getAutomaticFee(), 9) + " AVAX</b>"
    okBtn.onClicked: {} // TODO
  }
  AVMEPopupConfirmTx {
    id: confirmAddLiquidityPopup
    info: "You will add "
    + "<b>" + addLiquidityPanel.add1Amount + " " + addAsset1Popup.chosenAssetSymbol + "</b><br>and <b>"
    + addLiquidityPanel.add2Amount + " " + addAsset2Popup.chosenAssetSymbol + "</b> to the pool"
    + "<br>Gas Limit: <b>"
    + qmlSystem.weiToFixedPoint("250000", 18) + " AVAX</b>"
    + "<br>Gas Price: <b>"
    + qmlSystem.weiToFixedPoint(qmlSystem.getAutomaticFee(), 9) + " AVAX</b>"
    okBtn.onClicked: {} // TODO
  }
  AVMEPopupConfirmTx {
    id: confirmRemoveLiquidityPopup
    info: "You will remove "
    + "<b>" + removeLiquidityPanel.removeLPEstimate + " "
    + removeAsset1Popup.chosenAssetSymbol + "/" + removeAsset2Popup.chosenAssetSymbol
    + " LP</b> from the pool"
    + "<br>Gas Limit: <b>"
    + qmlSystem.weiToFixedPoint("250000", 18) + " AVAX</b>"
    + "<br>Gas Price: <b>"
    + qmlSystem.weiToFixedPoint(qmlSystem.getAutomaticFee(), 9) + " AVAX</b>"
    okBtn.onClicked: {} // TODO
  }
}

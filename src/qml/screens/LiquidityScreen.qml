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
  /*
  property string lowerToken
  property string higherToken
  property string userLPSharePercentage
  */

  // TODO: get liquidity allowances
  /*
  std::string liquidityAllowance = Pangolin::allowance(
    Pangolin::contracts["AVAX-AVME"],
    this->w.getCurrentAccount().first,
    Pangolin::contracts["router"]
  );
  */

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
      // TODO: fetch add allowances here
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
      // TODO: fetch add allowances here
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
      // TODO: fetch remove allowances here
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
      // TODO: fetch remove allowances here
    }
  }

  // TODO: popups for insufficient funds and confirming approval/add/removal here
}

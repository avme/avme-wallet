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

  // op = "approval_add", "approval_remove", "add" or "remove"
  function checkLedger(op) {
    var data = qmlSystem.checkForLedger()
    if (data.state) {
      ledgerFailPopup.close()
      ledgerRetryTimer.stop()
      if (op == "approval_add") {
        confirmAddApprovalPopup.open()
      } else if (op == "approval_remove") {
        confirmRemoveApprovalPopup.open()
      } else if (op == "add") {
        confirmAddLiquidityPopup.open()
      } else if (op == "remove") {
        confirmRemoveLiquidityPopup.open()
      }
    } else {
      ledgerFailPopup.info = data.message
      ledgerFailPopup.open()
      ledgerRetryTimer.start()
    }
  }

  Timer { id: ledgerRetryTimer; interval: 250; onTriggered: parent.checkLedger() }

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
  Item {
    property bool addAsset1Loaded: false
    property bool addAsset2Loaded: false
    function checkPopups() {
      if (addAsset1Loaded && addAsset2Loaded) { addLiquidityPanel.fetchAllowancesAndPair() }
    }

    AVMEPopupAssetSelect {
      id: addAsset1Popup
      defaultToAVME: false
      Component.onCompleted: { parent.addAsset1Loaded = true; parent.checkPopups() }
      onAboutToHide: {
        if (chosenAssetAddress == addAsset2Popup.chosenAssetAddress) {
          if (chosenAssetAddress == qmlSystem.getContract("AVAX")) {
            addAsset2Popup.forceAVME()
          } else {
            addAsset2Popup.forceAVAX()
          }
        }
        addLiquidityPanel.fetchAllowancesAndPair()
      }
    }
    AVMEPopupAssetSelect {
      id: addAsset2Popup
      defaultToAVME: true
      Component.onCompleted: { parent.addAsset2Loaded = true; parent.checkPopups() }
      onAboutToHide: {
        if (chosenAssetAddress == addAsset1Popup.chosenAssetAddress) {
          if (chosenAssetAddress == qmlSystem.getContract("AVAX")) {
            addAsset1Popup.forceAVME()
          } else {
            addAsset1Popup.forceAVAX()
          }
        }
        addLiquidityPanel.fetchAllowancesAndPair()
      }
    }
  }

  Item {
    property bool removeAsset1Loaded: false
    property bool removeAsset2Loaded: false
    function checkPopups() {
      if (removeAsset1Loaded && removeAsset2Loaded) { removeLiquidityPanel.fetchPair() }
    }
    AVMEPopupAssetSelect {
      id: removeAsset1Popup
      defaultToAVME: false
      Component.onCompleted: { parent.removeAsset1Loaded = true; parent.checkPopups() }
      onAboutToHide: {
        if (chosenAssetAddress == removeAsset2Popup.chosenAssetAddress) {
          if (chosenAssetAddress == qmlSystem.getContract("AVAX")) {
            removeAsset2Popup.forceAVME()
          } else {
            removeAsset2Popup.forceAVAX()
          }
        }
        removeLiquidityPanel.fetchPair()
      }
    }
    AVMEPopupAssetSelect {
      id: removeAsset2Popup
      defaultToAVME: true
      Component.onCompleted: { parent.removeAsset2Loaded = true; parent.checkPopups() }
      onAboutToHide: {
        if (chosenAssetAddress == removeAsset1Popup.chosenAssetAddress) {
          if (chosenAssetAddress == qmlSystem.getContract("AVAX")) {
            removeAsset1Popup.forceAVME()
          } else {
            removeAsset1Popup.forceAVAX()
          }
        }
        removeLiquidityPanel.fetchPair()
      }
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
    id: confirmAddApprovalAsset1Popup
  }
  AVMEPopupConfirmTx {
    id: confirmAddApprovalAsset2Popup
  }


  AVMEPopupConfirmTx {
    id: confirmRemoveApprovalPopup
    info: "You will approve "
    + "<b>" + removeAsset1Popup.chosenAssetSymbol + "/"
    + removeAsset2Popup.chosenAssetSymbol + " LP</b>"
    + " to be removed from the pool for the current address"
  }
  AVMEPopupConfirmTx {
    id: confirmAddLiquidityPopup
    info: "You will add "
    + "<b>" + addLiquidityPanel.add1Amount + " " + addAsset1Popup.chosenAssetSymbol
    + "</b><br>and <b>"
    + addLiquidityPanel.add2Amount + " " + addAsset2Popup.chosenAssetSymbol
    + "</b> to the pool"
  }
  AVMEPopupConfirmTx {
    id: confirmRemoveLiquidityPopup
    info: "You will remove "
    + "<b>" + removeLiquidityPanel.removeLPEstimate + " "
    + removeAsset1Popup.chosenAssetSymbol + "/" + removeAsset2Popup.chosenAssetSymbol
    + " LP</b> from the pool"
  }

  AVMEPopupTxProgress {
    id: txProgressPopup
  }

  // Info popup for if communication with Ledger fails
  AVMEPopupInfo {
    id: ledgerFailPopup
    icon: "qrc:/img/warn.png"
    onAboutToHide: ledgerRetryTimer.stop()
    okBtn.text: "Close"
  }
}

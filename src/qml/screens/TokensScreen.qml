/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

// Screen for managing the Wallet's registered tokens.
Item {
  id: tokensScreen
  property alias selectedToken: tokensPanel.selectedToken

  // Panel for managing the ARC20 tokens (view/add/remove)
  AVMEPanelTokens {
    id: tokensPanel
    width: (parent.width * 0.6)
    anchors {
      top: parent.top
      bottom: parent.bottom
      left: parent.left
      margins: 10
    }
    addTokenBtn.onClicked: addTokenPopup.open()
    removeTokenBtn.onClicked: confirmEraseTokenPopup.open()
  }

  // Panel for the details of the selected ARC20 token
  AVMEPanelTokenDetails {
    id: tokenDetailsPanel
    width: (parent.width * 0.4)
    anchors {
      top: parent.top
      bottom: parent.bottom
      right: parent.right
      margins: 10
    }
  }

  // Popup for adding a new token
  AVMEPopupTokenAdd {
    id: addTokenPopup
    widthPct: 0.4
    heightPct: 0.7
  }

  // Popup for confirming token removal
  AVMEPopupYesNo {
    id: confirmEraseTokenPopup
    widthPct: 0.4
    heightPct: 0.25
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to remove this token?"
    yesBtn.onClicked: {
      qmlSystem.removeARC20Token(selectedToken.itemAddress);
      confirmEraseTokenPopup.close()
      tokensPanel.reloadTokens()
    }
    noBtn.onClicked: {
      confirmEraseTokenPopup.close()
    }
  }
}

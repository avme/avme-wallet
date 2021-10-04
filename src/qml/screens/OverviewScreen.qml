/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtCharts 2.2

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

// Screen for showing a general overview for the chosen Account.
Item {
  id: overviewScreen

  AVMEOverviewBalance {
    id: overviewBalance
    width: (parent.width * 0.6)
    height: (parent.height * 0.2)
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
      margins: 10
    }
  }

  AVMEPanelOverview {
    id: overviewPanel
    width: (parent.width * 0.6)
    height: (parent.height * 0.75)
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      margins: 10
    }
  }

  // "qrcodeWidth = 0" doesn't let the program open, leave it at 1
  AVMEPopupQRCode {
    id: qrcodePopup
    qrcodeWidth: (overviewBalance.currentAccount != "")
    ? qmlSystem.getQRCodeSize(overviewBalance.currentAccount) : 1
    textAddress.text: overviewBalance.currentAccount
  }
}

/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/panels"
import "qrc:/qml/popups"

Item {
  id: exchangeScreen
  anchors.fill: parent

  property string augustusSwapper: "0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57"
  property string tokenProxy: "0x216B4B4Ba9F3e719726886d34a177484278Bfcae"
  AVMEAsyncImage {
    id: logoBg
    width: 400
    height: 400
    z: 0
    anchors { left: parent.left; bottom: parent.bottom }
    imageOpacity: 0.15
    imageSource: "qrc:/img/ParaSwap_logo.png"
  }

  AVMEPopupInfo {
    id: fundsPopup; icon: "qrc:/img/warn.png"
    info: "Insufficient funds. Please check your inputs."
  }
  AVMEPopupExchangeSettings { id: slippageSettings }
  AVMEPopupConfirmTx { id: confirmTransactionPopup }
  AVMEPopupTxProgress { id: txProgressPopup }
  
  AVMEPanelExchange {
    id: exchangePanel
    height: parent.height * 0.8
    width: parent.width * 0.4
    anchors.centerIn: parent

  }
}

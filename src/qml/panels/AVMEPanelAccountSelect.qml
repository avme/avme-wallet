/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

AVMEPanel {
  id: accountSelectPanel
  title: "ACCOUNTS"
  Rectangle {
    anchors.fill: parent
    anchors.topMargin: parent.height * 0.175
    anchors.bottomMargin: parent.height * 0.25
    anchors.leftMargin: parent.width * 0.05
    anchors.rightMargin: parent.width * 0.05
    color: "transparent"
    
    AVMEWalletList {
      id: walletList
      anchors.fill: parent
      model: walletListModel
    }
  }
  Row {
    id: selectWalletBtnRow
    anchors.bottom: parent.bottom
    anchors.bottomMargin: parent.height * 0.1
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width * 0.8
    height: parent.height * 0.075
    AVMEButton {
      id: createImportBtn
      width: parent.width / 5
      height: parent.height
      text: "Create / Import New"
      anchors.left: parent.left
    }
    AVMEButton {
      id: selectAccountBtn
      width: parent.width / 5
      height: parent.height
      text: "Use This Account"
      anchors.horizontalCenter: parent.horizontalCenter
    }
    AVMEButton {
      id: eraseAccountBtn
      width: parent.width / 5
      height: parent.height
      text: "Erase This Account"
      anchors.right: parent.right
    }
  }
}

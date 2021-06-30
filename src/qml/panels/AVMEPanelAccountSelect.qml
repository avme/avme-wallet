/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

AVMEPanel {
  id: accountSelectPanel
  property alias accountList: walletModel
  property alias btnCreate: createImportBtn
  property alias btnSelect: selectAccountBtn
  property alias btnErase: eraseAccountBtn
  title: "Accounts"

  Rectangle {
    id: selectWalletAccountRect
    color: "transparent"
    anchors {
      fill: parent
      topMargin: parent.height * 0.2
      bottomMargin: parent.height * 0.2
      leftMargin: parent.width * 0.05
      rightMargin: parent.width * 0.05
    }

    AVMEWalletList {
      id: walletList
      anchors.fill: parent
      model: ListModel { id: walletModel }
    }
  }

  Row {
    id: selectWalletBtnRow
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      bottomMargin: 50
    }
    spacing: 50

    AVMEButton {
      id: createImportBtn
      width: 200
      text: "Create / Import New"
    }
    AVMEButton {
      id: selectAccountBtn
      width: 200
      text: "Use This Account"
    }
    AVMEButton {
      id: eraseAccountBtn
      width: 200
      text: "Erase This Account"
    }
  }
}

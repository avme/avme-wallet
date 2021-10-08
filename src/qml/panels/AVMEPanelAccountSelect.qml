/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

AVMEPanel {
  id: accountSelectPanel
  property alias accountList: walletList
  property alias accountModel: walletModel
  property alias btnAdd: addBtn
  property alias btnSelect: selectBtn
  property alias btnErase: eraseBtn
  title: "Your Accounts"

  // Enter/Return key override
  Keys.onPressed: {
    if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
      if (btnSelect.enabled) { chooseSelectedAccount() }
    }
  }

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
      model: ListModel {
        id: walletModel
        function sortByAddress() {
          for (var i = 0; i < count; i++) {
            for (var j = 0; j < i; j++) {
              if (get(i).address < get(j).address) { move(i, j, 1) }
            }
          }
        }
      }
    }
  }

  Row {
    id: selectWalletBtnRow
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      bottomMargin: 50
    }
    spacing: 20

    AVMEButton {
      id: addBtn
      width: (accountSelectPanel.width * 0.15) + (parent.spacing)
      text: "Add New Account"
    }
    AVMEButton {
      id: selectBtn
      width: (accountSelectPanel.width * 0.15) + (parent.spacing)
      text: "Select This Account"
    }
    AVMEButton {
      id: eraseBtn
      width: (accountSelectPanel.width * 0.15) + (parent.spacing)
      text: "Erase This Account"
    }
  }
}

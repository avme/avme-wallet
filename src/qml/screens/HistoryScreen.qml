/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Screen for showing the transaction history for the Account
Item {
  id: historyScreen
  property bool sortByNew: true

  Connections {
    target: qmlSystem
    function onHistoryLoaded(data) {
      if (data != null) {
        if (sortByNew) {
          for (var i = (data.length - 1); i >= 0; i--) {
            historyModel.append(JSON.parse(data[i]))
          }
        } else {
          for (var i = 0; i < data.length; i++) {
            historyModel.append(JSON.parse(data[i]))
          }
        }
      }
      if (historyList.count == 0) {
        infoText.text = "No transactions made yet.<br>Once you make one, it'll appear here."
      } else {
        infoText.text = ""
        infoText.visible = false
      }
    }
  }

  Component.onCompleted: reloadTransactions()

  function reloadTransactions() {
    historyModel.clear()
    infoText.text = "Loading transactions..."
    infoText.visible = true
    qmlSystem.updateTransactionStatus()
    qmlSystem.listAccountTransactions(qmlSystem.getCurrentAccount())
  }

  // Transaction list
  Row {
    id: listBtnRow
    width: (parent.width * 0.4) - (anchors.margins * 2)
    anchors {
      top: parent.top
      left: parent.left
      margins: 10
    }
    spacing: 10

    AVMEButton {
      id: btnSort
      width: (parent.width * 0.7) - parent.spacing
      text: (sortByNew) ? "Sorted by Newer" : "Sorted by Older"
      onClicked: {
        sortByNew = !sortByNew
        reloadTransactions()
      }
    }

    AVMEButton {
      id: btnRefresh
      width: parent.width * 0.3
      text: "Refresh"
      onClicked: reloadTransactions()
    }
  }

  // The list itself
  Rectangle {
    id: listRect
    width: (parent.width * 0.4) - (anchors.margins * 2)
    anchors {
      top: listBtnRow.bottom
      bottom: parent.bottom
      left: parent.left
      margins: 10
    }
    radius: 5
    color: "#4458A0C9"

    AVMETxHistoryList {
      id: historyList
      anchors.fill: parent
      model: ListModel { id: historyModel }
    }
  }

  // Transaction details panel
  AVMEPanel {
    id: historyPanel
    width: (parent.width * 0.6) - (anchors.margins * 2)
    anchors {
      top: parent.top
      bottom: parent.bottom
      right: parent.right
      margins: 10
    }
    title: "Transaction Details"

    Column {
      id: historyColumn
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
      spacing: 20

      Text {
        id: infoText
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 18.0
        visible: false
      }

      AVMEButton {
        id: btnOpenLink
        width: parent.width
        visible: (historyList.currentItem)
        text: "Open Transaction in Block Explorer"
        onClicked: Qt.openUrlExternally(historyList.currentItem.itemTxLink)
      }

      Text {
        id: detailsText
        elide: Text.ElideRight
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: (historyList.currentItem)
        ? "<b>Operation:</b> " + historyList.currentItem.itemOperation + "<br><br>"
        + "<b>From:</b> " + historyList.currentItem.itemFrom + "<br><br>"
        + "<b>To:</b> " + historyList.currentItem.itemTo + "<br><br>"
        + "<b>Value:</b> " + historyList.currentItem.itemValue + "<br><br>"
        + "<b>Gas:</b> " + historyList.currentItem.itemGas + "<br><br>"
        + "<b>Price:</b> " + historyList.currentItem.itemPrice + "<br><br>"
        + "<b>Timestamp:</b> " + historyList.currentItem.itemDateTime + "<br><br>"
        + "<b>Confirmed:</b> " + historyList.currentItem.itemConfirmed + "<br><br>"
        + "<b>Invalid:</b> " + historyList.currentItem.itemInvalid
        : ""
      }
    }
  }
}

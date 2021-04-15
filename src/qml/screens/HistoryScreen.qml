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

  Component.onCompleted: reloadTransactions()

  function reloadTransactions() {
    historyModel.clear()
    var txList = System.listAccountTransactions(System.getTxSenderAccount())
    if (txList != null) {
      if (sortByNew) {
        for (var i = (txList.length - 1); i >= 0; i--) {
          historyModel.append(JSON.parse(txList[i]))
        }
      } else {
        for (var i = 0; i < txList.length; i++) {
          historyModel.append(JSON.parse(txList[i]))
        }
      }
    }
  }

  Rectangle {
    id: accountHeaderRow
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      margins: 10
    }
    height: 50
    color: "#1D212A"
    radius: 10

    Text {
      id: addressText
      anchors {
        verticalCenter: parent.verticalCenter
        left: parent.left
        leftMargin: 10
      }
      color: "#FFFFFF"
      text: System.getTxSenderAccount()
      font.pointSize: 16.0
    }

    AVMEButton {
      id: btnSort
      width: (parent.width * 0.2)
      anchors {
        verticalCenter: parent.verticalCenter
        right: btnRefresh.left
        rightMargin: 10
      }
      text: (sortByNew) ? "Sorted by Newer" : "Sorted by Older"
      onClicked: {
        sortByNew = !sortByNew
        reloadTransactions()
      }
    }

    AVMEButton {
      id: btnRefresh
      width: (parent.width * 0.1)
      anchors {
        verticalCenter: parent.verticalCenter
        right: parent.right
        rightMargin: 10
      }
      text: "Refresh"
      onClicked: reloadTransactions()
    }
  }

  // Transaction list
  Rectangle {
    id: listRect
    width: (parent.width * 0.35) + anchors.margins
    anchors {
      top: accountHeaderRow.bottom
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
    width: (parent.width * 0.6) + anchors.margins
    anchors {
      top: accountHeaderRow.bottom
      bottom: parent.bottom
      right: parent.right
      margins: 10
    }
    title: "Transaction Details"

    Column {
      id: historyColumn
      anchors {
        top: parent.header.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: 20
      }
      spacing: 20

      // Text if there's no transactions made with the Account
      Text {
        id: noTxText
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pointSize: 18.0
        text: "No transactions made yet.<br>Once you make one, it'll appear here."
        visible: (historyList.count == 0)
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
        font.pointSize: 14.0
        text: (historyList.currentItem)
        ? "<b>Operation:</b> " + historyList.currentItem.itemOperation + "<br><br>"
        + "<b>From:</b> " + historyList.currentItem.itemFrom + "<br><br>"
        + "<b>To:</b> " + historyList.currentItem.itemTo + "<br><br>"
        + "<b>Value:</b> " + historyList.currentItem.itemValue + "<br><br>"
        + "<b>Gas:</b> " + historyList.currentItem.itemGas + "<br><br>"
        + "<b>Price:</b> " + historyList.currentItem.itemPrice + "<br><br>"
        + "<b>Timestamp:</b> " + historyList.currentItem.itemDateTime + "<br><br>"
        + "<b>Confirmed:</b> " + historyList.currentItem.itemConfirmed
        : ""
      }
    }
  }
}

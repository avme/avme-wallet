/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Screen for showing the transaction history for the Account
Item {
  id: historyScreen
  property bool sortByNew: true

  Connections {
    target: qmlSystem
    function onHistoryLoaded(dataStr) {
      console.log("signal ok")
      historyModel.clear()
      if (dataStr != null) {
        var data = JSON.parse(dataStr)
        for (var i = 0; i < data.length; i++) {
          historyModel.append(data[i])
        }
        historyModel.sortByTimestamp()
        historyList.currentIndex = 0
      }
      if (historyModel.count > 0) {
        infoText.text = ""
        infoText.visible = false
      } else {
        infoText.text = "No transactions made yet.<br>Once you make one, it'll appear here."
        infoText.visible = true
      }
    }
  }

  Component.onCompleted: reloadTransactions()

  function reloadTransactions() {
    historyModel.clear()
    infoText.text = "Loading transactions..."
    infoText.visible = true
    qmlSystem.listAccountTransactions(qmlSystem.getCurrentAccount())
  }

  AVMEButton {
    id: eraseAllBtn
    width: (parent.width * 0.5) - (anchors.margins * 2)
    enabled: (historyModel.count > 0)
    anchors {
      top: parent.top
      left: parent.left
      margins: 10
    }
    text: "Erase All History"
    onClicked: eraseHistoryPopup.open()
  }

  // The list itself
  Rectangle {
    id: listRect
    width: (parent.width * 0.5) - (anchors.margins * 2)
    anchors {
      top: eraseAllBtn.bottom
      bottom: parent.bottom
      left: parent.left
      margins: 10
    }
    radius: 5
    color: "#4458A0C9"

    AVMETxHistoryList {
      id: historyList
      anchors.fill: parent
      model: ListModel {
        id: historyModel
        function sortByTimestamp() {
          for (var i = 0; i < count; i++) {
            for (var j = 0; j < i; j++) {
              if (get(i).unixtime > get(j).unixtime) { move(i, j, 1) }
            }
          }
        }
      }
    }
  }

  // Transaction details panel
  AVMEPanel {
    id: historyPanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
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

      AVMEButton {
        id: btnCheckStatus
        width: parent.width
        visible: (historyList.currentItem)
        text: "Refresh Transaction Status"
        onClicked: {
          qmlSystem.updateTxStatus(historyList.currentItem.itemHash)
          qmlSystem.listAccountTransactions(qmlSystem.getCurrentAccount())
        }
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

  AVMEPopupYesNo {
    id: eraseHistoryPopup
    widthPct: 0.55
    heightPct: 0.25
    icon: "qrc:/img/warn.png"
    info: "Are you sure you want to erase your transaction history?"
    + "<br>All data will be <b>permanently lost</b>."
    yesBtn.onClicked: {
      qmlSystem.eraseAllHistory()
      eraseHistoryPopup.close()
      qmlSystem.listAccountTransactions(qmlSystem.getCurrentAccount())
    }
    noBtn.onClicked: eraseHistoryPopup.close()
  }
}

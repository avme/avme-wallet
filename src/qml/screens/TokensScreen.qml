/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/popups"

// Screen for managing the Wallet's registered tokens.
Item {
  id: tokensScreen
  property string avmeAddress: QmlSystem.getAVMEAddress()
  property alias selectedToken: tokenGrid.currentItem

  Component.onCompleted: reloadTokens()

  function reloadTokens() {
    tokenList.clear()
    QmlSystem.loadARC20Tokens()
    var tokens = QmlSystem.getARC20Tokens()
    for (var i = 0; i < tokens.length; i++) {
      tokenList.append(tokens[i]);
    }
    tokenList.sortBySymbol()
  }

  AVMEPanel {
    id: tokensPanel
    width: (parent.width * 0.6)
    title: "Token List"
    anchors {
      top: parent.top
      bottom: parent.bottom
      left: parent.left
      margins: 10
    }

    AVMETokenGrid {
      id: tokenGrid
      width: (parent.width * 0.9)
      anchors {
        top: parent.top
        bottom: btnRow.top
        horizontalCenter: parent.horizontalCenter
        topMargin: 80
        bottomMargin: 20
      }
      model: ListModel {
        id: tokenList
        function sortBySymbol() {
          for (var i = 0; i < count; i++) {
            for (var j = 0; j < i; j++) {
              if (get(i).symbol < get(j).symbol) { move(i, j, 1) }
            }
          }
        }
      }
    }

    Row {
      id: btnRow
      anchors {
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
        bottomMargin: 20
      }
      spacing: 20

      AVMEButton {
        id: btnAdd
        width: (tokensPanel.width * 0.3)
        text: "Add a new token"
        onClicked: addTokenPopup.open()
      }
      AVMEButton {
        id: btnRemove
        width: (tokensPanel.width * 0.3)
        enabled: (selectedToken != null && selectedToken.itemAddress != avmeAddress)
        text: (enabled) ? "Remove this token" : "Can't remove"
        onClicked: confirmEraseTokenPopup.open()
      }
    }
  }

  AVMEPanel {
    id: tokenDetailsPanel
    width: (parent.width * 0.4)
    title: "Token Details"
    anchors {
      top: parent.top
      bottom: parent.bottom
      right: parent.right
      margins: 10
    }

    Column {
      anchors.centerIn: parent
      spacing: 20

      Image {
        id: tokenImage
        height: 128
        anchors.horizontalCenter: parent.horizontalCenter
        antialiasing: true
        smooth: true
        fillMode: Image.PreserveAspectFit
        source: {
          if (selectedToken != null) {
            if (selectedToken.itemAddress == avmeAddress) {
              source: "qrc:/img/avme_logo.png"
            } else {
              var img = QmlSystem.getARC20TokenImage(selectedToken.itemAddress)
              source: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
            }
          } else {
            source: ""
          }
        }
      }
      Text {
        id: tokenSymbol
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 18.0
        font.bold: true
        text: ((selectedToken != null) ? selectedToken.itemSymbol : "")
      }
      Text {
        id: tokenName
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "<b>Name:</b> "
        + ((selectedToken != null) ? selectedToken.itemName : "")
      }
      Text {
        id: tokenDecimals
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "<b>Decimals:</b> "
        + ((selectedToken != null) ? selectedToken.itemDecimals : "")
      }
      Text {
        id: tokenAddress
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "<b>Address:</b><br>"
        + ((selectedToken != null) ? selectedToken.itemAddress : "")
      }
      Text {
        id: tokenAVAXPairContract
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "<b>AVAX Pair Contract:</b><br>"
        + ((selectedToken != null) ? selectedToken.itemAVAXPairContract : "")
      }
      AVMEButton {
        id: btnCopyToken
        width: (parent.width * 0.9)
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (!tokenTimer.running)
        text: (!tokenTimer.running) ? "Copy Token Address" : "Copied!"
        onClicked: {
          QmlSystem.copyToClipboard(selectedToken.itemAddress)
          tokenTimer.start()
        }
        Timer { id: tokenTimer; interval: 2000 }
      }
      AVMEButton {
        id: btnCopyPair
        width: (parent.width * 0.9)
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: (!pairTimer.running)
        text: (!pairTimer.running) ? "Copy Pair Address" : "Copied!"
        onClicked: {
          QmlSystem.copyToClipboard(selectedToken.itemAVAXPairContract)
          pairTimer.start()
        }
        Timer { id: pairTimer; interval: 2000 }
      }
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
      QmlSystem.removeARC20Token(selectedToken.itemAddress);
      confirmEraseTokenPopup.close()
      reloadTokens()
    }
    noBtn.onClicked: {
      confirmEraseTokenPopup.close()
    }
  }
}

/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Panel for showing a given ARC20 token's details.
AVMEPanel {
  id: tokenDetailsPanel
  title: "Token Details"

  Column {
    anchors.centerIn: parent
    spacing: 20

    AVMEAsyncImage {
      id: tokenImage
      width: 128
      height: 128
      anchors.horizontalCenter: parent.horizontalCenter
      imageSource: {
        if (tokensPanel.selectedToken != null) {
          if (tokensPanel.selectedToken.itemAddress == qmlSystem.getContract("AVME")) {
            imageSource: "qrc:/img/avme_logo.png"
          } else {
            var img = qmlSystem.getARC20TokenImage(tokensPanel.selectedToken.itemAddress)
            imageSource: (img != "") ? "file:" + img : "qrc:/img/unknown_token.png"
          }
        } else {
          imageSource: ""
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
      text: ((tokensPanel.selectedToken != null) ? tokensPanel.selectedToken.itemSymbol : "")
    }
    Text {
      id: tokenName
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "<b>Name:</b> "
      + ((tokensPanel.selectedToken != null) ? tokensPanel.selectedToken.itemName : "")
    }
    Text {
      id: tokenDecimals
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "<b>Decimals:</b> "
      + ((tokensPanel.selectedToken != null) ? tokensPanel.selectedToken.itemDecimals : "")
    }
    Text {
      id: tokenAddress
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "<b>Address:</b><br>"
      + ((tokensPanel.selectedToken != null) ? tokensPanel.selectedToken.itemAddress : "")
    }
    Text {
      id: tokenAVAXPairContract
      anchors.horizontalCenter: parent.horizontalCenter
      horizontalAlignment: Text.AlignHCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "<b>AVAX Pair Contract:</b><br>"
      + ((tokensPanel.selectedToken != null) ? tokensPanel.selectedToken.itemAVAXPairContract : "")
    }
    AVMEButton {
      id: btnCopyToken
      width: (tokenDetailsPanel.width * 0.8)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (!tokenTimer.running)
      text: (!tokenTimer.running) ? "Copy Token Address" : "Copied!"
      onClicked: {
        qmlSystem.copyToClipboard(tokensPanel.selectedToken.itemAddress)
        tokenTimer.start()
      }
      Timer { id: tokenTimer; interval: 2000 }
    }
    AVMEButton {
      id: btnCopyPair
      width: (tokenDetailsPanel.width * 0.8)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (!pairTimer.running)
      text: (!pairTimer.running) ? "Copy Pair Address" : "Copied!"
      onClicked: {
        qmlSystem.copyToClipboard(tokensPanel.selectedToken.itemAVAXPairContract)
        pairTimer.start()
      }
      Timer { id: pairTimer; interval: 2000 }
    }
  }
}

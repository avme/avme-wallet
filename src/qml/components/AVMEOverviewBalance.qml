/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.15 // Gradient.orientation requires QtQuick 2.15
import QtQuick.Controls 2.2

// Template for basic info/data/etc.
Rectangle {
  id: overviewBalance
  property alias totalFiatBalance: fiatBalance.text
  property alias totalCoinBalance: coinBalance.text
  property alias totalTokenBalance: tokenBalance.text

  implicitWidth: 500
  implicitHeight: 120
  gradient: Gradient {
    orientation: Gradient.Horizontal
    GradientStop { position: 0.0; color: "#9300f5" }
    GradientStop { position: 1.0; color: "#00d6f6" }
  }
  radius: 10

  Column {
    anchors {
      left: parent.left
      right: parent.right
      verticalCenter: parent.verticalCenter
      margins: 10
    }
    spacing: 10

    Text {
      id: fiatBalance
      color: "white"
      font.pixelSize: 24.0
      font.bold: true
      text: {
        if (accountHeader.totalFiatBalance) {
          text: "$" + accountHeader.totalFiatBalance
        } else {
          text: "Loading..."
        }
      }
    }

    Text {
      id: coinBalance
      color: "white"
      font.pixelSize: 18.0
      font.bold: true
      text: (accountHeader.coinRawBalance)
      ? accountHeader.coinRawBalance + " AVAX" : "Loading..."
    }

    Text {
      id: tokenBalance
      color: "white"
      font.pixelSize: 18.0
      font.bold: true
      // Using the own tokenList object makes the own if to fail
      text: {
        if (accountHeader.tokensLoading) {
          var totalTokenWorth = 0.0
          for (var token in accountHeader.tokenList) {
            totalTokenWorth += (
              +accountHeader.tokenList[token]["rawBalance"] *
              +accountHeader.tokenList[token]["derivedValue"]
            )
          }
          text: totalTokenWorth + " AVAX (Tokens)"
        } else {
          text: "Loading..."
        }
      }
    }
  }
}

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

  // Due to usage of global variables, we can only tell the screen
  // to read from them in the appropriate time
  // Using a signal
  Component.onCompleted: {
    if (!accountHeader.coinRawBalance) {
      totalFiatBalance = "Loading..."
      totalCoinBalance = "Loading..."
      totalTokenBalance = "Loading..."
    } else { updateBalances() }
  }
  Connections {
    target: accountHeader
      function onUpdatedBalances() { updateBalances() }
  }

  function updateBalances() {
    totalFiatBalance = "$" + accountHeader.totalFiatBalance
    totalCoinBalance = accountHeader.coinRawBalance + " AVAX"
    var totalTokenWorth = 0.0
    for (var token in accountHeader.tokenList) {
      var currentTokenWorth = (+accountHeader.tokenList[token]["rawBalance"] *
      +accountHeader.tokenList[token]["derivedValue"])
      // Due to some unknown reason, if you sum something to 0, it will return 0
      // So we need to check if the currentTokenWorth is not 0
      if (+currentTokenWorth != 0)
        totalTokenWorth += +currentTokenWorth
    }
    totalTokenBalance = totalTokenWorth + " AVAX (Tokens)"
  }


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
    }

    Text {
      id: coinBalance
      color: "white"
      font.pixelSize: 18.0
      font.bold: true
    }

    Text {
      id: tokenBalance
      color: "white"
      font.pixelSize: 18.0
      font.bold: true
    }
  }
}

/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9

/**
 * Custom list for an account QRCode
 * Requires a ListModel with the following items:
 * - "squareColor": the account's name/label (bool)
 */
GridView {
  id: qrCodeGridView
  property real squareSize: 29
  width: height
  height: roundNumber(parent.height, squareSize) * squareSize
  anchors.centerIn: parent
  antialiasing: true
  cellHeight: roundNumber(parent.height, squareSize)
  cellWidth: roundNumber(parent.height, squareSize)

  function roundNumber(square, totalSize) {
    square = Math.round(square);
    while ((square % totalSize) != 0) {
      --square;
    }
    //console.log(square/totalSize)
    return square/totalSize;
  }

  delegate: Column {
    Item {
      id: gridItem
      Rectangle {
        height: parent.parent.parent.height / qrCodeGridView.squareSize
        width: height
        antialiasing: true
        color: (squareColor) ? "black" : "white";
      }
    }
  }
}

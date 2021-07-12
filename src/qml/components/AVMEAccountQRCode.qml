import QtQuick 2.9

/**
 * Custom list for an account QRCode
 * Requires a ListModel with the following items:
 * - "squareColor": the account's name/label (bool)
 */

GridView {
    function roundNumber(square, totalSize) {
        square = Math.round(square);
        while ((square % totalSize) != 0) {
            --square;
        }
        console.log(square/totalSize)
        return square/totalSize;
    }
    id: qrCodeGridView
    antialiasing: true
    property real squareSize: 29
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    height: roundNumber(parent.height, squareSize) * squareSize
    width: height
    
    cellHeight: roundNumber(parent.height, squareSize)
    cellWidth: roundNumber(parent.height, squareSize)
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
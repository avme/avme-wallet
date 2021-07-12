import QtQuick 2.9

import "qrc:/qml/components"

AVMEPopup {
  id: qrcodePopup
  widthPct: 0.3
  heightPct: 0.6
  property real qrcodeWidth: 29
  property alias qrModel: modelQr
  property alias textAddress: addressText

  Rectangle {
    id: popupQrCodeBorderRect
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top 
    anchors.topMargin: parent.height * 0.075
    height: parent.height * 0.6
    width: height
    color: "#ffffff"
    radius: 5

    Rectangle {
        id: popupQrCodeRect
        height: parent.height * 0.95
        width: height
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        AVMEAccountQRCode {
            id: qrCodeGrid
            squareSize: qrcodeWidth
            model: ListModel { id: modelQr }
        }
    }
  }
  Text {
    id: addressText
    anchors.bottom: closeBtn.top
    anchors.bottomMargin: parent.height * 0.05
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    width: parent.width
    color: "white"
    font.bold: true
    font.pixelSize: 14.0
    text: address
  }

  AVMEButton {
    id: closeBtn
    anchors.bottom: parent.bottom
    anchors.bottomMargin: parent.height * 0.05
    anchors.horizontalCenter: parent.horizontalCenter
    height: parent.height * 0.1
    width: parent.width * 0.2
    text: "Close"
    onClicked: {
        qrcodePopup.close()
    }
  }
}
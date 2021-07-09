/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Custom list for a wallet's assets and amounts.
 * Requires a ListModel with the following items:
 * - "assetName": the account's name/label (string)
 * - "coinAmount": the asset's amount in <coin-name> (string)
 * - "tokenAmount": the asset's amount in <token-name> (string)
 * - "isToken": let the list know if the asset is a token or a coin
 *              in order to properly display values. (bool)
 * - "fiatAmount": the asset's amount in <fiat> (string)
 * - "imagePath": the asset's logo file path (string)
 */
ListView {
  id: assetList
  implicitWidth: 550
  implicitHeight: 600
  focus: true
  clip: true
  spacing: height * 0.025
  boundsBehavior: Flickable.StopAtBounds

  // Delegate (structure for each item in the list)
  delegate: Component {
    id: listDelegate
    Item {
      id: listItem
      readonly property string itemAssetName: assetName
      readonly property string itemCoinAmount: coinAmount
      readonly property string itemTokenAmount: tokenAmount
      readonly property bool itemIsToken: isToken
      readonly property string itemFiatAmount: fiatAmount
      readonly property string itemImagePath: imagePath
      // Need to be parent.parent to take the width/height from ListView
      // Otherwise, it will take from the delegate: Component... qml reasons :shrug:
      width: parent.parent.width
      height: parent.parent.height * 0.25
      Rectangle {
        id: assetRectangle
        width: parent.width
        height: parent.height
        radius: 5
        color: "#0f0c18"
        Image {
          id: listAssetImage
          height: parent.height * 0.3
          width: height
          source: imagePath
          mipmap: true
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.topMargin: parent.height * 0.1
          anchors.leftMargin: parent.height * 0.1
        } 
        Text {
          id: listAssetAmount
          anchors.top: listAssetImage.bottom
          anchors.left: parent.left
          anchors.topMargin: parent.height * 0.05
          anchors.leftMargin: parent.height * 0.1
          color: "white"
          text: if(isToken) {
            text: itemTokenAmount
          } else {
            text: itemCoinAmount
          }
          font.pixelSize: 20.0
          font.bold: true
        }
        Text {
          id: listAssetName
          anchors.top: listAssetImage.bottom
          anchors.left: listAssetAmount.right
          anchors.topMargin: parent.height * 0.05
          anchors.leftMargin: parent.height * 0.1
          color: "white"
          text: itemAssetName
          font.pixelSize: 20.0
          font.bold: true
        }
        Text {
          id: listAssetFiatAmount 
          anchors.top: listAssetAmount.bottom
          anchors.left: parent.left
          anchors.topMargin: parent.height * 0.025
          anchors.leftMargin: parent.height * 0.1
          color: "white"
          text: itemFiatAmount
          font.pixelSize: 15.0

        }
        Text {
          id: listAssetCoinAmount 
          anchors.top: listAssetFiatAmount.bottom
          anchors.left: parent.left
          anchors.topMargin: parent.height * 0.025
          anchors.leftMargin: parent.height * 0.1
          color: "white"
          text: if(isToken) {
            text: itemCoinAmount + " AVAX"
          } else {
            // Else condition was added to avoid Qt of complaining about [undefined] value
            text: ""
          }
          font.pixelSize: 15.0
        }
        // TODO: Clickable chart
      }
    }
  }
}
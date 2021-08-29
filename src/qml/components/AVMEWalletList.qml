/* Copyright (c) 2020-2021 AVME Developers
	 Distributed under the MIT/X11 software license, see the accompanying
	 file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Custom list for a wallet's addresses and amounts.
 * Requires a ListModel with the following items:
 * - "address": the account's actual address
 * - "name": the account's name/label
 * - "coinAmount": the account's amount in <coin-name>
 * - "coinValue" : the account's dolar value of <coin-name>
 * - "backgroundGradientStart": the BG Gradient color start
 * - "backgroundGradientEnd": the BG Gradient color end
 */
ListView {
  id: walletList

  width: parent.width
  height: parent.height
  focus: true
  clip: true
  boundsBehavior: Flickable.StopAtBounds
  leftMargin: 20
  rightMargin: 20
  snapMode: ListView.SnapToItem
  spacing: 40
  orientation: ListView.Horizontal
  highlight: Rectangle {
    color: "#342e43";
    radius: 10;
    anchors.verticalCenter: walletList.currentItem.verticalCenter
  }
  highlightMoveVelocity: 1500

	delegate: Component {
		id: listDelegate

    Item {
			id: listItem
      readonly property string itemName: name
      readonly property string itemAddress: address
      readonly property string itemCoinAmount: coinAmount
      readonly property string itemCoinValue: coinValue
      readonly property bool itemIsLedger: isLedger
      readonly property string itemDerivationPath: derivationPath
			width: parent.parent.width / 4
      height: parent.height

			Rectangle {
        id: delegateRectangle
        property string backgroundGradientStart
        property string backgroundGradientEnd
        property var gradientStart: [
          "#7100D3", "#3400D3", "#7100D3", "#C22820",
          "#0093D2", "#B92063", "#00D2B9", "#991DAC"
        ]
        property var gradientEnd: [
          "#19A3D2", "#19A3D2", "#2619D2", "#3017D0",
          "#00AA40", "#B92063", "#3C1298", "#005AD5"
        ]

        Component.onCompleted: {
          var num = Math.floor(Math.random() * gradientStart.length)
          backgroundGradientStart = gradientStart[num]
          backgroundGradientEnd = gradientEnd[num]
        }

				gradient: Gradient {
					GradientStop { position: 0.0; color: delegateRectangle.backgroundGradientStart }
					GradientStop { position: 1.0; color: delegateRectangle.backgroundGradientEnd }
				}
        radius: 10
        anchors.centerIn: parent
				width: (parent.width * 0.95)
				height: (parent.height * 0.95)

				Image {
					source: (!itemIsLedger) ? "qrc:/img/icons/Icon_Profile_White.png" : "qrc:/img/icons/ledgerIcon.png"
					anchors.top: parent.top
					anchors.topMargin: parent.height * 0.1
					anchors.horizontalCenter: parent.horizontalCenter
					width: parent.width / 3
					height: width
				}
				Text {
					id: delegateName
          anchors {
            horizontalCenter: parent.horizontalCenter
					  top: parent.top
					  topMargin: parent.height * 0.4
          }
          text: (itemName) ? itemName : "-unnamed-"
          width: parent.width * 0.9
          color: "#ffffff"
					font.pixelSize: 18.0
          font.bold: true
          elide: Text.ElideRight
					horizontalAlignment: Text.AlignHCenter
				}
				Text {
					id: delegateAddress
          anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: parent.height * 0.5
          }
					text: itemAddress
          width: parent.width * 0.9
					color: "#ffffff"
					font.pixelSize: 14.0
          elide: Text.ElideRight
					horizontalAlignment: Text.AlignHCenter
				}
				Text {
					id: delegateCoinAmount
          anchors {
            bottom: parent.bottom
            bottomMargin: parent.height * 0.2
            right: parent.right
            rightMargin: parent.width * 0.1
          }
					text: itemCoinAmount
					color: "#ffffff"
					font.pixelSize: 16.0
					horizontalAlignment: Text.AlignHCenter
				}
				Text {
          id: delegateCoinValue
          anchors {
            bottom: parent.bottom
            bottomMargin: parent.height * 0.1
            right: parent.right
            rightMargin: parent.width * 0.1
          }
          text: itemCoinValue
          color: "#ffffff"
          font.pixelSize: 16.0
          horizontalAlignment: Text.AlignHCenter
				}
				MouseArea {
          id: delegateMouseArea
          anchors.fill: parent
          onClicked: walletList.currentIndex = index
				}
			}
		}
	}
}

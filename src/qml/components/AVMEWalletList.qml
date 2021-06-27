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
	highlight: Rectangle {
		color: "#342e43";
		radius: 10;
		anchors.verticalCenter: walletList.currentItem.verticalCenter
	}
	highlightMoveVelocity: 1500
	focus: true
	clip: true
	width: parent.width
	height: parent.height
	boundsBehavior: Flickable.StopAtBounds
	leftMargin: 20
	rightMargin: 20
	snapMode: ListView.SnapToItem
	spacing: 40
	orientation: ListView.Horizontal
	delegate: Component {
		id: listDelegate
		Item {
			id: delegateItem
			width: parent.parent.width / 4
			height: parent.height
			Rectangle {
				id: delegateRectangle
				gradient: Gradient {
					GradientStop { position: 0.0; color: backgroundGradientStart }
					GradientStop { position: 1.0; color: backgroundGradientEnd }
				}
				radius: 10
				anchors.verticalCenter: parent.verticalCenter
				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width - parent.width * 0.075
				height: parent.height - parent.height * 0.075
				Image {
					source: "qrc:/img/icons/Icon_Profile_White.png"
					anchors.top: parent.top
					anchors.topMargin: parent.height * 0.1
					anchors.horizontalCenter: parent.horizontalCenter
					width: parent.width / 3
					height: width
				}
				Text {
					id: delegateName
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.top: parent.top
					anchors.topMargin: parent.height * 0.4
					text: name
					color: "#ffffff"
					font.pixelSize: 24.0
					horizontalAlignment: Text.AlignHCenter
					font.bold: true
				}
				Text {
					id: delegateAddress
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.top: parent.top
					anchors.topMargin: parent.height * 0.5
					text: address
					color: "#ffffff"
					font.pixelSize: 16.0
					horizontalAlignment: Text.AlignHCenter
				}
				Text {
					id: delegateCoinAmount
					anchors.bottom: parent.bottom
					anchors.bottomMargin: parent.height * 0.2
					anchors.right: parent.right
					anchors.rightMargin: parent.width * 0.1
					text: coinAmount
					color: "#ffffff"
					font.pixelSize: 16.0
					horizontalAlignment: Text.AlignHCenter
				}
				Text {
          id: delegateCoinValue
          anchors.bottom: parent.bottom
          anchors.bottomMargin: parent.height * 0.1
          anchors.right: parent.right
          anchors.rightMargin: parent.width * 0.1
          text: coinValue
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

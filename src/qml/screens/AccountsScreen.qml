/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"
import "qrc:/qml/panels"

// Screen for listing Accounts and their general operations

Item {

	AVMEPanelAccountSelect {
		height: parent.height * 0.9
		width: parent.width * 0.95
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
	}
}


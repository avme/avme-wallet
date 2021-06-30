/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

// Template for creating popups.
// Requires a size percentage (sizePct) between 0.0 and 1.0
Popup {
  id: popup
  property real sizePct

  width: window.width * sizePct
  height: window.height * sizePct
  x: (window.width / 2) - (width / 2)
  y: (window.height / 2) - (height / 2)
  background: Rectangle { anchors.fill: parent; color: "#1C2029"; radius: 10 }
  modal: true
  focus: true
  padding: 0  // Remove white borders
  closePolicy: Popup.NoAutoClose
}

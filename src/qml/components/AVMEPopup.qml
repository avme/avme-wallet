/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Template for creating popups.
 * Parameters:
 * - widthPct: width percentage relative to the parent (0.0 - 1.0)
 * - heightPct: height percentage relative to the parent (0.0 - 1.0)
 */
Popup {
  id: popup
  property real widthPct
  property real heightPct

  width: parent.width * widthPct
  height: parent.height * heightPct
  x: ((parent.width / 2) - (width / 2))
  y: ((parent.height / 2) - (height / 2))
  background: Rectangle { anchors.fill: parent; color: "#1C2029"; radius: 10 }
  modal: true
  focus: true
  padding: 0  // Remove white borders
  closePolicy: Popup.NoAutoClose
}

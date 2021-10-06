/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

/**
 * Stylized combobox.
 */
ComboBox {
  id: combobox
  width: 160
  height: 40

  background: Rectangle { color: "#3F3F4B"; radius: 5 }

  contentItem: Text {
    text: combobox.displayText
    font.pixelSize: 14.0
    color: (combobox.pressed) ? "#2BE8F4" : "#FFFFFF"
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    leftPadding: 10
    rightPadding: combobox.indicator.width + combobox.spacing
  }

  indicator: Canvas {
    id: canvas
    x: combobox.width - width - combobox.rightPadding
    y: combobox.topPadding + ((combobox.availableHeight - height) / 2)
    width: 12
    height: 8
    contextType: "2d"
    Connections {
      target: combobox
      function onPressedChanged() { canvas.requestPaint() }
    }
    onPaint: {
      context.reset()
      context.moveTo(0, 0)
      context.lineTo(width, 0)
      context.lineTo(width / 2, height)
      context.closePath()
      context.fillStyle = (combobox.pressed) ? "#2BE8F4" : "#FFFFFF"
      context.fill()
    }
  }

  popup: Popup {
    y: combobox.height - 1
    width: combobox.width
    implicitHeight: contentItem.implicitHeight
    padding: 1
    background: Rectangle { color: "transparent" }
    contentItem: ListView {
      clip: true
      implicitHeight: contentHeight
      model: (combobox.popup.visible) ? combobox.delegateModel : null
      currentIndex: combobox.highlightedIndex
      ScrollIndicator.vertical: ScrollIndicator {
        contentItem: Rectangle { implicitWidth: 2; implicitHeight: 100; color: "#FFFFFF" }
      }
    }
  }

  delegate: ItemDelegate {
    width: combobox.width
    background: Rectangle { color: (highlighted) ? "#4F4F5C" : "#3F3F4B" }
    contentItem: Text {
      text: modelData
      color: (highlighted) ? "#2BE8F4" : "#FFFFFF"
      font: combobox.font
      elide: Text.ElideRight
      verticalAlignment: Text.AlignVCenter
    }
    highlighted: combobox.highlightedIndex === index
  }
}


/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

/**
 * Popup for inserting a BIP39 seed.
 * Parameters:
 * - fullSeed: the validated seed in a single string, words separated by space
 */
AVMEPopup {
  id: seedPopup
  widthPct: 0.4
  heightPct: 0.8
  property string fullSeed

  function handlePaste(event) {
    if ((event.key == Qt.Key_V) && (event.modifiers & Qt.ControlModifier)) {
      var clip = QmlSystem.copySeedFromClipboard()
      var leftCol = seedColLeft.children
      var rightCol = seedColRight.children
      for (var i = 0; i < 6; i++) {
        leftCol[i].text = (clip[i]) ? clip[i] : ""
        rightCol[i].text = (clip[i+6]) ? clip[i+6] : ""
      }
    }
  }

  function checkSeed() {
    fullSeed = ""
    for (var i = 0; i < 6; i++) {
      fullSeed += seedColLeft.children[i].text + " "
    }
    for (var i = 0; i < 6; i++) {
      fullSeed += seedColRight.children[i].text
      if (i != 5) { fullSeed += " " }
    }
    if (QmlSystem.seedIsValid(fullSeed)) {
      useSeedForWallet()
    } else {
      fullSeed = ""
      seedFailPopup.open()
    }
  }

  function clean() {
    fullSeed = ""
    var leftCol = seedColLeft.children
    var rightCol = seedColRight.children
    for (var i = 0; i < 6; i++) {
      leftCol[i].text = ""
      rightCol[i].text = ""
    }
  }

  Column {
    id: seedItems
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 30

    Text {
      id: info
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: "Enter your 12-word seed."
    }

    Row {
      id: seedInputs
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 20

      Column {
        id: seedColLeft
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20
        AVMEInput {
          id: seedInput1
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel1
            anchors {
              verticalCenter: parent.verticalCenter
              right: parent.left
              rightMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 24.0
            text: "1"
          }
        }
        AVMEInput {
          id: seedInput2
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel2
            anchors {
              verticalCenter: parent.verticalCenter
              right: parent.left
              rightMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 24.0
            text: "2"
          }
        }
        AVMEInput {
          id: seedInput3
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel3
            anchors {
              verticalCenter: parent.verticalCenter
              right: parent.left
              rightMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 24.0
            text: "3"
          }
        }
        AVMEInput {
          id: seedInput4
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel4
            anchors {
              verticalCenter: parent.verticalCenter
              right: parent.left
              rightMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 24.0
            text: "4"
          }
        }
        AVMEInput {
          id: seedInput5
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel5
            anchors {
              verticalCenter: parent.verticalCenter
              right: parent.left
              rightMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 24.0
            text: "5"
          }
        }
        AVMEInput {
          id: seedInput6
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel6
            anchors {
              verticalCenter: parent.verticalCenter
              right: parent.left
              rightMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 24.0
            text: "6"
          }
        }
      }

      Column {
        id: seedColRight
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20
        AVMEInput {
          id: seedInput7
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel7
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 24.0
            text: "7"
          }
        }
        AVMEInput {
          id: seedInput8
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel8
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 24.0
            text: "8"
          }
        }
        AVMEInput {
          id: seedInput9
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel9
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 24.0
            text: "9"
          }
        }
        AVMEInput {
          id: seedInput10
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel10
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 24.0
            text: "10"
          }
        }
        AVMEInput {
          id: seedInput11
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel11
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 24.0
            text: "11"
          }
        }
        AVMEInput {
          id: seedInput12
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel12
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 24.0
            text: "12"
          }
        }
      }
    }

    AVMEButton {
      id: btnOk
      width: (seedItems.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (
        seedInput1.text != "" && seedInput2.text != "" &&
        seedInput3.text != "" && seedInput4.text != "" &&
        seedInput5.text != "" && seedInput6.text != "" &&
        seedInput7.text != "" && seedInput8.text != "" &&
        seedInput9.text != "" && seedInput10.text != "" &&
        seedInput11.text != "" && seedInput12.text != ""
      )
      text: "Done"
      onClicked: checkSeed()
    }

    AVMEButton {
      id: btnClose
      width: (seedItems.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Back"
      onClicked: {
        seedPopup.clean()
        seedPopup.close()
      }
    }
  }
}

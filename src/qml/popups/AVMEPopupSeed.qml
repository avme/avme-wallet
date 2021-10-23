/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Popup for inserting a BIP39 seed.
AVMEPopup {
  id: seedPopup
  widthPct: 0.4
  heightPct: 0.9
  property string fullSeed
  property alias phraseValue: phraseSize.currentValue
  property alias clearBtn: btnClear

  onAboutToShow: seedLabel1.forceActiveFocus()
  onAboutToHide: {
    var leftCol = seedColLeft.children
    var rightCol = seedColRight.children
    for (var i = 0; i < (+phraseValue/2); i++) {
      leftCol[i].text = ""; rightCol[i].text = ""
    }
  }

  function handlePaste(event) {
    if ((event.key == Qt.Key_V) && (event.modifiers & Qt.ControlModifier)) {
      var clip = qmlSystem.copySeedFromClipboard()
      var leftCol = seedColLeft.children
      var rightCol = seedColRight.children
      // Clean all fields first
      for (var i = 0; i < (+phraseValue/2); i++) {
        leftCol[i].text = ""; rightCol[i].text = ""
      }
      // Remove unnecessary spaces and invisible newlines from each word
      for (var i = 0; i < (+phraseValue); i++) {
        var word = clip[i]
        word = word.replace(" ", "")
        word = word.replace("\n", "")
        if (i < (+phraseValue/2)) {
          leftCol[i].text = word
        } else {
          rightCol[i-(+phraseValue/2)].text = word
        }
      }
    }
  }

  function checkSeed() {
    fullSeed = ""
    var ignoreValue = (+phraseValue == 12) ? 5 : 11
    for (var i = 0; i < (+phraseValue/2); i++) {
      fullSeed += seedColLeft.children[i].text + " "
    }
    for (var i = 0; i < (+phraseValue/2); i++) {
      fullSeed += seedColRight.children[i].text
      if (i != ignoreValue) { fullSeed += " " }
    }
    if (qmlSystem.seedIsValid(fullSeed)) {
      seedPopup.close()
    } else {
      fullSeed = ""
      seedFailPopup.open()
    }
  }

  Column {
    id: seedItems
    width: parent.width
    height: parent.height * 0.8
    anchors.top: parent.top
    anchors.topMargin: 20
    spacing: 20

    // Enter/Numpad enter key override
    Keys.onPressed: {
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        if (btnOk.enabled) { checkSeed() }
      }
    }

    Text {
      id: info
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      anchors.left: parent.left
      anchors.leftMargin: ((parent.width - (width + phraseSize.width + (width * 0.025)))/2)
      color: "#FFFFFF"
      font.pixelSize: 14.0
      height: parent.height * 0.05
      text: "Enter your seed. Phrase Size:"
      AVMECombobox {
        id: phraseSize
        width: 80
        height: parent.height
        anchors.left: parent.right
        anchors.leftMargin: parent.width * 0.025
        font.pixelSize: parent.font.pixelSize
        model: ["12", "24"]
        onActivated: {
          // Always clean all fields when changing phrase size
          var leftCol = seedColLeft.children
          var rightCol = seedColRight.children
          for (var i = 0; i < (+phraseValue/2); i++) {
            leftCol[i].text = ""; rightCol[i].text = ""
          }
        }
      }
    }

    Row {
      id: seedInputs
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: spacing

      Column {
        id: seedColLeft
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5
        AVMEInput {
          id: seedInput1
          height: (seedItems.height / 20)
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
            font.pixelSize: 16.0
            text: "1"
          }
        }
        AVMEInput {
          id: seedInput2
          height: (seedItems.height / 20)
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
            font.pixelSize: 16.0
            text: "2"
          }
        }
        AVMEInput {
          id: seedInput3
          height: (seedItems.height / 20)
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
            font.pixelSize: 16.0
            text: "3"
          }
        }
        AVMEInput {
          id: seedInput4
          height: (seedItems.height / 20)
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
            font.pixelSize: 16.0
            text: "4"
          }
        }
        AVMEInput {
          id: seedInput5
          height: (seedItems.height / 20)
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
            font.pixelSize: 16.0
            text: "5"
          }
        }
        AVMEInput {
          id: seedInput6
          height: (seedItems.height / 20)
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
            font.pixelSize: 16.0
            text: "6"
          }
        }
        AVMEInput {
          id: seedInput13 // Actually 7
          height: (seedItems.height / 20)
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          visible: (phraseValue == 24) ? true : false
          Text {
            id: seedLabel13
            anchors {
              verticalCenter: parent.verticalCenter
              right: parent.left
              rightMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: "7"
          }
        }
        AVMEInput {
          id: seedInput14 // Actually 8
          visible: (phraseValue == 24) ? true : false
          height: (seedItems.height / 20)
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel14
            anchors {
              verticalCenter: parent.verticalCenter
              right: parent.left
              rightMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: "8"
          }
        }
        AVMEInput {
          id: seedInput15 // Actually 9
          visible: (phraseValue == 24) ? true : false
          height: (seedItems.height / 20)
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel15
            anchors {
              verticalCenter: parent.verticalCenter
              right: parent.left
              rightMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: "9"
          }
        }
        AVMEInput {
          id: seedInput16 // Actually 10
          visible: (phraseValue == 24) ? true : false
          height: (seedItems.height / 20)
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel16
            anchors {
              verticalCenter: parent.verticalCenter
              right: parent.left
              rightMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: "10"
          }
        }
        AVMEInput {
          id: seedInput17 // Actually 11
          visible: (phraseValue == 24) ? true : false
          height: (seedItems.height / 20)
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel17
            anchors {
              verticalCenter: parent.verticalCenter
              right: parent.left
              rightMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: "11"
          }
        }
        AVMEInput {
          id: seedInput18 // Actually 12
          visible: (phraseValue == 24) ? true : false
          height: (seedItems.height / 20)
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel18
            anchors {
              verticalCenter: parent.verticalCenter
              right: parent.left
              rightMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: "12"
          }
        }
      }

      Column {
        id: seedColRight
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5
        AVMEInput {
          id: seedInput7 // 7 AND 13 at the same time, depending on combobox
          width: (seedItems.width * 0.35)
          height: (seedItems.height / 20)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel7
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: (phraseValue == 12) ? "7" : "13"
          }
        }
        AVMEInput {
          id: seedInput8 // 8 AND 14 at the same time, depending on combobox
          width: (seedItems.width * 0.35)
          height: (seedItems.height / 20)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel8
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: (phraseValue == 12) ? "8" : "14"
          }
        }
        AVMEInput {
          id: seedInput9 // 9 AND 15 at the same time, depending on combobox
          width: (seedItems.width * 0.35)
          height: (seedItems.height / 20)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel9
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: (phraseValue == 12) ? "9" : "15"
          }
        }
        AVMEInput {
          id: seedInput10 // 10 AND 16 at the same time, depending on combobox
          width: (seedItems.width * 0.35)
          height: (seedItems.height / 20)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel10
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: (phraseValue == 12) ? "10" : "16"
          }
        }
        AVMEInput {
          id: seedInput11 // 11 AND 17 at the same time, depending on combobox
          width: (seedItems.width * 0.35)
          height: (seedItems.height / 20)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel11
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: (phraseValue == 12) ? "11" : "17"
          }
        }
        AVMEInput {
          id: seedInput12 // 12 AND 18 at the same time, depending on combobox
          width: (seedItems.width * 0.35)
          height: (seedItems.height / 20)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel12
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: (phraseValue == 12) ? "12" : "18"
          }
        }
        AVMEInput {
          id: seedInput19 // Actually 19
          height: (seedItems.height / 20)
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          visible: (phraseValue == 24) ? true : false
          Text {
            id: seedLabel19
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: "19"
          }
        }
        AVMEInput {
          id: seedInput20 // Actually 20
          visible: (phraseValue == 24) ? true : false
          height: (seedItems.height / 20)
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel20
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: "20"
          }
        }
        AVMEInput {
          id: seedInput21 // Actually 21
          visible: (phraseValue == 24) ? true : false
          height: (seedItems.height / 20)
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel21
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: "21"
          }
        }
        AVMEInput {
          id: seedInput22 // Actually 22
          visible: (phraseValue == 24) ? true : false
          height: (seedItems.height / 20)
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel22
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: "22"
          }
        }
        AVMEInput {
          id: seedInput23 // Actually 23
          visible: (phraseValue == 24) ? true : false
          height: (seedItems.height / 20)
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel23
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: "23"
          }
        }
        AVMEInput {
          id: seedInput24 // Actually 24
          visible: (phraseValue == 24) ? true : false
          height: (seedItems.height / 20)
          width: (seedItems.width * 0.35)
          Keys.onReleased: handlePaste(event)
          Text {
            id: seedLabel24
            anchors {
              verticalCenter: parent.verticalCenter
              left: parent.right
              leftMargin: 20
            }
            color: "#FFFFFF"
            font.pixelSize: 16.0
            text: "24"
          }
        }
      }
    }
  }

  Column {
    id: seedBtnCol
    width: parent.width
    height: parent.height * 0.2
    anchors {
      bottom: parent.bottom
      bottomMargin: (btnClear.visible) ? btnClear.height : 0
    }
    spacing: 10

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
        seedInput11.text != "" && seedInput12.text != "" &&
        +phraseValue == 12 || (
        seedInput1.text != "" && seedInput2.text != "" &&
        seedInput3.text != "" && seedInput4.text != "" &&
        seedInput5.text != "" && seedInput6.text != "" &&
        seedInput7.text != "" && seedInput8.text != "" &&
        seedInput9.text != "" && seedInput10.text != "" &&
        seedInput11.text != "" && seedInput12.text != "" &&
        seedInput13.text != "" && seedInput14.text != "" &&
        seedInput15.text != "" && seedInput16.text != "" &&
        seedInput17.text != "" && seedInput18.text != "" &&
        seedInput20.text != "" && seedInput21.text != "" &&
        seedInput22.text != "" && seedInput23.text != "" &&
        seedInput24.text != ""
        )
      )
      text: "Done"
      onClicked: checkSeed()
    }

    AVMEButton {
      id: btnClear
      width: (seedItems.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Clear Seed"
      onClicked: { seedPopup.fullSeed = ""; seedPopup.close() }
    }

    AVMEButton {
      id: btnClose
      width: (seedItems.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Close"
      onClicked: seedPopup.close()
    }
  }

  AVMEPopupInfo {
    id: seedFailPopup; icon: "qrc:/img/warn.png"
    widthPct: 0.9
    info: "Seed is invalid.<br>Please check if typing is correct."
  }
}

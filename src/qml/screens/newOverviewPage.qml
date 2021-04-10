import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

Item {
  width: 1094
  height: 768
  
  Rectangle {
    id: mainRectangle
    x: 0
    y: 0
    width: 1094
    height: 768
    color: "#252935"

    AVMESideMenu {
      id: sideMenu
    }

    /*
    Rectangle {
      id: menuRectangle
      x: 0
      y: 0
      width: 95
      height: 768
      color: "#1c2029"

      Loader {
        id: menu
        x: 0
        y: 0
        width: 95
        height: 768
        source: "qrc:/qml/screens/newMenu.qml"
      }

    }
    */

    Rectangle {
      id: balanceRectangle
      x: 131
      y: 78
      width: 401
      height: 244
      color: "#2d3542"
      radius: 11
      smooth: true
      border.width: 3
      border.color: "#2d3542"


      Rectangle {
        id: cornerRectangle
        x: 0
        y: 38
        width: 401
        height: 22
        color: "#1d212a"
      }

      Rectangle {
        id: titleRectangle
        x: 0
        y: 0
        width: 401
        height: 60
        color: "#1d212a"
        radius: 10
        border.width: 0


        Text {
          id: titleTextBalance
          y: 8
          width: 271
          height: 44
          color: "#ffffff"
          text: qsTr("Balance")
          anchors.left: parent.left
          anchors.leftMargin: 13
          font.family: "Tahoma"
          font.pixelSize: 32
        }
      }

      Rectangle {
        id: avmeBalanceRectangle
        y: 92
        height: 61
        color: "#343b4b"
        radius: 11
        anchors.left: parent.left
        anchors.leftMargin: 13
        anchors.right: parent.right
        anchors.rightMargin: 13
        border.width: 0

        BorderImage {
          id: borderImage
          width: 50
          antialiasing: true
          smooth: true
          anchors.top: parent.top
          anchors.topMargin: 5
          anchors.left: parent.left
          anchors.leftMargin: 5
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 5
          source: "../../img/avax_logo.png"
        }

        Text {
          id: tokenName
          y: 21
          width: 80
          height: 20
          color: "#ffffff"
          text: qsTr("AVAX")
          anchors.left: parent.left
          anchors.leftMargin: 60
          font.pixelSize: 12
          font.family: "Tahoma"
        }

        Text {
          id: tokenBalance
          x: 145
          y: 21
          width: 80
          height: 20
          color: "#ffffff"
          text: qsTr("VALUE")
          anchors.right: parent.right
          anchors.rightMargin: 144
          font.pixelSize: 12
          font.family: "Tahoma"
        }

        Text {
          id: tokenValue
          x: 216
          width: 80
          color: "#ffffff"
          text: qsTr("VALUE")
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 20
          anchors.top: parent.top
          anchors.topMargin: 21
          anchors.right: parent.right
          anchors.rightMargin: 29
          font.pixelSize: 12
          font.family: "Tahoma"
        }
      }

      Rectangle {
        id: avaxBalanceRectangle
        y: 170
        height: 61
        color: "#343b4b"
        radius: 11
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 13
        anchors.right: parent.right
        anchors.rightMargin: 13
        anchors.left: parent.left
        anchors.leftMargin: 13

        Image {
          id: image1
          width: 50
          antialiasing: true
          smooth: true
          anchors.left: parent.left
          anchors.leftMargin: 5
          anchors.top: parent.top
          anchors.topMargin: 5
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 5
          source: "../../img/avme_logo.png"
          fillMode: Image.PreserveAspectFit
        }

        Text {
          id: tokenName1
          y: 21
          width: 80
          height: 20
          color: "#ffffff"
          text: qsTr("AVME")
          anchors.left: parent.left
          anchors.leftMargin: 60
          font.pixelSize: 12
          font.family: "Tahoma"
        }

        Text {
          id: tokenBalance1
          x: 145
          y: 21
          width: 80
          height: 20
          color: "#ffffff"
          text: qsTr("VALUE")
          anchors.right: parent.right
          anchors.rightMargin: 144
          font.pixelSize: 12
          font.family: "Tahoma"
        }

        Text {
          id: tokenValue1
          x: 261
          width: 80
          color: "#ffffff"
          text: qsTr("VALUE")
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 20
          anchors.top: parent.top
          anchors.topMargin: 21
          anchors.right: parent.right
          anchors.rightMargin: 29
          font.pixelSize: 12
          font.family: "Tahoma"
        }
      }

      Text {
        id: balanceTitle
        y: 67
        height: 20
        color: "#ffffff"
        text: qsTr("BALANCE
        ")
        anchors.right: parent.right
        anchors.rightMargin: 157
        anchors.left: parent.left
        anchors.leftMargin: 164
        font.pixelSize: 12
        font.family: "Tahoma"
      }

      Text {
        id: valueTitle
        x: 279
        y: 66
        width: 80
        height: 20
        color: "#ffffff"
        text: qsTr("VALUE")
        anchors.right: parent.right
        anchors.rightMargin: 42
        font.pixelSize: 12
        font.family: "Tahoma"
      }

      Text {
        id: tokenTitle
        y: 67
        width: 80
        height: 20
        color: "#ffffff"
        text: qsTr("TOKEN")
        anchors.left: parent.left
        anchors.leftMargin: 73
        font.family: "Tahoma"
        font.pixelSize: 12
      }

    }

    Rectangle {
      id: totalWalletRectangle
      x: 557
      y: 93
      width: 516
      height: 284
      color: "#2d3542"
      radius: 11
      border.color: "#2d3542"
      border.width: 3
      smooth: true
      Rectangle {
        id: totalWalletCorner
        x: 0
        y: 38
        width: 516
        height: 22
        color: "#1d212a"
      }

      Rectangle {
        id: titleRectangle1
        x: 0
        width: 516
        height: 59
        color: "#1d212a"
        radius: 10
        anchors.top: parent.top
        anchors.topMargin: 0
        border.width: 0
        Text {
          id: textRectangle1
          x: 13
          y: 8
          width: 271
          height: 44
          color: "#ffffff"
          text: qsTr("Total Wallet Value")
          font.pixelSize: 32
          font.family: "Tahoma"
        }
      }

      Item {
        id: walletChart
        width: 200
        height: 200
        anchors.left: parent.left
        anchors.leftMargin: 13
        anchors.top: parent.top
        anchors.topMargin: 71
      }
      ListView {
        id: listView
        x: 219
        y: 72
        width: 284
        height: 80
        rotation: 0
        anchors.top: parent.top
        anchors.right: parent.right
        model: ListModel {
          ListElement {
            name: "AVAX"
            rectangleColor: "#2d3542"
            ballColor : "#e14a69"
          }

          ListElement {
            name: "AVME"
            rectangleColor: "#343b4b"
            ballColor : "#762f8d"
          }
        }
        anchors.rightMargin: 13
        anchors.topMargin: 112
        delegate: Item {
          width: parent.width
          height: 40
          Row {
            id: row1
            spacing: 10
            Rectangle {
              id: rectangle
              width: listView.width
              height: 40
              color: rectangleColor
              Rectangle {
                width: 30
                height: 30
                radius: 15
                border.width: 0
                color : ballColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin : 10

              }

              Text {
                color: "#ffffff"
                height: 40
                text: name
                anchors.left: parent.left
                anchors.leftMargin: 50
                verticalAlignment: Text.AlignVCenter
                font.family: "Tahoma"
                font.pixelSize: 25
              }

              Text {
                color: "#ffffff"
                height: 40
                text: "123$"
                horizontalAlignment: Text.AlignRight
                anchors.right: parent.right
                anchors.rightMargin: 50
                verticalAlignment: Text.AlignVCenter
                font.family: "Tahoma"
                font.pixelSize: 25
              }
            }
          }
        }
      }

    }
    Rectangle {
      id: stakingRectangle
      x: 132
      y: 386
      width: 398
      height: 297
      color: "#2d3542"
      radius: 11
      border.color: "#2d3542"
      border.width: 3
      smooth: true
      Rectangle {
        id: cornerRectangle2
        x: 0
        y: 38
        width: 398
        height: 22
        color: "#1d212a"
      }

      Rectangle {
        id: titleStaking
        x: 0
        y: 0
        width: 398
        height: 60
        color: "#1d212a"
        radius: 10
        border.width: 0
        Text {
          id: titleTextStaking
          y: 8
          width: 271
          height: 44
          color: "#ffffff"
          text: qsTr("Staking")
          anchors.left: parent.left
          anchors.leftMargin: 13
          font.pixelSize: 32
          font.family: "Tahoma"
        }
      }

      Rectangle {
        id: getRewardRectangle
        width: 173
        color: "#772e88"
        radius: 13
        border.width: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 13
        anchors.top: parent.top
        anchors.topMargin: 257
        anchors.left: parent.left
        anchors.leftMargin: 13

        Text {
          id: getRewardText
          y: 0
          width: 173
          height: 27
          color: "#ffffff"
          text: qsTr("GET REWARD")
          anchors.left: parent.left
          anchors.leftMargin: 0
          lineHeight: 1.2
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 0
          verticalAlignment: Text.AlignVCenter
          font.family: "Tahoma"
          horizontalAlignment: Text.AlignHCenter
          font.pixelSize: 20
        }
      }

      Rectangle {
        id: totalLockedRectangle
        x: 0
        y: 60
        width: 398
        height: 48
        color: "#343b4b"
        anchors.top: parent.top
        anchors.topMargin: 60

        Text {
          id: totalLockedText
          y: 0
          width: 156
          height: 48
          color: "#ffffff"
          text: qsTr("TOTAL LOCKED")
          verticalAlignment: Text.AlignVCenter
          font.family: "Tahoma"
          anchors.left: parent.left
          anchors.leftMargin: 13
          font.pixelSize: 20
        }

        Text {
          id: element2
          x: 240
          y: 0
          width: 143
          height: 48
          color: "#ffffff"
          text: qsTr("$VALUE")
          font.family: "Tahoma"
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignRight
          anchors.right: parent.right
          anchors.rightMargin: 13
          font.pixelSize: 20
        }
      }

      Rectangle {
        id: stakingInfoRectangle
        x: -9
        y: 7
        color: "#772e88"
        radius: 13
        anchors.right: parent.right
        anchors.rightMargin: 13
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottomMargin: 13
        anchors.leftMargin: 212
        anchors.topMargin: 257
        Text {
          id: stakeInfoText
          x: 0
          y: 0
          width: 173
          height: 27
          color: "#ffffff"
          text: qsTr("STAKING INFO")
          font.pixelSize: 20
          font.family: "Tahoma"
          anchors.bottomMargin: 0
          anchors.bottom: parent.bottom
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
        }
        anchors.bottom: parent.bottom
      }

      Text {
        id: avmeRewardTitle
        x: 50
        color: "#ffffff"
        text: qsTr("AVME REWARD")
        font.family: "Tahoma"
        anchors.top: parent.top
        anchors.topMargin: 121
        font.pixelSize: 14
      }

      Text {
        id: walletReward
        x: 86
        color: "#ffffff"
        text: qsTr("0")
        anchors.top: parent.top
        anchors.topMargin: 163
        font.family: "Tahoma"
        font.pixelSize: 45
      }

      Text {
        id: rewardTableTitle
        x: 253
        y: 117
        color: "#ffffff"
        text: qsTr("REWARD TABLE")
        font.family: "Tahoma"
        font.pixelSize: 14
      }
      ListView {
        id: rewardTable
        x: 212
        width: 173
        height: 100
        anchors.right: parent.right
        anchors.rightMargin: 13
        orientation: ListView.Vertical
        anchors.top: parent.top
        anchors.topMargin: 144
        spacing: 10
        model: ListModel {
          ListElement {
            name: "30 Days"
          }

          ListElement {
            name: "60 Days"
          }

          ListElement {
            name: "90 Days"
          }

          ListElement {
            name: "180 Days"
          }

          ListElement {
            name: "360 Days"
          }
        }
        delegate: Item {
          x: 5
          width: 40
          height: 10

          Row {
            id: row2
            spacing: 0
            anchors.left: parent.left
            anchors.leftMargin: 10
            Text {
              color: "#ffffff"
              text: name
              font.family: "Tahoma"
              font.pixelSize: 14

            }
          }

          Row {
            id: row3
            spacing : 0
            anchors.left: parent.left
            anchors.leftMargin: 125
            Text {
              color: "#ffffff"
              text: "...%"
              font.family: "Tahoma"
              font.pixelSize: 14
              horizontalAlignment: Text.AlignLeft
            }
          }
        }
      }

      Rectangle {
        id: rewardTableDivisor
        x: 212
        width: 173
        height: 1
        color: "#772e88"
        anchors.top: parent.top
        anchors.topMargin: 140
      }
    }

    Rectangle {
      id: marketDataRectangle
      x: 557
      y: 400
      width: 516
      height: 349
      color: "#2d3542"
      radius: 11
      border.color: "#2d3542"
      border.width: 3
      smooth: true
      Rectangle {
        id: cornerRectangle3
        x: 0
        y: 38
        width: 516
        height: 22
        color: "#1d212a"
      }

      Rectangle {
        id: titleRectangle3
        x: 0
        y: 0
        width: 516
        height: 60
        color: "#1d212a"
        radius: 10
        border.width: 0
        Text {
          id: marketDataTitleText
          x: 13
          y: 8
          width: 188
          height: 44
          color: "#ffffff"
          text: qsTr("Market Data")
          font.pixelSize: 32
          font.family: "Tahoma"
        }
      }

      Item {
        id: marketDataItem
        anchors.top: parent.top
        anchors.topMargin: 73
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 13
        anchors.right: parent.right
        anchors.rightMargin: 13
        anchors.left: parent.left
        anchors.leftMargin: 13
      }
    }

    Rectangle {
      id: walletDivisor
      x: 123
      width: 963
      height: 1
      color: "#4e525d"
      anchors.top: parent.top
      anchors.topMargin: 58
    }

    Text {
      id: address
      x: 132
      color: "#ffffff"
      text: qsTr("ADDRESS: 0x...")
      verticalAlignment: Text.AlignVCenter
      font.family: "Tahoma"
      anchors.top: parent.top
      anchors.topMargin: 16
      font.pixelSize: 20
    }

    Rectangle {
      id: refreshRectangle
      x: 899
      y: 16
      width: 144
      height: 24
      color: "#252935"

      Image {
        id: refreshIcon
        x: 72
        y: 0
        width: 27
        height: 24
        source: "../../img/icons/refresh.png"
        fillMode: Image.PreserveAspectFit
      }

      Text {
        id: refreshText
        x: 0
        y: 0
        width: 100
        height: 24
        color: "#ffffff"
        text: qsTr("Refresh")
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 20
      }
    }

    Rectangle {
      id: manageWalletRectangle
      x: 700
      y: 16
      width: 176
      height: 24
      color: "#252935"

      Text {
        id: manageWalletText
        x: 0
        y: 0
        width: 143
        height: 24
        color: "#ffffff"
        text: qsTr("Manage Wallets")
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 20
      }

      Image {
        id: manageWalletIcon
        x: 149
        y: 0
        width: 27
        height: 24
        source: "../../img/icons/inboxes.png"
        fillMode: Image.PreserveAspectFit
      }
    }
  }
}

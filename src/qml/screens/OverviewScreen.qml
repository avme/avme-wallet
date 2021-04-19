/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtCharts 2.2

import "qrc:/qml/components"

// Screen for showing an overview for the Wallet, Account, etc.
Item {
  id: overviewScreen

  Connections {
    target: System
    onRewardUpdated: stakingPanel.reward = poolReward
  }

  // Timer for reloading the Account balances
  Timer {
    id: listReloadTimer
    interval: 1000
    repeat: true
    onTriggered: reloadBalances()
  }

  Component.onCompleted: {
    reloadBalances()
    listReloadTimer.start()
  }

  function reloadBalances() {
    var acc = System.getAccountBalances(System.getCurrentAccount())
    var wal = System.getAllAccountBalances()
    System.getPoolReward()
    accountCoinBalance.text = (acc.balanceAVAX) ? acc.balanceAVAX : "Loading..."
    accountTokenBalance.text = (acc.balanceAVME) ? acc.balanceAVME : "Loading..."
    stakingLockedBalance.text = (acc.balanceLPLocked) ? acc.balanceLPLocked : "Loading..."
    walletCoinBalance.text = (wal.balanceAVAX) ? wal.balanceAVAX : "Loading..."
    walletTokenBalance.text = (wal.balanceAVME) ? wal.balanceAVME : "Loading..."
  }

  AVMEAccountHeader {
    id: accountHeader
  }

  // TODO: fiat balances and chart percentages
  AVMEPanel {
    id: balancesPanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
    anchors {
      top: accountHeader.bottom
      left: parent.left
      bottom: parent.bottom
      margins: 10
    }
    title: "Balances"

    Column {
      anchors {
        top: parent.header.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        topMargin: 20
      }
      spacing: 10

      Text {
        id: accountText
        width: parent.width * 0.95
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        text: "This Account"
      }

      ChartView {
        id: accountChart
        property color coinColor: "#782D8B"
        property color tokenColor: "#368097"
        width: parent.width
        height: (parent.height * 0.3)
        backgroundColor: "transparent"
        antialiasing: true
        legend.visible: false
        margins { right: 0; bottom: 0; left: 0; top: 0 }

        PieSeries {
          id: accountPie
          size: 0.8
          holeSize: 0.6
          horizontalPosition: 0.125
          PieSlice {
            label: "AVAX"; color: accountChart.coinColor; borderColor: "transparent"; value: 54.5
          }
          PieSlice {
            label: "AVME"; color: accountChart.tokenColor; borderColor: "transparent"; value: 45.5
          }
        }

        Column {
          width: (parent.width * 0.7)
          anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            margins: 20
          }
          spacing: 10

          Rectangle {
            id: accountCoinRect
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: 60
            radius: 10
            color: accountChart.coinColor

            Image {
              id: accountCoinLogo
              height: parent.height
              anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
                margins: 10
              }
              antialiasing: true
              smooth: true
              source: "qrc:/img/avax_logo.png"
              fillMode: Image.PreserveAspectFit
            }

            Text {
              id: accountCoinBalance
              width: parent.width * 0.8
              anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -10
                left: accountCoinLogo.right
                leftMargin: 10
              }
              color: "#FFFFFF"
              elide: Text.ElideRight
            }

            Text {
              id: accountCoinPrice
              width: parent.width * 0.8
              anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: 10
                left: accountCoinLogo.right
                leftMargin: 10
              }
              color: "#FFFFFF"
              text: "$999999999.99"
              elide: Text.ElideRight
            }
          }

          Rectangle {
            id: accountTokenRect
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: 60
            radius: 10
            color: accountChart.tokenColor

            Image {
              id: accountTokenLogo
              height: parent.height
              anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
                margins: 10
              }
              antialiasing: true
              smooth: true
              source: "qrc:/img/avme_logo.png"
              fillMode: Image.PreserveAspectFit
            }

            Text {
              id: accountTokenBalance
              width: parent.width * 0.8
              anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -10
                left: accountTokenLogo.right
                leftMargin: 10
              }
              color: "#FFFFFF"
              elide: Text.ElideRight
            }

            Text {
              id: accountTokenPrice
              width: parent.width * 0.8
              anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: 10
                left: accountTokenLogo.right
                leftMargin: 10
              }
              color: "#FFFFFF"
              text: "$99999.99"
              elide: Text.ElideRight
            }
          }
        }
      }

      Text {
        id: walletText
        width: parent.width * 0.95
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        text: "Total from Wallet"
      }

      ChartView {
        id: walletChart
        property color coinColor: "#782D8B"
        property color tokenColor: "#368097"
        width: parent.width
        height: (parent.height * 0.3)
        backgroundColor: "transparent"
        antialiasing: true
        legend.visible: false
        margins { right: 0; bottom: 0; left: 0; top: 0 }

        PieSeries {
          id: walletPie
          size: 0.8
          holeSize: 0.6
          horizontalPosition: 0.125
          PieSlice {
            label: "AVAX"; color: walletChart.coinColor; borderColor: "transparent"; value: 38.9
          }
          PieSlice {
            label: "AVME"; color: walletChart.tokenColor; borderColor: "transparent"; value: 62.1
          }
        }

        Column {
          width: (parent.width * 0.7)
          anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            margins: 20
          }
          spacing: 10

          Rectangle {
            id: walletCoinRect
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: 60
            radius: 10
            color: walletChart.coinColor

            Image {
              id: walletCoinLogo
              height: parent.height
              anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
                margins: 10
              }
              antialiasing: true
              smooth: true
              source: "qrc:/img/avax_logo.png"
              fillMode: Image.PreserveAspectFit
            }

            Text {
              id: walletCoinBalance
              width: parent.width * 0.8
              anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -10
                left: walletCoinLogo.right
                leftMargin: 10
              }
              color: "#FFFFFF"
              elide: Text.ElideRight
            }

            Text {
              id: walletCoinPrice
              width: parent.width * 0.8
              anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: 10
                left: walletCoinLogo.right
                leftMargin: 10
              }
              color: "#FFFFFF"
              text: "$999999999.99"
              elide: Text.ElideRight
            }
          }

          Rectangle {
            id: walletTokenRect
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: 60
            radius: 10
            color: walletChart.tokenColor

            Image {
              id: walletTokenLogo
              height: parent.height
              anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
                margins: 10
              }
              antialiasing: true
              smooth: true
              source: "qrc:/img/avme_logo.png"
              fillMode: Image.PreserveAspectFit
            }

            Text {
              id: walletTokenBalance
              width: parent.width * 0.8
              anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -10
                left: walletTokenLogo.right
                leftMargin: 10
              }
              color: "#FFFFFF"
              elide: Text.ElideRight
            }

            Text {
              id: walletTokenPrice
              width: parent.width * 0.8
              anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: 10
                left: walletTokenLogo.right
                leftMargin: 10
              }
              color: "#FFFFFF"
              text: "$99999.99"
              elide: Text.ElideRight
            }
          }
        }
      }
    }
  }

  // TODO: future statistics
  AVMEPanel {
    id: stakingPanel
    property string reward
    width: (parent.width * 0.5) - (anchors.margins * 2)
    height: (parent.height * 0.45) - anchors.margins
    anchors {
      top: accountHeader.bottom
      right: parent.right
      margins: 10
    }
    title: "Staking Statistics"

    Rectangle {
      id: stakingLockedRect
      width: parent.width * 0.9
      height: 40
      anchors {
        horizontalCenter: parent.horizontalCenter
        top: parent.header.bottom
        margins: 10
      }
      color: "#3E4653"
      radius: 10

      Text {
        id: stakingLockedBalance
        anchors {
          verticalCenter: parent.verticalCenter
          left: parent.left
          leftMargin: 10
        }
        width: parent.width * 0.75
        color: "#FFFFFF"
        elide: Text.ElideRight
      }

      Text {
        id: stakingLockedText
        anchors {
          verticalCenter: parent.verticalCenter
          right: parent.right
          rightMargin: 10
        }
        color: "#FFFFFF"
        text: "Locked LP"
      }
    }

    Text {
      id: rewardCurrentTitle
      anchors {
        top: stakingLockedRect.bottom
        horizontalCenter: parent.horizontalCenter
        topMargin: 10
      }
      color: "#FFFFFF"
      text: "Current AVME Reward"
    }

    Text {
      id: rewardAmount
      width: parent.width * 0.9
      anchors {
        top: rewardCurrentTitle.bottom
        horizontalCenter: parent.horizontalCenter
      }
      font.bold: true
      font.pointSize: 18.0
      color: "#FFFFFF"
      text: (parent.reward) ? parent.reward : "Loading..."
      elide: Text.ElideRight
      horizontalAlignment: Text.AlignHCenter
    }

    Text {
      id: rewardFutureTitle
      anchors {
        top: rewardAmount.bottom
        horizontalCenter: parent.horizontalCenter
        topMargin: 10
      }
      color: "#FFFFFF"
      text: "Future Rewards"
    }

    Column {
      id: rewardFutureTable
      width: parent.width * 0.9
      anchors {
        top: rewardFutureTitle.bottom
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
      }

      Text {
        anchors.left: parent.left
        width: parent.width
        color: "#FFFFFF"
        text: "30 days"
        elide: Text.ElideRight
        Text {
          anchors.right: parent.right
          color: "#FFFFFF"
          text: "...%"
        }
      }

      Text {
        anchors.left: parent.left
        width: parent.width
        color: "#FFFFFF"
        text: "60 days"
        elide: Text.ElideRight
        Text {
          anchors.right: parent.right
          color: "#FFFFFF"
          text: "...%"
        }
      }

      Text {
        anchors.left: parent.left
        width: parent.width
        color: "#FFFFFF"
        text: "90 days"
        elide: Text.ElideRight
        Text {
          anchors.right: parent.right
          color: "#FFFFFF"
          text: "...%"
        }
      }

      Text {
        anchors.left: parent.left
        width: parent.width
        color: "#FFFFFF"
        text: "180 days"
        elide: Text.ElideRight
        Text {
          anchors.right: parent.right
          color: "#FFFFFF"
          text: "...%"
        }
      }

      Text {
        anchors.left: parent.left
        width: parent.width
        color: "#FFFFFF"
        text: "360 days"
        elide: Text.ElideRight
        Text {
          anchors.right: parent.right
          color: "#FFFFFF"
          text: "...%"
        }
      }
    }
  }

  AVMEPanel {
    id: marketDataPanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
    height: (parent.height * 0.45) - anchors.margins
    anchors {
      top: stakingPanel.bottom
      right: parent.right
      margins: 10
    }
    title: "Market Data"
  }
}

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
    onAccountBalancesUpdated: {
      accountCoinBalance.text = data.balanceAVAX
      accountTokenBalance.text = data.balanceAVME
      accountCoinPrice.text = "$" + data.balanceAVAXUSD
      accountTokenPrice.text = "$" + data.balanceAVMEUSD
      accountSliceAVAX.value = data.percentageAVAXUSD
      accountSliceAVME.value = data.percentageAVMEUSD
      stakingLockedBalance.text = data.balanceLPLocked
    }
    onWalletBalancesUpdated: {
      walletCoinBalance.text = data.balanceAVAX
      walletTokenBalance.text = data.balanceAVME
      walletCoinPrice.text = "$" + data.balanceAVAXUSD
      walletTokenPrice.text = "$" + data.balanceAVMEUSD
      walletSliceAVAX.value = data.percentageAVAXUSD
      walletSliceAVME.value = data.percentageAVMEUSD
    }
    onRewardUpdated: stakingPanel.reward = poolReward
    onRoiCalculated: stakingPanel.roi = ROI
  }

  // Timer for reloading the Account balances
  Timer {
    id: listReloadTimer
    interval: 1000
    repeat: true
    onTriggered: reloadBalances()
  }

  // Timer for reloading the staking ROI
  Timer {
    id: listROITimer
    interval: 5000
    repeat: true
    onTriggered: System.calculateRewardCurrentROI()
  }

  Component.onCompleted: {
    reloadBalances()
    System.calculateRewardCurrentROI()
    listReloadTimer.start()
    listROITimer.start()
    accountCoinBalance.text = accountCoinPrice.text = "Loading..."
    accountTokenBalance.text = accountTokenPrice.text = "Loading..."
    walletCoinBalance.text = walletCoinPrice.text = "Loading..."
    walletTokenBalance.text = walletTokenPrice.text = "Loading..."
    stakingLockedBalance.text = "Loading..."
  }

  function reloadBalances() {
    System.getAccountBalancesOverview(System.getCurrentAccount())
    System.getAllAccountBalancesOverview()
    System.getPoolReward()
  }

  AVMEAccountHeader {
    id: accountHeader
  }

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

        Rectangle {
          anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
          }
          width: (parent.width * 0.275)
          color: "transparent"

          Text {
            id: accountSliceAVAXText
            anchors {
              centerIn: parent
              verticalCenterOffset: -10
            }
            font.bold: true
            font.pointSize: 14.0
            color: accountChart.coinColor
            text: accountSliceAVAX.value + "%"
          }

          Text {
            id: accountSliceAVMEText
            anchors {
              centerIn: parent
              verticalCenterOffset: 10
            }
            font.bold: true
            font.pointSize: 14.0
            color: accountChart.tokenColor
            text: accountSliceAVME.value + "%"
          }
        }

        PieSeries {
          id: accountPie
          size: 0.8
          holeSize: 0.65
          horizontalPosition: 0.125
          PieSlice {
            id: accountSliceAVAX; color: accountChart.coinColor; borderColor: "transparent"
          }
          PieSlice {
            id: accountSliceAVME; color: accountChart.tokenColor; borderColor: "transparent"
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
              elide: Text.ElideRight
            }
          }
        }
      }

      Text {
        id: walletText
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

        Rectangle {
          anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
          }
          width: (parent.width * 0.275)
          color: "transparent"

          Text {
            id: walletSliceAVAXText
            anchors {
              centerIn: parent
              verticalCenterOffset: -10
            }
            font.bold: true
            font.pointSize: 14.0
            color: walletChart.coinColor
            text: walletSliceAVAX.value + "%"
          }

          Text {
            id: walletSliceAVMEText
            anchors {
              centerIn: parent
              verticalCenterOffset: 10
            }
            font.bold: true
            font.pointSize: 14.0
            color: walletChart.tokenColor
            text: walletSliceAVME.value + "%"
          }
        }

        PieSeries {
          id: walletPie
          size: 0.8
          holeSize: 0.65
          horizontalPosition: 0.125
          PieSlice {
            id: walletSliceAVAX; color: walletChart.coinColor; borderColor: "transparent"
          }
          PieSlice {
            id: walletSliceAVME; color: walletChart.tokenColor; borderColor: "transparent"
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
              elide: Text.ElideRight
            }
          }
        }
      }
    }
  }

  AVMEPanel {
    id: stakingPanel
    property string reward
    property string roi
    width: (parent.width * 0.5) - (anchors.margins * 2)
    height: (parent.height * 0.35) - anchors.margins
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
      id: roiTitle
      anchors {
        top: rewardAmount.bottom
        horizontalCenter: parent.horizontalCenter
        topMargin: 10
      }
      color: "#FFFFFF"
      text: "Current ROI"
    }

    Text {
      id: roiPercentage
      width: parent.width * 0.9
      anchors {
        top: roiTitle.bottom
        horizontalCenter: parent.horizontalCenter
      }
      font.bold: true
      font.pointSize: 18.0
      color: "#FFFFFF"
      text: (parent.roi) ? parent.roi + "%" : "Loading..."
      elide: Text.ElideRight
      horizontalAlignment: Text.AlignHCenter
    }
  }

  AVMEPanel {
    id: marketDataPanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
    height: (parent.height * 0.55) - anchors.margins
    anchors {
      top: stakingPanel.bottom
      right: parent.right
      margins: 10
    }
    title: "Market Data"
  }
}

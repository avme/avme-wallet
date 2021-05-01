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
    function onAccountBalancesUpdated(data) {
      accountCoinBalance.text = data.balanceAVAX
      accountTokenBalance.text = data.balanceAVME
      stakingFreeBalance.text = data.balanceLPFree
      stakingLockedBalance.text = data.balanceLPLocked
      accountBalancesReloadTimer.start()
    }
    function onAccountFiatBalancesUpdated(data) {
      accountCoinPrice.text = "$" + data.balanceAVAXUSD
      accountTokenPrice.text = "$" + data.balanceAVMEUSD
      accountSliceAVAX.value = data.percentageAVAXUSD
      accountSliceAVME.value = data.percentageAVMEUSD
      accountFiatBalancesReloadTimer.start()
    }
    function onWalletBalancesUpdated(data) {
      walletCoinBalance.text = data.balanceAVAX
      walletTokenBalance.text = data.balanceAVME
      walletBalancesReloadTimer.start()
    }
    function onWalletFiatBalancesUpdated(data) {
      walletCoinPrice.text = "$" + data.balanceAVAXUSD
      walletTokenPrice.text = "$" + data.balanceAVMEUSD
      walletSliceAVAX.value = data.percentageAVAXUSD
      walletSliceAVME.value = data.percentageAVMEUSD
      walletFiatBalancesReloadTimer.start()
    }
    function onRewardUpdated(poolReward) {
      rewardAmount.reward = poolReward
      rewardReloadTimer.start()
    }
    function onRoiCalculated(ROI) {
      roiPercentage.roi = ROI
      roiTimer.start()
    }
    function onMarketDataUpdated(days, currentAVAXPrice, currentAVMEPrice, AVMEHistory) {
      currentAVAXAmount.amount = currentAVAXPrice
      currentAVMEAmount.amount = currentAVMEPrice
      var minY = -1
      var maxY = -1
      marketGraph.countX = (AVMEHistory.length / 2)

      for (var i = 0; i < AVMEHistory.length; i++) {
        // Get the current candlestick (and previous if not at the end yet)
        var obj = JSON.parse(AVMEHistory[i])
        var timestamp = new Date(obj.unixdate * 1000)
        var candlestick = Qt.createQmlObject(
          "import QtCharts 2.2; CandlestickSet { timestamp: " + timestamp.getTime() + " }", marketGraph
        )
        var prevObj = null
        var prevTimestamp = null
        if (i != AVMEHistory.length - 1) {
          prevObj = JSON.parse(AVMEHistory[i+1])
          prevTimestamp = new Date(prevObj.unixdate * 1000)
        }

        // Fill any gaps between days
        if (prevTimestamp != null) {
          var timediff = timestamp.getTime() - prevTimestamp.getTime()
          if (timediff > 86400000) {  // diff > 1 day means there are gaps
            while (timediff > 0) {
              var prevCandlestick = Qt.createQmlObject(
                "import QtCharts 2.2; CandlestickSet { timestamp: " + (timediff - 86400000) + " }", marketGraph
              )
              prevCandlestick.open = obj.priceUSD
              prevCandlestick.high = obj.priceUSD
              prevCandlestick.low = obj.priceUSD
              prevCandlestick.close = obj.priceUSD
              marketGraph.append(prevCandlestick)
              timediff -= 86400000
            }
          }
        }

        // Set candlestick values
        if (i == AVMEHistory.length - 1) {
          // Oldest candlestick
          candlestick.open = 0
          candlestick.high = Math.max(0, obj.priceUSD)
          candlestick.low = Math.min(0, obj.priceUSD)
          candlestick.close = obj.priceUSD
        } else {
          // The rest up until the newest
          candlestick.open = prevObj.priceUSD
          candlestick.high = Math.max(prevObj.priceUSD, obj.priceUSD)
          candlestick.low = Math.min(prevObj.priceUSD, obj.priceUSD)
          candlestick.close = obj.priceUSD
        }

        // Set axis limits before inserting
        if (i == 0) {
          marketGraph.maxX = timestamp
          marketGraph.minX = new Date(timestamp.getTime() - (86400000 * days))
        }
        minY = (minY == -1 || obj.priceUSD < minY) ? obj.priceUSD : minY
        maxY = (maxY == -1 || obj.priceUSD > maxY) ? obj.priceUSD : maxY
        if (candlestick.open == 0) {
          marketGraph.minY = 0
        } else {
          marketGraph.minY = (minY - (minY * 0.1) > 0) ? minY - (minY * 0.1) : 0
        }
        marketGraph.maxY = maxY + (maxY * 0.1)

        // Insert the candlestick into the graph
        marketGraph.append(candlestick)
      }
      marketChart.visible = true
    }
  }

  // Timer for reloading the Account balances
  Timer {
    id: accountBalancesReloadTimer
    interval: 2500
    repeat: false
    onTriggered: System.getAccountBalancesOverview(System.getCurrentAccount())
  }

  // Timer for reloading the Account fiat balances
  Timer {
    id: accountFiatBalancesReloadTimer
    interval: 2500
    repeat: false
    onTriggered: System.getAccountFiatBalancesOverview(System.getCurrentAccount())
  }

  // Timer for reloading the Wallet balances
  Timer {
    id: walletBalancesReloadTimer
    interval: 2500
    repeat: false
    onTriggered: System.getAllAccountBalancesOverview()
  }

  // Timer for reloading the Wallet fiat balances
  Timer {
    id: walletFiatBalancesReloadTimer
    interval: 2500
    repeat: false
    onTriggered: System.getAllAccountFiatBalancesOverview()
  }

  // Timer for reloading the current AVME reward
  Timer {
    id: rewardReloadTimer
    interval: 2500
    repeat: false
    onTriggered: System.getPoolReward()
  }

  // Timer for reloading the staking ROI
  Timer {
    id: roiTimer
    interval: 2500
    repeat: false
    onTriggered: System.calculateRewardCurrentROI()
  }

  Component.onCompleted: {
    accountCoinBalance.text = accountCoinPrice.text = "Loading..."
    accountTokenBalance.text = accountTokenPrice.text = "Loading..."
    walletCoinBalance.text = walletCoinPrice.text = "Loading..."
    walletTokenBalance.text = walletTokenPrice.text = "Loading..."
    stakingFreeBalance.text = "Loading..."
    stakingLockedBalance.text = "Loading..."
    System.getAccountBalancesOverview(System.getCurrentAccount())
    System.getAccountFiatBalancesOverview(System.getCurrentAccount())
    System.getAllAccountBalancesOverview()
    System.getAllAccountFiatBalancesOverview()
    System.getPoolReward()
    System.calculateRewardCurrentROI()
    System.getMarketData(30)
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
    title: "Balances & Staking Statistics"

    Column {
      anchors {
        top: parent.header.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        topMargin: 10
      }
      spacing: 5

      Text {
        id: accountText
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        font.pixelSize: 14.0
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
            font.pixelSize: 14.0
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
            font.pixelSize: 14.0
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
              font.pixelSize: 14.0
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
              font.pixelSize: 14.0
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
              font.pixelSize: 14.0
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
              font.pixelSize: 14.0
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
        font.pixelSize: 14.0
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
            font.pixelSize: 14.0
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
            font.pixelSize: 14.0
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
              font.pixelSize: 14.0
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
              font.pixelSize: 14.0
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
              font.pixelSize: 14.0
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
              font.pixelSize: 14.0
              elide: Text.ElideRight
            }
          }
        }
      }

      Rectangle {
        id: stakingBalancesRect
        width: parent.width * 0.9
        height: 60
        anchors {
          horizontalCenter: parent.horizontalCenter
          margins: 20
        }
        color: "#3E4653"
        radius: 10

        Text {
          id: stakingFreeBalance
          anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -10
            left: parent.left
            leftMargin: 10
          }
          width: parent.width * 0.75
          color: "#FFFFFF"
          font.pixelSize: 14.0
          elide: Text.ElideRight
        }

        Text {
          id: stakingFreeText
          anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -10
            right: parent.right
            rightMargin: 10
          }
          color: "#FFFFFF"
          font.pixelSize: 14.0
          text: "Free LP"
        }

        Text {
          id: stakingLockedBalance
          anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: 10
            left: parent.left
            leftMargin: 10
          }
          width: parent.width * 0.75
          color: "#FFFFFF"
          font.pixelSize: 14.0
          elide: Text.ElideRight
        }

        Text {
          id: stakingLockedText
          anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: 10
            right: parent.right
            rightMargin: 10
          }
          color: "#FFFFFF"
          font.pixelSize: 14.0
          text: "Locked LP"
        }
      }

      Rectangle {
        id: stakingRewardsRect
        width: parent.width * 0.9
        height: 60
        anchors {
          horizontalCenter: parent.horizontalCenter
          margins: 20
        }
        color: "#3E4653"
        radius: 10

        Text {
          id: rewardAmount
          property string reward
          anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -10
            left: parent.left
            leftMargin: 10
          }
          color: "#FFFFFF"
          font.pixelSize: 14.0
          text: (reward) ? reward : "Loading..."
          elide: Text.ElideRight
          horizontalAlignment: Text.AlignHCenter
        }

        Text {
          id: rewardTitle
          anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -10
            right: parent.right
            rightMargin: 10
          }
          color: "#FFFFFF"
          font.pixelSize: 14.0
          text: "Current AVME Reward"
        }

        Text {
          id: roiPercentage
          property string roi
          anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: 10
            left: parent.left
            leftMargin: 10
          }
          color: "#FFFFFF"
          font.pixelSize: 14.0
          text: (roi) ? roi + "%" : "Loading..."
          elide: Text.ElideRight
          horizontalAlignment: Text.AlignHCenter
        }

        Text {
          id: roiTitle
          anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: 10
            right: parent.right
            rightMargin: 10
          }
          color: "#FFFFFF"
          font.pixelSize: 14.0
          text: "Current APY"
        }
      }
    }
  }

  AVMEPanel {
    id: marketDataPanel
    width: (parent.width * 0.5) - (anchors.margins * 2)
    anchors {
      top: accountHeader.bottom
      right: parent.right
      bottom: parent.bottom
      margins: 10
    }
    title: "Market Data"

    Rectangle {
      id: marketPricesRect
      width: parent.width * 0.9
      height: 60
      anchors {
        top: parent.header.bottom
        horizontalCenter: parent.horizontalCenter
        margins: 20
      }
      color: "#3E4653"
      radius: 10

      Text {
        id: currentAVAXAmount
        property string amount
        anchors {
          verticalCenter: parent.verticalCenter
          verticalCenterOffset: -10
          left: parent.left
          leftMargin: 10
        }
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: (amount) ? amount : "Loading..."
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
      }

      Text {
        id: currentAVAXTitle
        anchors {
          verticalCenter: parent.verticalCenter
          verticalCenterOffset: -10
          right: parent.right
          rightMargin: 10
        }
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Current AVAX Price (USD)"
      }

      Text {
        id: currentAVMEAmount
        property string amount
        anchors {
          verticalCenter: parent.verticalCenter
          verticalCenterOffset: 10
          left: parent.left
          leftMargin: 10
        }
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: (amount) ? amount : "Loading..."
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
      }

      Text {
        id: currentAVMETitle
        anchors {
          verticalCenter: parent.verticalCenter
          verticalCenterOffset: 10
          right: parent.right
          rightMargin: 10
        }
        color: "#FFFFFF"
        font.pixelSize: 14.0
        text: "Current AVME Price (USD)"
      }
    }

    Text {
      id: chartLoadingText
      anchors {
        top: marketPricesRect.bottom
        horizontalCenter: parent.horizontalCenter
        margins: 10
      }
      visible: (!marketChart.visible)
      font.pixelSize: 14.0
      color: "#FFFFFF"
      text: "Loading historical prices..."
    }

    ChartView {
      id: marketChart
      anchors {
        top: marketPricesRect.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: 10
      }
      visible: false
      antialiasing: true
      backgroundColor: "#881D212A"
      title: "<b>Historical AVME Prices</b>"
      titleColor: "#FFFFFF"
      titleFont.pixelSize: 14.0
      legend {
        color: "#FFFFFF"
        labelColor: "#FFFFFF"
        alignment: Qt.AlignBottom
        font.pixelSize: 14.0
      }
      margins { right: 0; bottom: 0; left: 0; top: 0 }

      MouseArea {
        id: chartArea
        x: parent.plotArea.x
        y: parent.plotArea.y
        width: parent.plotArea.width
        height: parent.plotArea.height
        hoverEnabled: true
        onEntered: {
          mouseRectX.visible = mouseRectY.visible = true
          mouseLineX.visible = mouseLineY.visible = true
        }
        onExited: {
          mouseRectX.visible = mouseRectY.visible = false
          mouseLineX.visible = mouseLineY.visible = false
        }
        onPositionChanged: {
          var valueXPerPixel = (marketGraph.maxX.getTime() - marketGraph.minX.getTime()) / width
          var valueYPerPixel = (marketGraph.maxY - marketGraph.minY) / height
          var valueX = new Date(marketGraph.minX.getTime() + (mouse.x * valueXPerPixel))
          var valueY = marketGraph.maxY - (mouse.y * valueYPerPixel)
          mouseRectX.info = Qt.formatDate(valueX, "dd/MM")
          mouseRectY.info = valueY.toFixed(3)
          mouseLineX.x = parent.plotArea.x + mouse.x
          mouseLineY.y = parent.plotArea.y + mouse.y
          mouseRectX.x = mouseLineX.x - (mouseRectX.width / 2)
          mouseRectY.y = mouseLineY.y - (mouseRectY.height / 2)
        }
      }

      Rectangle {
        id: mouseRectX
        property string info
        visible: false
        width: 60
        height: 30
        anchors.top: chartArea.bottom
        radius: 5
        color: "#3E4653"
        Text {
          color: "#FFFFFF"
          font.pixelSize: 14.0
          anchors.centerIn: parent
          text: parent.info
        }
      }

      Rectangle {
        id: mouseRectY
        property string info
        visible: false
        width: 60
        height: 30
        anchors.right: chartArea.left
        radius: 5
        color: "#3E4653"
        Text {
          color: "#FFFFFF"
          font.pixelSize: 14.0
          anchors.centerIn: parent
          text: parent.info
        }
      }

      Rectangle {
        id: mouseLineX
        visible: false
        width: 1
        color: "#FFFFFF"
        anchors {
          top: chartArea.top
          bottom: chartArea.bottom
        }
      }

      Rectangle {
        id: mouseLineY
        visible: false
        height: 1
        color: "#FFFFFF"
        anchors {
          left: chartArea.left
          right: chartArea.right
        }
      }

      CandlestickSeries {
        id: marketGraph
        property int countX: 0
        property alias minX: marketAxisX.min
        property alias maxX: marketAxisX.max
        property alias minY: marketAxisY.min
        property alias maxY: marketAxisY.max
        name: "<b>AVME Price (USD)</b>"
        increasingColor: "green"
        decreasingColor: "red"
        bodyOutlineVisible: false
        minimumColumnWidth: 10
        axisX: DateTimeAxis {
          id: marketAxisX
          labelsColor: "#FFFFFF"
          labelsFont.pixelSize: 14.0
          gridLineColor: "#22FFFFFF"
          tickCount: marketGraph.countX
          format: "dd/MM"
        }
        axisY: ValueAxis {
          id: marketAxisY
          labelsColor: "#FFFFFF"
          labelsFont.pixelSize: 14.0
          gridLineColor: "#22FFFFFF"
        }
      }
    }
  }
}

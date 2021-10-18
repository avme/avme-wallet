/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Side panel that acts as a "global menu"
Rectangle {
  id: sideMenu
  property string currentScreen
  property bool walletIsLoaded: false
  property bool accountIsLoaded: (accountHeader.currentAddress != "")
  property bool balanceIsLoaded: (accountHeader.coinRawBalance)
  width: 200
  height: parent.height
  color: "#1C2029"

  function changeScreen(screen) {
    content.active = false
    currentScreen = screen
    qmlSystem.setScreen(content, "qml/screens/" + screen + "Screen.qml")
    content.active = true
  }

  function toggleMenuOptions() {
    for (var i = 0; i < menuModel.count; i++) {
      var item = menuModel.get(i);
      switch (item.screen) {
        case "CreateWallet":
        case "LoadWallet":
          item.isEnabled = true;
          break;
        case "Accounts":
        case "Contacts":
        case "Tokens":
          item.isEnabled = walletIsLoaded;
          break;
        case "Applications":
        case "Overview":
        case "History":
          item.isEnabled = (walletIsLoaded && accountIsLoaded);
          break;
        case "Send":
        case "Exchange":
        case "Staking":
        case "Compound":
          item.isEnabled = (walletIsLoaded && accountIsLoaded && balanceIsLoaded);
          break;
      }
    }
  }

  Component.onCompleted: toggleMenuOptions()
  onWalletIsLoadedChanged: toggleMenuOptions()
  onAccountIsLoadedChanged: toggleMenuOptions()
  onBalanceIsLoadedChanged: toggleMenuOptions()

  Rectangle {
    id: topRect
    width: parent.width
    height: (logo.height + versionText.height)
    color: parent.color
    anchors.top: parent.top
    z: 2

    AVMEAsyncImage {
      id: logo
      width: 200
      height: 50
      loading: false
      anchors {
        top: parent.top
        topMargin: 5
        horizontalCenter: parent.horizontalCenter
        horizontalCenterOffset: -5  // Logo is a bit off-center
      }
      imageSource: "qrc:/img/Welcome_Logo_AVME.png"
    }
    Text {
      id: versionText
      height: 30
      color: "#FFFFFF"
      font.bold: true
      font.pixelSize: 14.0
      anchors {
        bottom: parent.bottom
        bottomMargin: -5
        horizontalCenter: parent.horizontalCenter
      }
      text: "v" + qmlSystem.getProjectVersion()
    }
  }

  ListView {
    id: menu
    width: parent.width
    z: 1
    anchors {
      horizontalCenter: parent.horizontalCenter
      top: topRect.bottom
      bottom: bottomRect.top
    }
    Rectangle {
      id: topBorder
      width: parent.width * 0.9
      anchors.bottom: parent.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      height: 1
      color: "#FFFFFF"
    }
    Rectangle {
      id: bottomBorder
      width: parent.width * 0.9
      anchors.top: parent.top
      anchors.horizontalCenter: parent.horizontalCenter
      height: 1
      color: "#FFFFFF"
    }

    model: ListModel {
      id: menuModel
      ListElement {
        type: "Wallet"; name: "Create/Import"; screen: "CreateWallet";
        icon: "qrc:/img/icons/plus.png";
        iconSelect: "qrc:/img/icons/plusSelect.png";
        isEnabled: false; isVisible: false;
      }
      ListElement {
        type: "Wallet"; name: "Load"; screen: "LoadWallet";
        icon: "qrc:/img/icons/upload.png";
        iconSelect: "qrc:/img/icons/uploadSelect.png";
        isEnabled: false; isVisible: false;
      }
      ListElement {
        type: "Wallet"; name: "Accounts"; screen: "Accounts";
        icon: "qrc:/img/icons/inboxes.png";
        iconSelect: "qrc:/img/icons/inboxesSelect.png";
        isEnabled: false; isVisible: false;
      }
      ListElement {
        type: "Wallet"; name: "Contacts"; screen: "Contacts";
        icon: "qrc:/img/icons/users.png";
        iconSelect: "qrc:/img/icons/usersSelect.png";
        isEnabled: false; isVisible: false;
      }
      ListElement {
        type: "Wallet"; name: "Tokens"; screen: "Tokens";
        icon: "qrc:/img/icons/coin.png";
        iconSelect: "qrc:/img/icons/coinSelect.png";
        isEnabled: false; isVisible: false;
      }
      ListElement {
        type: "Wallet"; name: "DApps"; screen: "Applications";
        icon: "qrc:/img/icons/grid.png";
        iconSelect: "qrc:/img/icons/gridSelect.png";
        isEnabled: false; isVisible: false;
      }
      ListElement {
        type: "This Account"; name: "Overview"; screen: "Overview";
        icon: "qrc:/img/icons/pie-chart-alt.png";
        iconSelect: "qrc:/img/icons/pie-chart-altSelect.png";
        isEnabled: false; isVisible: false;
      }
      ListElement {
        type: "This Account"; name: "Tx History"; screen: "History";
        icon: "qrc:/img/icons/history.png";
        iconSelect: "qrc:/img/icons/historySelect.png";
        isEnabled: false; isVisible: false;
      }
      ListElement {
        type: "This Account"; name: "Send"; screen: "Send";
        icon: "qrc:/img/icons/paper-plane.png";
        iconSelect: "qrc:/img/icons/paper-planeSelect.png";
        isEnabled: false; isVisible: false;
      }
      ListElement {
        type: "This Account"; name: "ParaSwap Exchange"; screen: "Exchange";
        icon: "qrc:/img/icons/directions.png";
        iconSelect: "qrc:/img/icons/directionsSelect.png";
        isEnabled: false; isVisible: false;
      }
      ListElement {
        type: "This Account"; name: "AVME Staking"; screen: "Staking";
        icon: "qrc:/img/icons/credit-card.png";
        iconSelect: "qrc:/img/icons/credit-cardSelect.png";
        isEnabled: false; isVisible: false;
      }
      ListElement {
        type: "This Account"; name: "YieldYak Compound"; screen: "Compound";
        icon: "qrc:/img/icons/credit-card-f.png";
        iconSelect: "qrc:/img/icons/credit-card-fSelect.png";
        isEnabled: false; isVisible: false;
      }
    }
    section.property: "type"
    section.delegate: Component {
      id: header
      Rectangle {
        id: headerRect
        property bool isExpanded: false
        width: parent.width
        height: 40
        color: "transparent"
        AVMEAsyncImage {
          id: dropdown
          width: 16
          height: 16
          loading: false
          anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
          }
          imageSource: (isExpanded)
          ? "qrc:/img/icons/chevron-downSelect.png"
          : "qrc:/img/icons/chevron-down.png"
          rotation: (isExpanded) ? -180 : 0 // Counter-clockwise
          Behavior on rotation { SmoothedAnimation { duration: 200 } }
        }
        Text {
          id: headerText
          color: (isExpanded) ? "#AD00FA" : "#FFFFFF"
          font.pixelSize: 14.0
          font.bold: true
          text: section
          anchors {
            left: dropdown.right
            leftMargin: 10
            verticalCenter: parent.verticalCenter
          }
        }
        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          Timer { id: t; interval: 100; onTriggered: headerRect.isExpanded = true }
          Component.onCompleted: t.start()
          onEntered: headerRect.color = "#444444"
          onExited: headerRect.color = "transparent"
          onClicked: headerRect.isExpanded = !headerRect.isExpanded
        }
        onIsExpandedChanged: {
          for (var i = 0; i < menuModel.count; i++) {
            var item = menuModel.get(i);
            if (item.type === section) { item.isVisible = headerRect.isExpanded }
          }
        }
      }
    }
    delegate: Component {
      id: listDelegate
      Rectangle {
        id: menuItem
        property bool selected: (screen === currentScreen)
        width: parent.width
        color: "transparent"
        visible: (isVisible && isEnabled)
        enabled: isEnabled
        onVisibleChanged: height = (visible) ? 40 : 0
        Behavior on height { SmoothedAnimation { duration: 200 } }
        AVMEAsyncImage {
          id: itemIcon
          width: 16
          height: 16
          loading: false
          anchors {
            left: parent.left
            leftMargin: 20
            verticalCenter: parent.verticalCenter
          }
          imageSource: (parent.selected) ? iconSelect : icon
        }
        Text {
          id: text
          color: (parent.selected) ? "#AD00FA" : "#FFFFFF"
          font.pixelSize: 14.0
          font.bold: true
          text: name
          anchors {
            left: itemIcon.right
            leftMargin: 10
            verticalCenter: parent.verticalCenter
          }
        }
        Rectangle {
          id: selection
          width: 5
          color: "#AD00FA"
          visible: parent.selected
          anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
          }
        }
        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onEntered: { menuItem.color = "#444444" }
          onExited: { menuItem.color = "transparent" }
          onClicked: {
            menuItem.color = "transparent"
            menu.currentIndex = index
            settingsItem.selected = aboutItem.selected = false
            changeScreen(screen)
          }
        }
      }
    }
  }

  Rectangle {
    id: bottomRect
    width: parent.width
    height: (settingsItem.height + aboutItem.height)
    color: parent.color
    anchors.bottom: parent.bottom
    z: 2

    Rectangle {
      id: settingsItem
      property bool selected: false
      width: parent.width
      height: 40
      enabled: (walletIsLoaded && accountIsLoaded)
      visible: enabled
      anchors.bottom: aboutItem.top
      color: "transparent"
      AVMEAsyncImage {
        id: settingsIcon
        width: 16
        height: 16
        loading: false
        anchors {
          left: parent.left
          leftMargin: 20
          verticalCenter: parent.verticalCenter
        }
        imageSource: (parent.selected)
        ? "qrc:/img/icons/cogSelect.png" : "qrc:/img/icons/cog.png"
      }
      Text {
        id: settingsText
        color: (parent.selected) ? "#AD00FA" : "#FFFFFF"
        font.bold: true; font.pixelSize: 14.0
        text: "Settings"
        anchors { left: settingsIcon.right; leftMargin: 10; verticalCenter: parent.verticalCenter }
      }
      Rectangle {
        id: settingsSelection
        width: 5
        color: "#AD00FA"
        visible: parent.selected
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: { settingsItem.color = "#444444" }
        onExited: { settingsItem.color = "transparent" }
        onClicked: {
          settingsItem.color = "transparent"
          parent.selected = true
          aboutItem.selected = false
          menu.currentIndex = -1
          changeScreen("Settings")
        }
      }
    }
    Rectangle {
      id: aboutItem
      property bool selected: false
      width: parent.width
      height: 40
      anchors.bottom: parent.bottom
      color: "transparent"
      AVMEAsyncImage {
        id: aboutIcon
        width: 16
        height: 16
        loading: false
        anchors {
          left: parent.left
          leftMargin: 20
          verticalCenter: parent.verticalCenter
        }
        imageSource: (parent.selected)
        ? "qrc:/img/icons/infoSelect.png" : "qrc:/img/icons/info.png"
      }
      Text {
        id: aboutText
        color: (parent.selected) ? "#AD00FA" : "#FFFFFF"
        font.bold: true; font.pixelSize: 14.0
        text: "About"
        anchors { left: aboutIcon.right; leftMargin: 10; verticalCenter: parent.verticalCenter }
      }
      Rectangle {
        id: aboutSelection
        width: 5
        color: "#AD00FA"
        visible: parent.selected
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: { aboutItem.color = "#444444" }
        onExited: { aboutItem.color = "transparent" }
        onClicked: {
          aboutItem.color = "transparent"
          parent.selected = true
          settingsItem.selected = false
          menu.currentIndex = -1
          changeScreen("About")
        }
      }
    }
  }
}

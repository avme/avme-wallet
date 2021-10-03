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
  property int currentSelectionOffset
  width: 200
  height: parent.height
  color: "#1C2029"

  // TODO: Using this if condition is a workaround, find a better solution
  property bool enableBtn: accountHeader.coinRawBalance

  function changeScreen(name) {
    content.active = false
    currentScreen = name
    qmlSystem.setScreen(content, "qml/screens/" + name + "Screen.qml")
    content.active = true
  }

  Image {
    id: logo
    height: 50
    anchors {
      top: parent.top
      topMargin: 10
      horizontalCenter: parent.horizontalCenter
    }
    source: "qrc:/img/Welcome_Logo_AVME.png"
    fillMode: Image.PreserveAspectFit
    antialiasing: true
    smooth: true
  }

  Text {
    id: versionText
    color: "#FFFFFF"
    font.bold: true
    font.pixelSize: 14.0
    anchors {
      top: logo.bottom
      topMargin: 10
      horizontalCenter: parent.horizontalCenter
    }
    text: "v" + qmlSystem.getProjectVersion()
  }

  // TODO: proper item selection at startup, disabling logic
  ListView {
    id: menu
    property string expandedSection: ""
    width: parent.width
    interactive: false  // Disable flicking
    anchors {
      horizontalCenter: parent.horizontalCenter
      top: versionText.bottom
      bottom: parent.bottom
      topMargin: 10
      bottomMargin: 10
    }
    model: ListModel {
      id: menuModel
      ListElement {
        type: "Wallet"; name: "Create/Import"; screen: "CreateWallet";
        icon: "qrc:/img/icons/plus.png";
        iconSelect: "qrc:/img/icons/plusSelect.png";
        isEnabled: true; isVisible: false;
      }
      ListElement {
        type: "Wallet"; name: "Load"; screen: "LoadWallet";
        icon: "qrc:/img/icons/upload.png";
        iconSelect: "qrc:/img/icons/uploadSelect.png";
        isEnabled: true; isVisible: false;
      }
      ListElement {
        type: "Wallet"; name: "Accounts"; screen: "Accounts";
        icon: "qrc:/img/icons/inboxes.png";
        iconSelect: "qrc:/img/icons/inboxesSelect.png";
        isEnabled: true; isVisible: false;
      }
      ListElement {
        type: "Wallet"; name: "Contacts"; screen: "Contacts";
        icon: "qrc:/img/icons/bookmark.png";
        iconSelect: "qrc:/img/icons/bookmarkSelect.png";
        isEnabled: true; isVisible: false;
      }
      ListElement {
        // TODO: rename "TokensScreen" to "AssetsScreen"
        type: "Wallet"; name: "Assets"; screen: "Tokens";
        icon: "qrc:/img/icons/coin.png";
        iconSelect: "qrc:/img/icons/coinSelect.png";
        isEnabled: true; isVisible: false;
      }
      ListElement {
        type: "Wallet"; name: "Applications"; screen: "Applications";
        icon: "qrc:/img/icons/grid.png";
        iconSelect: "qrc:/img/icons/gridSelect.png";
        isEnabled: true; isVisible: false;
      }
      ListElement {
        type: "This Account"; name: "Overview"; screen: "Overview";
        icon: "qrc:/img/icons/pie-chart-alt.png";
        iconSelect: "qrc:/img/icons/pie-chart-altSelect.png";
        isEnabled: true; isVisible: false;
      }
      // TODO: split asset prices and overview screens
      ListElement {
        type: "This Account"; name: "Asset Prices"; screen: "Overview";
        icon: "qrc:/img/icons/activity.png";
        iconSelect: "qrc:/img/icons/activitySelect.png";
        isEnabled: true; isVisible: false;
      }
      ListElement {
        type: "This Account"; name: "Tx History"; screen: "History";
        icon: "qrc:/img/icons/history.png";
        iconSelect: "qrc:/img/icons/historySelect.png";
        isEnabled: true; isVisible: false;
      }
      ListElement {
        type: "Operations"; name: "Send"; screen: "Send";
        icon: "qrc:/img/icons/paper-plane.png";
        iconSelect: "qrc:/img/icons/paper-planeSelect.png";
        isEnabled: true; isVisible: false;
      }
      ListElement {
        type: "Operations"; name: "Exchange"; screen: "Exchange";
        icon: "qrc:/img/icons/directions.png";
        iconSelect: "qrc:/img/icons/directionsSelect.png";
        isEnabled: true; isVisible: false;
      }
      ListElement {
        type: "Operations"; name: "Add Liquidity"; screen: "Liquidity";
        icon: "qrc:/img/icons/log-in.png";
        iconSelect: "qrc:/img/icons/log-inSelect.png";
        isEnabled: true; isVisible: false;
      }
      // TODO: split add and remove liquidity screens
      ListElement {
        type: "Operations"; name: "Remove Liquidity"; screen: "Liquidity";
        icon: "qrc:/img/icons/log-out.png";
        iconSelect: "qrc:/img/icons/log-outSelect.png";
        isEnabled: true; isVisible: false;
      }
      ListElement {
        type: "Operations"; name: "Staking"; screen: "Staking";
        icon: "qrc:/img/icons/credit-card.png";
        iconSelect: "qrc:/img/icons/credit-cardSelect.png";
        isEnabled: true; isVisible: false;
      }
      // TODO: split staking and compound screens
      ListElement {
        type: "Operations"; name: "YY Compound"; screen: "Staking";
        icon: "qrc:/img/icons/credit-card-f.png";
        iconSelect: "qrc:/img/icons/credit-card-fSelect.png";
        isEnabled: true; isVisible: false;
      }
    }
    section.property: "type"
    section.delegate: Component {
      id: header
      Rectangle {
        id: headerRect
        property bool isExpanded: false
        property string currentExpandedSection: ListView.view.expandedSection
        width: parent.width
        height: 40
        color: "transparent"
        Image {
          id: dropdown
          width: 16
          height: 16
          anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
          }
          antialiasing: true
          smooth: true
          fillMode: Image.PreserveAspectFit
          source: (isExpanded) ? "qrc:/img/icons/chevron-downSelect.png" : "qrc:/img/icons/chevron-down.png"
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
          onEntered: { headerRect.color = "#444444" }
          onExited: { headerRect.color = "transparent" }
          onClicked: {
            headerRect.color = "transparent"
            headerRect.isExpanded = !headerRect.isExpanded
          }
        }
        onCurrentExpandedSectionChanged: isExpanded = (currentExpandedSection === section)
        onIsExpandedChanged: {
          if (isExpanded) ListView.view.expandedSection = section
          for (var i = 0; i < menuModel.count; i++) {
            var item = menuModel.get(i);
            if (item.type !== "" && section === item.type) {
              item.isVisible = headerRect.isExpanded
            }
          }
        }
      }
    }
    delegate: Component {
      id: listDelegate
      Rectangle {
        id: menuItem
        property bool selected: ListView.isCurrentItem
        width: parent.width
        color: "transparent"
        visible: (isVisible && isEnabled)
        enabled: isEnabled
        onVisibleChanged: height = (visible) ? 40 : 0
        Behavior on height { SmoothedAnimation { duration: 200 } }
        Image {
          id: itemIcon
          width: 16
          height: 16
          anchors {
            left: parent.left
            leftMargin: 20
            verticalCenter: parent.verticalCenter
          }
          antialiasing: true
          smooth: true
          fillMode: Image.PreserveAspectFit
          source: (parent.selected) ? iconSelect : icon
        }
        Text {
          id: text
          color: {
            if (!parent.enabled) color: "#88000000"
            else if (parent.selected) color: "#AD00FA"
            else color: "#FFFFFF"
          }
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
    id: settingsItem
    property bool selected: false
    width: parent.width
    height: 40
    anchors.bottom: aboutItem.top
    color: "transparent"
    Image {
      id: settingsIcon; width: 16; height: 16
      anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
      antialiasing: true; smooth: true
      fillMode: Image.PreserveAspectFit
      source: (parent.selected) ? "qrc:/img/icons/cogSelect.png" : "qrc:/img/icons/cog.png"
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
    Image {
      id: aboutIcon; width: 16; height: 16
      anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
      antialiasing: true; smooth: true
      fillMode: Image.PreserveAspectFit
      source: (parent.selected) ? "qrc:/img/icons/infoSelect.png" : "qrc:/img/icons/info.png"
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

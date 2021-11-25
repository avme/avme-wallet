/* Copyright (c) 2020-2021 AVME Developers
   Distributed under the MIT/X11 software license, see the accompanying
   file LICENSE or http://www.opensource.org/licenses/mit-license.php. */
import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/qml/components"

// Popup for adding a new ARC20 token from the list in the repo.
AVMEPopup {
  id: addListTokenPopup
  property var tokens: null

  onAboutToShow: {
    tokenList.tokenModel.clear()
    tokens = null
    filterInput.text = ""
    qmlSystem.getARC20TokenList()
  }
  onAboutToHide: {
    tokenList.tokenModel.clear()
    tokens = null
    filterInput.text = ""
  }

  Connections {
    target: tokenList
    function onUpdatedTokenSelection() {
      selectAllCheckbox.checked = tokenList.tokenModel.allTokensSelected()
    }
  }

  Connections {
    target: qmlSystem
    function onGotTokenList(tokenData) {
      tokens = tokenData
      refreshList("")
    }
    function onUpdateAddTokenProgress(current, total) {
      window.infoPopup.info = "Adding tokens... "
      + "(" + current + "/" + total + ")" + "<br>This may take a while."
    }
    function onAddedTokens() {
      window.infoPopup.close()
      addListTokenPopup.close()
    }
  }

  function refreshList(filter) {
    // TODO: redo this - clearing the model clears the selections, that shouldn't happen
    tokenList.tokenModel.clear()
    for (var i = 0; i < tokens.length; i++) {
      var nameMatch = tokens[i]["name"].toUpperCase().includes(filter.toUpperCase())
      var symbolMatch = tokens[i]["symbol"].toUpperCase().includes(filter.toUpperCase())
      if (filter == "" || nameMatch || symbolMatch) {
        tokens[i]["balance"] = ""
        tokenList.tokenModel.append(tokens[i])
      }
    }
    tokenList.tokenModel.sortBySymbol()
    tokenList.currentIndex = -1
  }

  Column {
    id: items
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter
    spacing: 20

    // Enter/Return and Space key override
    Keys.onPressed: {
      if (event.key == Qt.Key_Space) {
        if (tokenList.currentItem != null) {
          tokenList.tokenModel.selectToken(tokenList.currentItem.itemAddress)
        }
      }
      if ((event.key == Qt.Key_Return) || (event.key == Qt.Key_Enter)) {
        if (btnOk.enabled) { btnOk.handleAdd() }
      }
    }

    Text {
      id: info
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      color: "#FFFFFF"
      font.pixelSize: 14.0
      text: (tokens != null)
      ? "Choose one or more tokens from the list." : "Fetching token list, please wait..."
    }

    Rectangle {
      id: listRect
      anchors.horizontalCenter: parent.horizontalCenter
      width: (parent.width * 0.9)
      height: (parent.height * 0.65)
      radius: 5
      color: "#16141F"

      AVMETokenList {
        id: tokenList
        anchors.fill: parent
      }
    }

    Row {
      id: filterRow
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      AVMECheckbox {
        id: selectAllCheckbox
        width: (parent.width * 0.5) - (parent.spacing / 2)
        anchors.verticalCenter: parent.verticalCenter
        enabled: (tokens != null)
        text: "Select/Unselect All"
        onClicked: tokenList.tokenModel.selectAllTokens()
      }
      AVMEInput {
        id: filterInput
        width: (parent.width * 0.5) - (parent.spacing / 2)
        anchors.verticalCenter: parent.verticalCenter
        enabled: (tokens != null)
        label: "Filter by Symbol or Name"
        onTextEdited: addListTokenPopup.refreshList(filterInput.text)
      }
    }

    AVMEButton {
      id: btnOk
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      enabled: (tokenList.selectedTokens > 0)
      text: "Add Selected Tokens"
      onClicked: handleAdd()
      function handleAdd() {
        var tokenArr = []
        for (var i = 0; i < tokenList.tokenModel.count; i++) {
          if (tokenList.tokenModel.get(i).selected) {
            tokenArr.push(tokenList.tokenModel.get(i).address)
          }
        }
        window.infoPopup.info = "Adding tokens...<br>This may take a while."
        window.infoPopup.open()
        qmlSystem.addARC20Tokens(tokenArr)
        // TODO: parallelize adding tokens
      }
    }

    AVMEButton {
      id: btnClose
      width: (parent.width * 0.9)
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Close"
      onClicked: addListTokenPopup.close()
    }
  }
}

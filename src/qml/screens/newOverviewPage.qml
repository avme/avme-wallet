import QtQuick 2.0

Item {
    Rectangle {
        id: mainRectangle
        x: 0
        y: 0
        width: 1094
        height: 768
        color: "#252935"

        Rectangle {
            id: menuRectangle
            x: 0
            y: 0
            width: 95
            height: 768
            color: "#1c2029"
        }

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
                    id: element
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
                color: "#353c4a"
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
                    id: text4
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
                    id: text5
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
                color: "#353c4a"
                radius: 11
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
                    id: tokenName2
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
                    id: tokenName3
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
                x: 164
                y: 66
                width: 80
                height: 20
                color: "#ffffff"
                text: qsTr("BALANCE
")
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
            y: 38
            width: 516
            height: 284
            color: "#2d3542"
            radius: 11
            border.color: "#2d3542"
            border.width: 3
            smooth: true
            Rectangle {
                id: cornerRectangle1
                x: 0
                y: 38
                width: 516
                height: 22
                color: "#1d212a"
            }

            Rectangle {
                id: titleRectangle1
                x: 0
                y: 1
                width: 516
                height: 59
                color: "#1d212a"
                radius: 10
                border.width: 0
                Text {
                    id: element1
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

            ListView {
                id: totalWalletList
                x: 203
                y: 93
                width: 281
                height: 160
                layoutDirection: Qt.LeftToRight
                orientation: ListView.Vertical
                spacing : 35
                model: ListModel {
                    ListElement {
                        name: "Grey"
                        colorCode: "grey"
                    }

                    ListElement {
                        name: "Red"
                        colorCode: "red"
                    }
                }
                delegate: Item {
                    x: 5
                    width: 80
                    height: 40
                    Row {
                        id: row1
                        spacing: 10
                        Rectangle {
                            width: 40
                            height: 40
                            color: colorCode
                        }

                        Text {
                            text: name
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
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
                id: titleRectangle2
                x: 0
                y: 0
                width: 398
                height: 60
                color: "#1d212a"
                radius: 10
                border.width: 0
                Text {
                    id: element2
                    x: 13
                    y: 8
                    width: 271
                    height: 44
                    color: "#ffffff"
                    text: qsTr("Staking")
                    font.pixelSize: 32
                    font.family: "Tahoma"
                }
            }
        }

        Rectangle {
            id: balanceRectangle3
            x: 557
            y: 363
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
                    id: element3
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
        }
    }

}



















/*##^## Designer {
    D{i:0;autoSize:true;height:696;width:1092}D{i:6;anchors_x:13}D{i:8;anchors_height:50;anchors_x:8;anchors_y:6}
D{i:9;anchors_x:64}D{i:11;anchors_height:20;anchors_y:21}D{i:7;anchors_width:369;anchors_x:19}
D{i:13;anchors_height:50;anchors_x:8;anchors_y:3}D{i:14;anchors_x:64}D{i:16;anchors_height:20;anchors_width:80;anchors_x:261;anchors_y:21}
D{i:12;anchors_width:369;anchors_x:19}D{i:19;anchors_x:83}D{i:23;anchors_height:44;anchors_width:284;anchors_x:0;anchors_y:8}
D{i:35;anchors_height:44;anchors_width:284;anchors_x:0;anchors_y:8}D{i:39;anchors_height:44;anchors_width:284;anchors_x:0;anchors_y:8}
}
 ##^##*/

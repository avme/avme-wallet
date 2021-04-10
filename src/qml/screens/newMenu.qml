import QtQuick 2.0

Item {
    width: 95
    height: 768
    Rectangle {
        id: rectangle
        x: 0
        y: 0
        width: 95
        height: 768
        color: "#1c2029"

        Rectangle {
            id: divisor
            x: 8
            width: 79
            height: 1
            color: "#4e525d"
            anchors.top: parent.top
            anchors.topMargin: 100
        }

        Rectangle {
            id: divisor1
            x: 8
            y: 2
            width: 79
            height: 1
            color: "#4e525d"
            anchors.top: parent.top
            anchors.topMargin: 175
        }

        Rectangle {
            id: divisor2
            x: 9
            y: -9
            width: 79
            height: 1
            color: "#4e525d"
            anchors.top: parent.top
            anchors.topMargin: 250
        }

        Rectangle {
            id: divisor3
            x: 8
            y: 8
            width: 79
            height: 1
            color: "#4e525d"
            anchors.top: parent.top
            anchors.topMargin: 325
        }

        Rectangle {
            id: divisor4
            x: 8
            y: 9
            width: 79
            height: 1
            color: "#4e525d"
            anchors.top: parent.top
            anchors.topMargin: 400
        }

        Rectangle {
            id: divisor5
            x: 8
            y: 1
            width: 79
            height: 1
            color: "#4e525d"
            anchors.top: parent.top
            anchors.topMargin: 475
        }

        Image {
            id: logo
            y: 8
            height: 80
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 8
            source: "../../img/avme_logo.png"
            fillMode: Image.PreserveAspectFit
        }

        Rectangle {
            id: divisor6
            x: 8
            y: 9
            width: 79
            height: 1
            color: "#4e525d"
            anchors.top: parent.top
            anchors.topMargin: 550
        }

        Rectangle {
            id: divisor7
            x: 8
            y: 8
            width: 79
            height: 1
            color: "#4e525d"
            anchors.top: parent.top
            anchors.topMargin: 625
        }

        Rectangle {
            id: divisor8
            x: 8
            y: 5
            width: 79
            height: 1
            color: "#4e525d"
            anchors.top: parent.top
            anchors.topMargin: 700
        }

        Rectangle {
            id: overviewRectangle
            x: 0
            y: 107
            width: 95
            height: 62
            color: "#1c2029"
            border.width: 0

            Text {
                id: overviewText
                y: 48
                height: 14
                color: "#ffffff"
                text: qsTr("Overview")
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 8
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
                font.pixelSize: 15
            }

            Image {
                id: overviewImage
                x: -109
                y: 2
                width: 40
                height: 40
                antialiasing: true
                smooth: true
                enabled: false
                anchors.right: parent.right
                source: "../../img/icons/grid.png"
                fillMode: Image.PreserveAspectFit
                anchors.rightMargin: 7
                anchors.left: parent.left
                anchors.leftMargin: 8
            }
        }

        Rectangle {
            id: sendRectangle
            x: 0
            y: 182
            width: 95
            height: 62
            color: "#1c2029"
            border.width: 0

            Image {
                id: sendImage
                x: -104
                y: 0
                width: 40
                height: 40
                smooth: true
                anchors.right: parent.right
                source: "../../img/icons/upload.png"
                fillMode: Image.PreserveAspectFit
                anchors.rightMargin: 7
                anchors.left: parent.left
                anchors.leftMargin: 8
                antialiasing: true
                enabled: false
            }

            Text {
                id: sendText
                y: 49
                height: 14
                color: "#ffffff"
                text: qsTr("Send")
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.left: parent.left
                anchors.leftMargin: 8
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
                font.pixelSize: 15
            }
        }

        Rectangle {
            id: transactionRectangle
            x: 0
            y: 257
            width: 95
            height: 62
            color: "#1c2029"
            border.width: 0

            Image {
                id: transactionImage
                x: 123
                y: 0
                width: 40
                height: 40
                smooth: true
                anchors.right: parent.right
                source: "../../img/icons/directions.png"
                anchors.rightMargin: 8
                fillMode: Image.PreserveAspectFit
                anchors.left: parent.left
                anchors.leftMargin: 8
                enabled: false
                antialiasing: true
            }

            Text {
                id: transactionText
                y: 46
                height: 14
                color: "#ffffff"
                text: qsTr("Transactions")
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.left: parent.left
                anchors.leftMargin: 8
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
                font.pixelSize: 15
            }
        }

        Rectangle {
            id: stakingRectangle
            x: 0
            y: 332
            width: 95
            height: 62
            color: "#1c2029"
            border.width: 0

            Image {
                id: stakingImage
                x: -93
                y: 0
                width: 40
                height: 40
                smooth: true
                anchors.right: parent.right
                source: "../../img/icons/coin.png"
                fillMode: Image.PreserveAspectFit
                anchors.rightMargin: 8
                anchors.left: parent.left
                anchors.leftMargin: 8
                antialiasing: true
                enabled: false
            }

            Text {
                id: stakingText
                y: 48
                height: 14
                color: "#ffffff"
                text: qsTr("Staking")
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.left: parent.left
                anchors.leftMargin: 8
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
                font.pixelSize: 15
            }
        }

        Rectangle {
            id: exchangeRectangle
            x: 0
            y: 407
            width: 95
            height: 62
            color: "#1c2029"
            border.width: 0

            Image {
                id: exchangeImage
                x: -113
                y: 8
                width: 40
                height: 40
                smooth: true
                anchors.right: parent.right
                source: "../../img/icons/credit-card.png"
                anchors.rightMargin: 8
                fillMode: Image.PreserveAspectFit
                anchors.left: parent.left
                anchors.leftMargin: 8
                enabled: false
                antialiasing: true
            }

            Text {
                id: exchangeText
                y: 48
                height: 14
                color: "#ffffff"
                text: qsTr("Exchange")
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 8
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
                font.pixelSize: 15
            }
        }

        Rectangle {
            id: configExchange
            x: 0
            y: 482
            width: 95
            height: 62
            color: "#1c2029"
            border.width: 0

            Image {
                id: configImage
                x: -103
                y: 2
                width: 40
                height: 40
                smooth: true
                anchors.right: parent.right
                source: "../../img/icons/cog.png"
                fillMode: Image.PreserveAspectFit
                anchors.rightMargin: 8
                anchors.left: parent.left
                anchors.leftMargin: 8
                antialiasing: true
                enabled: false
            }

            Text {
                id: configText
                y: 48
                height: 14
                color: "#ffffff"
                text: qsTr("Config")
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 8
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
                font.pixelSize: 15
            }
        }

        Rectangle {
            id: extrasRectangle
            x: 0
            y: 557
            width: 95
            height: 62
            color: "#1c2029"
            border.width: 0

            Image {
                id: extrasImage
                x: -97
                y: 4
                width: 40
                height: 40
                smooth: true
                anchors.right: parent.right
                source: "../../img/icons/microchip.png"
                anchors.rightMargin: 8
                fillMode: Image.PreserveAspectFit
                anchors.left: parent.left
                anchors.leftMargin: 8
                enabled: false
                antialiasing: true
            }

            Text {
                id: extrasText
                y: 49
                height: 14
                color: "#ffffff"
                text: qsTr("Extras")
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 8
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
                font.pixelSize: 15
            }
        }

        Rectangle {
            id: aboutRectangle
            x: 0
            y: 632
            width: 95
            height: 62
            color: "#1c2029"
            border.width: 0

            Image {
                id: infoImage
                x: -123
                y: 7
                width: 40
                height: 40
                smooth: true
                anchors.right: parent.right
                source: "../../img/icons/info.png"
                fillMode: Image.PreserveAspectFit
                anchors.rightMargin: 8
                anchors.left: parent.left
                anchors.leftMargin: 8
                antialiasing: true
                enabled: false
            }

            Text {
                id: infoText
                y: 47
                height: 14
                color: "#ffffff"
                text: qsTr("About")
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 8
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
                font.pixelSize: 15
            }
        }

        Rectangle {
            id: quitRectangle
            y: 706
            height: 62
            color: "#1c2029"
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            border.width: 0

            Text {
                id: quitText
                y: 43
                height: 14
                color: "#ffffff"
                text: qsTr("Quit")
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 8
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
                font.pixelSize: 15
            }

            Image {
                id: quitImage
                x: -124
                y: 1
                width: 40
                height: 40
                smooth: true
                anchors.right: parent.right
                source: "../../img/icons/log-out.png"
                fillMode: Image.PreserveAspectFit
                anchors.rightMargin: 8
                anchors.left: parent.left
                anchors.leftMargin: 8
                antialiasing: true
                enabled: false
            }
        }
    }

}



















/*##^## Designer {
    D{i:2;anchors_y:88}D{i:3;anchors_y:88}D{i:4;anchors_y:88}D{i:5;anchors_y:88}D{i:6;anchors_y:88}
D{i:7;anchors_y:88}D{i:8;anchors_width:80;anchors_x:8}D{i:9;anchors_y:88}D{i:10;anchors_y:88}
D{i:11;anchors_y:88}D{i:13;anchors_width:78;anchors_x:9}D{i:14;anchors_width:80;anchors_x:8}
D{i:17;anchors_width:78;anchors_x:10}D{i:19;anchors_width:80;anchors_x:8}D{i:20;anchors_width:78;anchors_x:10}
D{i:22;anchors_width:80;anchors_x:8}D{i:23;anchors_width:78;anchors_x:9}D{i:26;anchors_width:78;anchors_x:9}
D{i:28;anchors_width:80;anchors_x:8}D{i:29;anchors_width:78;anchors_x:8}D{i:32;anchors_width:78;anchors_x:12}
D{i:35;anchors_width:78;anchors_x:8}D{i:37;anchors_width:78;anchors_x:9}D{i:36;anchors_width:95;anchors_x:0}
}
 ##^##*/

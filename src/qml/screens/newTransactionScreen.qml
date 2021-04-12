import QtQuick 2.0
import QtQuick.Controls 2.2

Item {
    Rectangle {
        id: bg
        x: 0
        y: 0
        width: 1200
        height: 720
        color: "#252935"

        Rectangle {
            id: transactionRect
            height: 330
            color: "#343b4b"
            radius: 20
            anchors.top: parent.top
            anchors.topMargin: 130
            anchors.right: parent.right
            anchors.rightMargin: 80
            anchors.left: parent.left
            anchors.leftMargin: 80

            Text {
                color: "#ffffff"
                text: qsTr("From: $address")
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.right: parent.right
                anchors.rightMargin: 933
                anchors.left: parent.left
                anchors.leftMargin: 25
                font.pixelSize: 20
            }

            Rectangle {
                id: btnTransaction
                x: 816
                y: 182
                width: 200
                height: 50
                color: "#2d183f"
                radius: 10
                anchors.right: parent.right
                anchors.rightMargin: 25
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 25

                Text {
                    color: "#ffffff"
                    text: qsTr("Send")
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 28
                }
            }

            Text {
                x: -5
                y: 8
                color: "#ffffff"
                text: qsTr("To:")
                anchors.right: parent.right
                anchors.rightMargin: 985
                anchors.left: parent.left
                anchors.topMargin: 70
                anchors.top: parent.top
                font.pixelSize: 20
                anchors.leftMargin: 25
            }

            ComboBox {
                id: assetSelector
                x: 855
                y: 62

                Text {
                    x: 0
                    color: "#ffffff"
                    text: qsTr("Asset")
                    anchors.top: parent.top
                    anchors.topMargin: -28
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 20
                }
            }

            Text {
                x: 0
                color: "#ffffff"
                text: qsTr("Amount")
                anchors.top: parent.top
                anchors.topMargin: 130
                anchors.left: parent.left
                font.pixelSize: 20
                anchors.right: parent.right
                anchors.leftMargin: 25
                anchors.rightMargin: 933
            }

            TextField {
                id: addressTextfield
                width: 561
                height: 40
                text: qsTr("Text Field")
                anchors.top: parent.top
                anchors.topMargin: 62
                anchors.left: parent.left
                anchors.leftMargin: 113
            }

            TextField {
                id: amountTextfield
                x: 6
                y: -8
                width: 561
                height: 40
                text: qsTr("Text Field")
                anchors.left: parent.left
                anchors.topMargin: 122
                anchors.top: parent.top
                anchors.leftMargin: 113
            }

            Text {
                x: -8
                y: 5
                color: "#ffffff"
                text: qsTr("Data:")
                anchors.left: parent.left
                anchors.topMargin: 190
                anchors.top: parent.top
                font.pixelSize: 20
                anchors.leftMargin: 25
            }

            TextField {
                id: dataTextField
                x: 11
                y: -13
                width: 561
                height: 40
                text: qsTr("Text Field")
                anchors.left: parent.left
                anchors.topMargin: 185
                anchors.top: parent.top
                anchors.leftMargin: 113
            }

            Text {
                x: -9
                y: 5
                color: "#ffffff"
                text: qsTr("Fees:")
                anchors.left: parent.left
                anchors.topMargin: 268
                anchors.top: parent.top
                font.pixelSize: 20
                anchors.right: parent.right
                anchors.leftMargin: 25
                anchors.rightMargin: 933
            }

            Text {
                x: 0
                y: 1
                height: 24
                color: "#ffffff"
                text: qsTr("Fees:")
                anchors.left: parent.left
                anchors.topMargin: 268
                anchors.top: parent.top
                font.pixelSize: 20
                anchors.right: parent.right
                anchors.leftMargin: 25
                anchors.rightMargin: 933
            }

            Text {
                x: 3
                y: 9
                height: 24
                color: "#ffffff"
                text: qsTr("Total:")
                anchors.left: parent.left
                anchors.topMargin: 268
                anchors.top: parent.top
                font.pixelSize: 20
                anchors.right: parent.right
                anchors.leftMargin: 479
                anchors.rightMargin: 479
            }
        }
    }
}



/*##^## Designer {
    D{i:0;autoSize:true;height:720;width:1200}D{i:3;anchors_x:23;anchors_y:18}D{i:5;anchors_x:53;anchors_y:18}
D{i:6;anchors_x:23;anchors_y:18}D{i:8;anchors_x:0;anchors_y:0}D{i:9;anchors_x:23;anchors_y:18}
D{i:10;anchors_x:113;anchors_y:62}D{i:11;anchors_x:113;anchors_y:62}D{i:12;anchors_x:23;anchors_y:18}
D{i:13;anchors_x:113;anchors_y:62}D{i:14;anchors_x:23;anchors_y:18}D{i:15;anchors_x:23;anchors_y:18}
D{i:16;anchors_x:23;anchors_y:18}D{i:2;anchors_width:200;anchors_x:52;anchors_y:129}
}
 ##^##*/

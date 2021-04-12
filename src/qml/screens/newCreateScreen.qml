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
        Image {
            id: logobg
            x: 481
            y: 0
            width: 1000
            height: 1100
            source: "../../img/avme_logo.png"
            anchors.horizontalCenterOffset: 381
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 0.15
            fillMode: Image.PreserveAspectFit
        }
    }
    Column {
        id: column
        width: parent.width / 4
        height: parent.height
        anchors.horizontalCenterOffset: -(parent.width /3)
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            id: menuRectangle
            width: parent.width
            height: parent.height / 1.5
            color: "#2d3542"
            radius: 15
            border.width: 0
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Text {
                color: "#ffffff"
                text: qsTr("Wallet Path")
                anchors.top: parent.top
                anchors.topMargin: 25
                anchors.left: parent.left
                anchors.leftMargin: 25
                font.pixelSize: 20
            }

            Rectangle {
                id: btnCreate
                x: 65
                y: 220
                width: 250
                height: 50
                color: "#2d183f"
                radius: 10
                border.width: 0
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 25

                Text {
                    id: element4
                    color: "#ffffff"
                    text: qsTr("Create Wallet")
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 24
                }
            }

            CheckBox {
                id: pathCheck
                x: 25
                width: 201
                height: 24
                text: qsTr("Use Default Path")
                anchors.top: parent.top
                anchors.topMargin: 55
                checked: false
            }

            TextField {
                id: pathField
                x: 26
                y: 85
                width: 249
                height: 40
                text: qsTr("Text Field")
            }

            CheckBox {
                id: phraseCheck
                x: 25
                y: 301
                text: qsTr("Use existing Phrase")
            }

            TextField {
                id: phraseField
                x: 26
                y: 338
                width: 249
                height: 40
                text: qsTr("Text Field")
            }

            Text {
                x: 2
                y: -5
                color: "#ffffff"
                text: qsTr("Wallet Password")
                anchors.left: parent.left
                anchors.topMargin: 131
                anchors.top: parent.top
                font.pixelSize: 20
                anchors.leftMargin: 25
            }

            TextField {
                id: passwordField
                x: 26
                y: 161
                width: 249
                height: 40
                text: qsTr("Text Field")
            }
        }
    }

}

/*##^## Designer {
    D{i:0;autoSize:true;height:720;width:1200}D{i:7;anchors_height:50;anchors_width:2250;anchors_x:72;anchors_y:18}
D{i:8;anchors_y:25}
}
 ##^##*/

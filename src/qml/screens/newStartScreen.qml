import QtQuick 2.0

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
            anchors.horizontalCenterOffset: 381
            opacity: 0.15
            anchors.horizontalCenter: parent.horizontalCenter
            source: "../../img/avme_logo.png"
            fillMode: Image.PreserveAspectFit
        }

    }

    Column {
        id: column
        width: parent.width / 5
        height: parent.height
        anchors.horizontalCenterOffset: -(parent.width /3)
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            id: rectangle
            width: parent.width
            height: 50
            color: "#2d183f"
            radius: 10
            border.width: 0
            anchors.verticalCenterOffset: -(parent.height / 10) *1
            anchors.verticalCenter: parent.verticalCenter

            Text {
                color: "#ffffff"
                text: qsTr("Create Wallet")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.fill: parent
                font.pixelSize: 24
            }
        }

        Rectangle {
            id: rectangle1
            width: parent.width
            height: 50
            color: "#2d183f"
            radius: 10
            border.width: 0
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 0

            Text {
                x: 0
                y: -72
                color: "#ffffff"
                text: qsTr("Load Wallet")
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Image {
            id: image
            width: 150
            height: 150
            anchors.top: parent.top
            anchors.topMargin: (parent.height / 20) * 1
            source: "../../img/avme_logo.png"
            fillMode: Image.PreserveAspectFit

            Text {
                id: element
                color: "#ffffff"
                text: qsTr("AVME Wallet")
                font.family: "Tahoma"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
                anchors.right: parent.right
                anchors.rightMargin: -30
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 60
            }
        }
    }

}





/*##^## Designer {
    D{i:0;autoSize:true;height:720;width:1200}D{i:5;anchors_x:0;anchors_y:-263}D{i:7;anchors_x:0;anchors_y:"-263"}
D{i:3;anchors_height:400;anchors_width:200;anchors_x:456;anchors_y:109}
}
 ##^##*/

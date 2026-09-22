import QtQuick

Rectangle {
    id: root
    property string iconName: ""
    property string label: ""

    height: Theme.rowHeight
    radius: Theme.radius
    color: ma.containsMouse ? Theme.hoverBackground : "transparent"

    signal clicked()

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 8
        spacing: 8

        Icon {
            name: root.iconName
            color: Theme.iconColor
            width: 15
            height: 15
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: root.label
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.textPrimary
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}

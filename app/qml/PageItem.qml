import QtQuick

Column {
    id: root
    property var pageData
    property int depth: 0
    property bool expanded: false
    readonly property bool hasChildren: !!(pageData.children && pageData.children.length > 0)

    signal pageClicked(var page)

    width: parent ? parent.width : 244
    spacing: 1

    // 行本体
    Rectangle {
        width: root.width
        height: 28
        radius: 4
        color: rowMa.containsMouse ? "#eeeeec" : "transparent"

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 4 + root.depth * 16
            spacing: 4

            // 展开/折叠三角
            Item {
                width: 16
                height: 20
                Text {
                    anchors.centerIn: parent
                    text: root.hasChildren ? (root.expanded ? "▾" : "▸") : ""
                    font.pixelSize: 10
                    color: "#9a9a97"
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: root.hasChildren
                    onClicked: root.expanded = !root.expanded
                }
            }

            Text {
                text: root.pageData.icon || "📄"
                font.pixelSize: 14
            }
            Text {
                text: root.pageData.name
                font.pixelSize: 14
                color: "#37352f"
                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: rowMa
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.pageClicked(root.pageData)
        }
    }

    // 子页面（递归）
    Column {
        width: root.width
        visible: root.expanded && root.hasChildren
        spacing: 1

        Repeater {
            model: root.hasChildren ? root.pageData.children : []
            delegate: Loader {
                // 注意：这里不能直接写 `PageItem { ... }`，
                // 那样是“类型直接递归引用”，会被 QML 编译器判为
                // "Type is instantiated recursively" 而加载失败。
                // 改用 Loader 按 URL 异步加载同一个文件，绕开编译期的递归类型解析。
                width: root.width
                source: "PageItem.qml"

                onLoaded: {
                    item.pageData = modelData
                    item.depth = root.depth + 1
                    item.pageClicked.connect(function(page) {
                        root.pageClicked(page)
                    })
                }
            }
        }
    }
}

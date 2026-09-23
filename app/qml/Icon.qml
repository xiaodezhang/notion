import QtQuick
import QtQuick.Effects

// 用真实的 SVG 文件渲染图标（默认接的是 Lucide，见 qml/icons/ 目录），
// 不再用 Canvas 手画。svg 本身画的是黑色（#000000），
// 通过 MultiEffect 的 colorization 动态染成 Theme 里定义的颜色，
// 这样换主题色时图标也会跟着变，用法和之前完全一样：
// Icon { name: "folder"; color: Theme.iconColor }
Item {
    id: root
    property string name: "page"
    property color color: "#37352f"

    implicitWidth: 16
    implicitHeight: 16

    // 逻辑名 -> 实际 svg 文件名的映射。
    // 换一套图标库（Tabler / Material Symbols…）时，只需要改这张表
    // 和 icons/ 目录里的文件，调用方（Sidebar.qml 等）完全不用动。
    readonly property var _fileMap: ({
        "page": "file-text",
        "folder": "folder",
        "chevron": "chevron-right",
        "search": "search",
        "inbox": "inbox",
        "settings": "settings",
        "trash": "trash",
        "plus": "plus",
        "folder-plus": "folder-plus"
    })

    Image {
        id: img
        anchors.fill: parent
        source: "qrc:/icons/" + (root._fileMap[root.name] || root.name) + ".svg"
        sourceSize: Qt.size(root.width * 2, root.height * 2) // 2x 栅格化，小尺寸也清晰
        smooth: true
        visible: false // 真正显示的是下面染色后的效果
    }

    MultiEffect {
        anchors.fill: img
        source: img
        colorization: 1.0
        colorizationColor: root.color
    }
}

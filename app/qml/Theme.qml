pragma Singleton
import QtQuick

QtObject {
    // 品牌色
    readonly property color accent: "#5b6bd6"

    // 背景
    readonly property color sidebarBackground: "#fbfbfa"
    readonly property color contentBackground: "#ffffff"
    readonly property color hoverBackground: "#eeeeec"
    readonly property color currentBackground: "#e0e0e0"
    readonly property color borderColor: "#e9e9e7"

    // 文本 / 图标
    readonly property color textPrimary: "#4a4a47"
    readonly property color textSecondary: "#9a9a97"
    readonly property color iconColor: "#6b6b68"

    // 尺寸
    readonly property int rowHeight: 28
    readonly property int indent: 16
    readonly property int radius: 4
    readonly property int sidebarWidth: 260

    // 字体
    readonly property int fontSizeNormal: 14
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeTitle: 28
}

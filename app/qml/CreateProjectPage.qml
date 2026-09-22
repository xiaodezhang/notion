import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

// ============================================================
// CreateProjectPage.qml
// 仿 Claude "新建项目" 弹窗/页面样式
//
// 用法示例（在你的 Main.qml 里）：
//
//   CreateProjectPage {
//       anchors.fill: parent
//       visible: false
//       onCancelled: visible = false
//       onCreateRequested: (name, description, color) => {
//           projectModel.create_project(name, description, color)
//           visible = false
//       }
//   }
//
// 如果项目里已经有全局 Theme 单例，可以把下面 QtObject { id: theme }
// 换成 `import "Theme.js" as Theme` 或你项目的 Theme 单例引用。
// ============================================================

Item {
    id: root

    // ---------------- 对外信号 ----------------
    signal createRequested(string name, string description, string colorName)
    signal cancelled()

    // ---------------- 内部状态 ----------------
    property string selectedColor: "coral"
    property var colorOptions: [
        { name: "coral",   value: "#D97757" },
        { name: "sage",    value: "#6A9C78" },
        { name: "sky",     value: "#5B8DEF" },
        { name: "plum",    value: "#8E6FB0" },
        { name: "amber",   value: "#D9A441" },
        { name: "slate",   value: "#6B7280" }
    ]

    function selectedColorValue() {
        for (var i = 0; i < colorOptions.length; i++) {
            if (colorOptions[i].name === selectedColor)
                return colorOptions[i].value
        }
        return colorOptions[0].value
    }

    // ---------------- 内置简易主题（可被外部 Theme 覆盖） ----------------
    QtObject {
        id: theme
        readonly property color pageBackground: "#FAFAF8"
        readonly property color cardBackground: "#FFFFFF"
        readonly property color textPrimary: "#1F1E1D"
        readonly property color textSecondary: "#77726C"
        readonly property color borderColor: "#E8E5E0"
        readonly property color inputBackground: "#F5F3F0"
        readonly property int radius: 12
        readonly property int radiusSmall: 8
    }

    anchors.fill: parent

    // 半透明遮罩背景
    Rectangle {
        anchors.fill: parent
        color: "#00000055"

        MouseArea {
            anchors.fill: parent
            onClicked: root.cancelled()
        }
    }

    // 居中卡片
    Rectangle {
        id: card
        width: Math.min(520, parent.width - 64)
        height: contentColumn.implicitHeight + 48
        anchors.centerIn: parent
        radius: theme.radius
        color: theme.cardBackground
        border.width: 1
        border.color: theme.borderColor

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.6
            shadowColor: "#33000000"
            shadowVerticalOffset: 6
        }

        // 阻止点击卡片内部时冒泡到遮罩关闭弹窗
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 24
            spacing: 20

            // ---------- 标题栏 ----------
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "新建项目"
                    font.pixelSize: 20
                    font.bold: true
                    color: theme.textPrimary
                    Layout.fillWidth: true
                }

                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    color: closeMa.containsMouse ? theme.inputBackground : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "\u2715"
                        font.pixelSize: 13
                        color: theme.textSecondary
                    }

                    MouseArea {
                        id: closeMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.cancelled()
                    }
                }
            }

            // ---------- 颜色 + 图标预览 ----------
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Rectangle {
                    id: iconPreview
                    width: 56
                    height: 56
                    radius: theme.radiusSmall
                    color: root.selectedColorValue()

                    Text {
                        anchors.centerIn: parent
                        text: nameField.text.length > 0
                              ? nameField.text.charAt(0).toUpperCase()
                              : "P"
                        color: "white"
                        font.pixelSize: 22
                        font.bold: true
                    }
                }

                RowLayout {
                    spacing: 8
                    Layout.fillWidth: true

                    Repeater {
                        model: root.colorOptions

                        delegate: Rectangle {
                            required property var modelData
                            width: 22
                            height: 22
                            radius: 11
                            color: modelData.value
                            border.width: root.selectedColor === modelData.name ? 2 : 0
                            border.color: theme.textPrimary

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectedColor = modelData.name
                            }
                        }
                    }
                }
            }

            // ---------- 名称输入 ----------
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "项目名称"
                    font.pixelSize: 13
                    color: theme.textSecondary
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: theme.radiusSmall
                    color: theme.inputBackground
                    border.width: nameField.activeFocus ? 1 : 0
                    border.color: root.selectedColorValue()

                    TextField {
                        id: nameField
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        placeholderText: "例如：产品需求梳理"
                        background: null
                        font.pixelSize: 14
                        color: theme.textPrimary
                        selectByMouse: true
                    }
                }
            }

            // ---------- 说明文本 ----------
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "项目说明（可选）"
                    font.pixelSize: 13
                    color: theme.textSecondary
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 96
                    radius: theme.radiusSmall
                    color: theme.inputBackground
                    border.width: descField.activeFocus ? 1 : 0
                    border.color: root.selectedColorValue()

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true

                        TextArea {
                            id: descField
                            placeholderText: "告诉 Claude 这个项目要做什么，之后它会更懂你的意图……"
                            wrapMode: TextArea.Wrap
                            background: null
                            font.pixelSize: 13
                            color: theme.textPrimary
                            selectByMouse: true
                        }
                    }
                }
            }

            // ---------- 底部按钮 ----------
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: 10

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 84
                    height: 36
                    radius: theme.radiusSmall
                    color: cancelMa.containsMouse ? theme.inputBackground : "transparent"
                    border.width: 1
                    border.color: theme.borderColor

                    Text {
                        anchors.centerIn: parent
                        text: "取消"
                        font.pixelSize: 13
                        color: theme.textPrimary
                    }

                    MouseArea {
                        id: cancelMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.cancelled()
                    }
                }

                Rectangle {
                    width: 108
                    height: 36
                    radius: theme.radiusSmall
                    opacity: nameField.text.trim().length > 0 ? 1.0 : 0.5
                    color: root.selectedColorValue()

                    Text {
                        anchors.centerIn: parent
                        text: "创建项目"
                        font.pixelSize: 13
                        font.bold: true
                        color: "white"
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: nameField.text.trim().length > 0
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.createRequested(
                                nameField.text.trim(),
                                descField.text.trim(),
                                root.selectedColor
                            )
                        }
                    }
                }
            }
        }
    }

    // 弹出时自动聚焦到名称输入框
    onVisibleChanged: {
        if (visible) {
            nameField.forceActiveFocus()
        } else {
            nameField.text = ""
            descField.text = ""
        }
    }
}

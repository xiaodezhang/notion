import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: sidebar
    width: Theme.sidebarWidth
    color: Theme.sidebarBackground
    border.width: 1
    border.color: Theme.borderColor

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 工作区切换栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            color: wsMa.containsMouse ? Theme.hoverBackground : "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 8
                spacing: 8

                Rectangle {
                    width: 22
                    height: 22
                    radius: 5
                    color: Theme.accent
                    Text {
                        anchors.centerIn: parent
                        text: "N"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 12
                    }
                }
                Text {
                    text: "我的工作区"
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    color: Theme.textPrimary
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Icon {
                    name: "chevron"
                    color: Theme.textSecondary
                    width: 11
                    height: 11
                    rotation: 90
                }
            }
            MouseArea {
                id: wsMa
                anchors.fill: parent
                hoverEnabled: true
            }
        }

        // 快捷入口
        Column {
            Layout.fillWidth: true
            Layout.bottomMargin: 6
            Layout.topMargin: 4
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            spacing: 1

            SidebarAction {
              width: parent.width
              iconName: "trash"
              label: "回收站" 
            }
            SidebarAction { 
              width: parent.width 
              iconName: "plus" 
              label: "新建页面" 
              onClicked: {
                pageTreeModel.add_node("Untitled", "page")
              }
            }
            SidebarAction { 
              width: parent.width 
              iconName: "folder-plus" 
              label: "新建项目" 
              onClicked: {
                pageTreeModel.add_node("Project", "folder")
              }
            }
        }


        Item { Layout.preferredHeight: 8 }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            height: 1
            color: Theme.borderColor
        }

        Item { Layout.preferredHeight: 4 }

        // 页面树：数据来自后台模型 pageTreeModel（在 main.py 里通过
        // setContextProperty 注入），不再在 QML 里写死数据
        TreeView {
            id: treeView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: pageTreeModel
            boundsBehavior: Flickable.StopAtBounds

            Component.onCompleted: {
              Qt.callLater(() => {
                var indexes = pageTreeModel.get_expanded_indexes()
                for (var i = 0; i < indexes.length; i++) {
                  treeView.expandToIndex(indexes[i])
                }
              })
            }

            onExpanded: (row, depth) => {
              pageTreeModel.set_expanded(treeView.index(row, 0), true)
            }

            onCollapsed: (row, depth) => {
              pageTreeModel.set_expanded(treeView.index(row, 0), false)
            }

            selectionModel: ItemSelectionModel {
              id: treeSelectionModel
              model: pageTreeModel
            }

            Connections {
              target: pageTreeModel
              function onCurrentIndexChanged(index) {
                treeSelectionModel.setCurrentIndex(index, ItemSelectionModel.ClearAndSelect)
                treeView.expandToIndex(index)
              }
            }

            delegate: Item {
                id: treeDelegate

                // TreeView 会自动给这些声明为 required 的属性赋值
                required property bool expanded
                required property bool hasChildren
                required property int depth
                required property int row
                required property var model
                required property bool current

                implicitWidth: treeView.width
                implicitHeight: Theme.rowHeight

                Rectangle {
                    anchors.fill: parent
                    color: treeDelegate.current ? Theme.currentBackground : (rowMa.containsMouse ? Theme.hoverBackground : "transparent")
                    radius: Theme.radius

                    MouseArea {
                        id: rowMa
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            var idx = treeView.index(treeDelegate.row, 0)
                            treeSelectionModel.setCurrentIndex(idx, ItemSelectionModel.ClearAndSelect)
                            pageTreeModel.set_current(idx)

                        }
                    }
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 4 + treeDelegate.depth * Theme.indent
                        spacing: 4

                        // 展开/折叠指示箭头
                        Item {
                            width: 16
                            height: Theme.rowHeight
                            Icon {
                                anchors.centerIn: parent
                                visible: treeDelegate.hasChildren
                                name: "chevron"
                                width: 10
                                height: 10
                                color: Theme.textSecondary
                                rotation: treeDelegate.expanded ? 90 : 0
                                Behavior on rotation { NumberAnimation { duration: 100 } }
                            }

                            MouseArea {
                              anchors.fill: parent
                              enabled: treeDelegate.hasChildren
                              onClicked: (mouse) => {
                                treeView.toggleExpanded(treeDelegate.row)
                                mouse.accepted = true
                              }
                            }
                        }

                        // 文件夹 / 页面 图标
                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: treeDelegate.model.nodeType === "folder" ? "folder" : "page"
                            color: Theme.iconColor
                            width: 15
                            height: 15
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: treeDelegate.model.display
                            font.pixelSize: Theme.fontSizeNormal
                            color: Theme.textPrimary
                            elide: Text.ElideRight
                        }
                    }

                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            height: 1
            color: Theme.borderColor
        }

        // 底部操作
        Column {
            Layout.fillWidth: true
            Layout.topMargin: 4
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            spacing: 1

            SidebarAction { width: parent.width; iconName: "search"; label: "搜索" }
            SidebarAction { width: parent.width; iconName: "inbox"; label: "收件箱" }
            SidebarAction { width: parent.width; iconName: "settings"; label: "设置" }
        }



    }
}

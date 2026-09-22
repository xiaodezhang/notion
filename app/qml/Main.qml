import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window
    width: 1080
    height: 720
    visible: true
    title: "Notion"
    color: Theme.contentBackground

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Sidebar {
            Layout.fillHeight: true
        }

        Page2 {
          Layout.fillWidth: true
          Layout.fillHeight: true

        }
    }
    // Main.qml 里
    CreateProjectPage {
      id: createProjectPage
      anchors.fill: parent
      visible: false

      onCancelled: visible = false
      onCreateRequested: (name, description, colorName) => {
        pageTreeModel.add_node(name, "folder")
        visible = false
      }
    }

    Shortcut {
      sequences: [StandardKey.Paste]   // 或者 "Ctrl+V"
      onActivated: pageTreeModel.paste_files()
    }
  }

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
}

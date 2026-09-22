import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine

Rectangle {
  color: Theme.contentBackground
  property var title: "开始"
  property var url: ''

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 12

    WebEngineView {
      Layout.fillWidth: true
      Layout.fillHeight: true
      url: pageTreeModel.current_url
    }
  }
}

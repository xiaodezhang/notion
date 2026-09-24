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

    ProgressBar {
      id: bar
      Layout.fillWidth: true
      height: 2
      indeterminate: true
      visible: false

      background: Rectangle {
        implicitHeight: 2
        color: "#e0e0e0"
      }

      contentItem: Item {
        implicitHeight: 2
        clip: true                       // 超出部分裁掉

        Rectangle {
          id: slider
          width: parent.width * 0.3
          height: parent.height
          color: "#3366cc"

          SequentialAnimation on x {
            running: bar.indeterminate && bar.visible
            loops: Animation.Infinite
            NumberAnimation {
              from: -slider.width
              to: bar.width
              duration: 1200
              easing.type: Easing.InOutQuad
            }
          }
        }
      }
    }

    Icon {
      id: upload
      name: "upload"
      Layout.alignment: Qt.AlignRight
      Layout.rightMargin: 10
      width: 11
      height: 11
      onClicked: {
        bar.visible = true
        pageTreeModel.share()
      }
    }

    WebEngineView {
      Layout.fillWidth: true
      Layout.fillHeight: true
      url: pageTreeModel.current_url
    }

    // Connect
    Connections {
      target: pageTreeModel
      function onUploadDone(index) {
        bar.visible = false
      }
    }

  }
}

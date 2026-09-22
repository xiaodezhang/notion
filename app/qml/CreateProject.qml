import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
  width: 400
  height: 400
  title: "Create Project"

  standardButtons: Dialog.Ok | Dialog.Cancel

  contentItem: ColumnLayout {
    anchors.fill: parent

    Text {
      text: "Create project"
    }

    TextField {
      Layout.fillWidth: true
      placeholderText: "Name your project"
    }

    Text {
      text: "What are you trying to achieve?"
    }

    TextArea{
      Layout.fillWidth: true
      height: 200
      placeholderText: "Describe your project, goals, subject, etc..."
    }


    RowLayout {
      Item{Layout.fillWidth: true}

      Button {
        text: "Cancel"
      }

      Button {
        text: "Create project"
      }
    }

  }
}

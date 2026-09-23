import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl
from PySide6.QtWebEngineQuick import QtWebEngineQuick
from platformdirs import user_data_path

from page_tree_model import PageTreeModel
from nvim import Nvim
import resources_rc


def main():
    app = QGuiApplication(sys.argv)
    app.setWindowIcon(QIcon(":/icons/hive.png"))
    engine = QQmlApplicationEngine()
    QtWebEngineQuick.initialize()

    # 后台数据模型：QML 的 TreeView 直接绑定它，不再在 QML 里写死数据
    path = user_data_path() / "notion" / "vault"
    nvim = Nvim()
    page_model = PageTreeModel(path, nvim)
    engine.rootContext().setContextProperty("pageTreeModel", page_model)

    # qml_file = Path(__file__).resolve().parent / "qml" / "Main.qml"
    qml_file = QUrl("qrc:/qml/Main.qml")
    # engine.load(QUrl.fromLocalFile(str(qml_file)))
    engine.load(qml_file)
    app.aboutToQuit.connect(lambda: page_model.save())

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())



if __name__ == "__main__":
    main()

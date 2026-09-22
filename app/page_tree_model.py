"""
侧边栏页面树的数据模型。

这里模拟“从后台读取数据”——实际项目中，把 _load_data() 换成
真正的数据来源即可（数据库查询、读本地 JSON/SQLite、调用 HTTP API 等），
其余的 QAbstractItemModel 接口不需要改动。
"""

import json
import subprocess
from pathlib import Path
from PySide6.QtCore import (
    Property,
    QAbstractItemModel,
    QModelIndex,
    QTimer,
    Qt,
    QUrl,
    Signal,
    Slot,
)
from PySide6.QtGui import QGuiApplication
from platformdirs import user_data_dir, user_data_path
from uuid import uuid4
from loguru import logger


import shutil
import re
import hashlib
from loguru import logger
from pathlib import Path
from uuid import uuid4
from platformdirs import user_data_path

from json_helper import write_json
from nvim import Nvim
from path_helper import app_path


def get_file_hash(file_path):
    hash_sha256 = hashlib.sha256()

    with open(file_path, "rb") as f:
        while chunk := f.read(4096):
            hash_sha256.update(chunk)

    return hash_sha256.hexdigest()


def get_file_title(file_path):
    title = ""

    with open(file_path, encoding="utf-8") as f:
        line = f.readline()
        mathches = re.findall(r"^#\s*(.+)", line)
        if mathches:
            title = mathches[0]

    return title


class PageNode:
    """树的一个节点：可以是文件夹（有子节点）或普通页面（叶子节点）。"""

    def __init__(
        self,
        id: str,
        name: str,
        path: Path,
        node_type: str = "page",
        parent: "PageNode | None" = None,
    ):
        self.id = id
        self.name = name
        self.path = path
        self.node_type = node_type  # "folder" 或 "page"
        self.parent: "PageNode | None" = parent
        self.children: list["PageNode"] = []

        path.mkdir(parents=True, exist_ok=True)
        if node_type == "page":
            self.md_file = path / "index.md"
            if not self.md_file.exists():
                self.md_file.touch()

            self.hash = get_file_hash(self.md_file)

            self.html_folder = app_path / "cache" / id
            self.html_folder.mkdir(parents=True, exist_ok=True)

            self.html_file = self.html_folder / "index.html"
            self.build_html()
            # if not self.html_file.exists():
            #     self.build_html()

    @classmethod
    def build(cls, parent: "PageNode"):
        id = str(uuid4())
        path = parent.path / "children" / id
        node = cls(id, "Untitled", path, "page", parent)
        parent.append_child(node)

        return node

    @classmethod
    def build_from_file(cls, file: Path, parent: "PageNode | None" = None):
        meta_file = file / "meta.json"
        meta_json = json.loads(meta_file.read_text(encoding="utf-8"))

        node = cls(
            meta_json["id"], meta_json["name"], file, meta_json["node_type"], parent
        )
        if parent is not None:
            parent.append_child(node)

        for c in meta_json["children"]:
            PageNode.build_from_file(file / "children" / c, node)

        return node

    def build_html(self):
        pandoc = Path.cwd() / "external" / "pandoc.exe"

        # markdown to html
        subprocess.run(
            [
                pandoc,
                "-s",
                str(self.md_file),
                "-o",
                self.html_file,
                "--mathjax",
                "--standalone",
            ],
            creationflags=subprocess.CREATE_NO_WINDOW,
        )

        self._check_and_copy_resources()

        name = get_file_title(self.md_file)
        if name != self.name:
            self.name = name

    def paste_files(self, files: list[Path]):
        for file in files:
            if not file.exists():
                continue

            target_path = self.path / file.name
            cache_path = self.html_folder / file.name

            if file.is_dir():
                shutil.copytree(file, target_path, dirs_exist_ok=True)
                shutil.copytree(file, cache_path, dirs_exist_ok=True)

            else:
                shutil.copy(file, target_path)
                shutil.copy(file, cache_path)

    def check_file(self):
        hash = get_file_hash(self.md_file)
        if hash != self.hash:
            self.hash = hash
            self.build_html()
            return True

        return False

    def _check_and_copy_resources(self):
        note_resources = [x.name for x in self.path.iterdir()]
        html_resources = [x.name for x in self.html_folder.iterdir()]
        to_move_resources = [x for x in note_resources if x not in html_resources]
        for x in to_move_resources:
            shutil.copy(self.path / x, self.html_folder / x)

    def save(self):
        for c in self.children:
            c.save()

        write_json(
            self.path / "meta.json",
            {
                "id": self.id,
                "name": self.name,
                "node_type": self.node_type,
                "children": [x.id for x in self.children],
            },
        )

    def append_child(self, child: "PageNode") -> None:
        child.parent = self
        self.children.append(child)

    def child(self, row: int) -> "PageNode":
        return self.children[row]

    def child_count(self) -> int:
        return len(self.children)

    def row(self) -> int:
        if self.parent is not None:
            return self.parent.children.index(self)
        return 0

    @property
    def url(self):
        return QUrl.fromLocalFile(self.html_file)


class PageTreeModel(QAbstractItemModel):
    """标准的层级模型，QML 里的 TreeView 直接绑定这个模型即可。"""

    current_changed = Signal()
    NodeTypeRole = Qt.ItemDataRole.UserRole + 1

    def __init__(self, path: Path, nvim: Nvim, parent=None):
        super().__init__(parent)
        self.path = path
        self._nvim = nvim
        if path.exists():
            self._root = PageNode.build_from_file(path)
        else:
            self._root = PageNode(str(uuid4()), "__root__", path, "folder")

        self._timer = QTimer(self)
        self.current: PageNode | None = None

        self._timer.timeout.connect(self._check_file)
        self._timer.start(300)

    @Property(QUrl, notify=current_changed)
    def current_url(self):
        if self.current:
            return self.current.url

        else:
            return QUrl()

    @Slot()
    def paste_files(self):
        if not self.current:
            return

        clipboard = QGuiApplication.clipboard()
        mime_data = clipboard.mimeData()

        if not mime_data.hasUrls():
            logger.info("剪贴板里没有文件")
            return

        self.current.paste_files([Path(url.toLocalFile()) for url in mime_data.urls()])
        self.current_changed.emit()

    def _check_file(self):
        if self.current is not None:
            if self.current.check_file():
                self.current_changed.emit()
                index = self.index_for_node(self.current)
                self.dataChanged.emit(index, index, [Qt.ItemDataRole.DisplayRole])


    def save(self):
        self._root.save()
        self._nvim.close()

    # ------------------------------------------------------------------
    # 数据来源：换成真正的后台读取逻辑
    # ------------------------------------------------------------------

    def index_for_node(self, node: PageNode) -> QModelIndex:
        if node is self._root or node.parent is None:
            return QModelIndex()
        return self.createIndex(node.row(), 0, node)

    @Slot(QModelIndex)
    def set_current(self, index: QModelIndex):
        node = index.internalPointer() if index.isValid() else None
        if node is self.current:
            return
        self.current = node
        if node is not None:
            self._nvim.switch(node.md_file)

        self.current_changed.emit()

    @Slot()
    def add_page(self):
        parent_index = self.index_for_node(self._root)
        row = self._root.child_count()

        self.beginInsertRows(parent_index, row, row)
        PageNode.build(self._root)
        self.endInsertRows()

    # ------------------------------------------------------------------
    # QAbstractItemModel 标准接口
    # ------------------------------------------------------------------
    def index(self, row: int, column: int, /, parent=...):
        if not self.hasIndex(row, column, parent):
            return QModelIndex()
        parent_node = parent.internalPointer() if parent.isValid() else self._root
        child_node = parent_node.child(row)
        return self.createIndex(row, column, child_node)

    def parent(self, index):
        if not index.isValid():
            return QModelIndex()
        child_node: PageNode = index.internalPointer()
        parent_node = child_node.parent
        if parent_node is None or parent_node is self._root:
            return QModelIndex()
        return self.createIndex(parent_node.row(), 0, parent_node)

    def rowCount(self, parent=QModelIndex()):
        if parent.column() > 0:
            return 0
        parent_node = parent.internalPointer() if parent.isValid() else self._root
        return parent_node.child_count()

    def columnCount(self, parent=QModelIndex()):
        return 1

    def data(self, index, role=Qt.ItemDataRole.DisplayRole):
        if not index.isValid():
            return None
        node: PageNode = index.internalPointer()
        if role == Qt.ItemDataRole.DisplayRole:
            return node.name

        if role == self.NodeTypeRole:
            return node.node_type

        return None

    def roleNames(self):
        return {
            Qt.ItemDataRole.DisplayRole: b"display",
            self.NodeTypeRole: b"nodeType",
        }

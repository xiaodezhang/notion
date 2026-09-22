import subprocess
import shutil
import json

file_name = 'appconfig.json'
with open(file_name) as file:
    config = json.load(file)
    app_name = config["name"]
    icon = config["icon"]

with open("version.txt") as file:
    version = file.read()
    subprocess.run(
        [
            "nuitka.cmd",
            "src/main.py",
            f"--windows-product-name={app_name}",
            "--windows-company-name=CNSCAN",
            "--standalone",
            "--plugin-enable=pyside6",
            "--nofollow-import-to=QtMultimedia",
            "--nofollow-import-to=QtWebEngine",
            "--windows-console-mode=disable",
            "--include-package=qt_material",
            f"--windows-icon-from-ico=./image/{icon}",
            "--include-module=scipy._external.array_api_compat.numpy.fft",
            "--include-module=h5py._npystrings",
            "--include-module=h5py._proxy",
            "--include-module=h5py._conv",
            "--include-data-dir=./image=image",
            "--include-data-dir=./style=style",
            "--include-data-dir=./translations=translations",
            "--include-data-dir=./net=net",
            "--include-data-file=./version.txt=version.txt",
            "--include-data-file=./dark_theme.xml=dark_theme.xml",
            "--include-data-file=./light_theme.xml=light_theme.xml",
            f"--include-data-file=./{file_name}={file_name}",
            f"--output-filename={app_name}",
            "--output-dir=./dist",
            f"--windows-file-version={version}",
        ]
    )


src = "driver"  # 源目录
dst = "dist/main.dist/driver"  # 目标目录

shutil.copytree(src, dst, dirs_exist_ok=True)
shutil.copy("driver/amd64/ftd2xx64.dll", "dist/main.dist/ftd2xx.dll")

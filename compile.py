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
            "app/main.py",
            f"--windows-product-name={app_name}",
            "--windows-company-name=Duduhome",
            "--standalone",
            "--plugin-enable=pyside6",
            "--nofollow-import-to=QtMultimedia",
            "--windows-console-mode=disable",
            f"--windows-icon-from-ico=./app/icons/{icon}",
            "--include-data-file=./version.txt=version.txt",
            f"--include-data-file=./{file_name}={file_name}",
            f"--output-filename={app_name}",
            "--output-dir=./dist",
            f"--windows-file-version={version}",
        ]
    )

shutil.copytree("external", "dist/main.dist/external", dirs_exist_ok=True)

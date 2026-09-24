import json
import os
from pathlib import Path
from PySide6.QtCore import QThread, Signal
import paramiko

PORT = 22
USER = "root"


def sftp_mkdir_p(sftp, remote_path):
    """递归创建远程目录(已存在则跳过)"""
    parts = remote_path.strip("/").split("/")
    cur = ""
    for p in parts:
        cur += "/" + p
        try:
            sftp.stat(cur)
        except FileNotFoundError:
            sftp.mkdir(cur)


def upload_dir(sftp, local_dir, remote_dir):
    sftp_mkdir_p(sftp, remote_dir)
    sftp.chmod(remote_dir, 0o755)
    for name in os.listdir(local_dir):
        local_path = os.path.join(local_dir, name)
        remote_path = remote_dir + "/" + name
        if os.path.isdir(local_path):
            upload_dir(sftp, local_path, remote_path)
        else:
            sftp.put(local_path, remote_path)
            sftp.chmod(remote_path, 0o644)
            print("uploaded:", remote_path)

class Uploader(QThread):
    done = Signal()

    def __init__(self, path, host, pasword, parent=None):
        super().__init__(parent)
        self._path, self._host, self._password = path, host, pasword

    def run(self):
        remote_dir = "/var/www/html/" + self._path.stem
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(self._host, PORT, USER, self._password)
        # 用密钥登录:ssh.connect(HOST, PORT, USER, key_filename="/path/to/id_rsa")

        sftp = ssh.open_sftp()
        upload_dir(sftp, self._path, remote_dir)
        sftp.close()

        # 修改属主(SFTP 的 chown 需要 uid,直接执行命令更简单)
        stdin, stdout, stderr = ssh.exec_command(f"chown -R www-data:www-data {remote_dir}")
        print(stderr.read().decode() or "chown done")

        ssh.close()

        self.done.emit()
        print("done")

#!/bin/bash

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
   echo "此脚本需要以root权限运行，请使用sudo或者切换到root用户运行"
   exit 1
fi

# 获取最新版本号
latest_version=$(curl -s https://api.github.com/repos/filebrowser/filebrowser/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

# 设置安装路径
install_dir="/usr/local/bin"

# 下载文件
echo "正在下载 File Browser ${latest_version}..."
curl -fsSL -o /tmp/filebrowser.tar.gz "https://github.com/filebrowser/filebrowser/releases/download/${latest_version}/linux-amd64-filebrowser.tar.gz"

# 解压文件
echo "正在解压文件..."
tar -C /tmp -xzf /tmp/filebrowser.tar.gz

# 移动可执行文件到安装目录
mv /tmp/filebrowser /tmp/filebrowser.json "$install_dir"

# 创建系统服务
cat > /etc/systemd/system/filebrowser.service <<EOF
[Unit]
Description=File Browser
After=network.target

[Service]
Type=simple
ExecStart=${install_dir}/filebrowser -c ${install_dir}/filebrowser.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 启动 File Browser 服务
systemctl daemon-reload
systemctl enable filebrowser
systemctl start filebrowser

echo "File Browser 安装完成！"
echo "您可以通过浏览器访问 http://your-server-ip:8080 来开始使用。"

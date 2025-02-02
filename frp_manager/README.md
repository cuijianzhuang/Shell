# FRP 服务器管理脚本

这是一个用于管理 FRP (Fast Reverse Proxy) 服务器的 Shell 脚本，提供了完整的安装、配置、管理和更新功能。

## 功能特性

- ✨ 自动安装最新版本 FRP
- 🔧 自动配置服务和基本设置
- 🚀 服务管理（启动/停止/重启）
- 📊 状态监控
- 🔄 自动更新
- 🔌 开机自启动管理
- 🗑️ 完全卸载功能

## 系统要求

- Linux 操作系统
- systemd
- root 权限
- curl
- wget

支持的架构：
- x86_64 (amd64)
- aarch64 (arm64)

## 安装使用

1. 下载脚本：
```bash
   wget https://raw.githubusercontent.com/your-username/frp-manager/main/frp_manager.sh
```
2. 添加执行权限：
```bash
   chmod +x frp_manager.sh
```

3. 运行脚本：

```bash
sudo ./frp_manager.sh
```

## 功能菜单

1. 安装 FRP
2. 配置 FRP
3. 启动 FRP
4. 停止 FRP
5. 重启 FRP
6. 查看状态
7. 删除 FRP
8. 设置开机自启动
9. 关闭开机自启动
10. 检查更新
11. 更新 FRP

## 配置说明

默认配置文件位置：`/usr/local/frp/frps.ini`

默认配置内容：

```ini
[common]
bind_port = 7000
dashboard_port = 7500
dashboard_user = admin
dashboard_pwd = admin
token = 12345678
```
建议在正式使用前修改默认配置，特别是：
- dashboard_user
- dashboard_pwd
- token

## 目录结构

- 安装目录：`/usr/local/frp`
- 服务文件：`/etc/systemd/system/frps.service`
- 配置文件：`/usr/local/frp/frps.ini`

## 更新记录

- 支持自动检查和安装更新
- 更新时自动备份配置文件
- 保留原有配置

## 注意事项

1. 首次使用请确保以 root 权限运行
2. 更新前建议备份重要数据
3. 修改配置后需要重启服务生效
4. 请及时修改默认密码和 token

## 故障排除

1. 如果服务无法启动，请检查：
   - 配置文件语法是否正确
   - 端口是否被占用
   - 系统防火墙设置

2. 如果更新失败，请：
   - 检查网络连接
   - 确认 GitHub API 访问是否正常
   - 尝试手动下载更新

## 卸载

使用脚本中的删除功能（选项 7）可以完全删除 FRP，包括：
- 停止并禁用服务
- 删除服务文件
- 删除安装目录

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 致谢

- [FRP 项目](https://github.com/fatedier/frp)



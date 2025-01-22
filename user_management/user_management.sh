#!/bin/bash

# 检查是否以root权限运行
if [ $(id -u) -ne 0 ]; then
    echo "请以root权限运行此脚本"
    exit 1
fi

# 显示菜单
show_menu() {
    clear
    echo "=== Linux用户管理系统 ==="
    echo "1. 添加新用户"
    echo "2. 删除用户"
    echo "3. 修改用户密码"
    echo "4. 查看所有用户"
    echo "5. 添加用户到组"
    echo "6. 锁定用户账户"
    echo "7. 解锁用户账户"
    echo "0. 退出"
    echo "======================="
}

# 添加新用户
add_user() {
    read -p "请输入要添加的用户名: " username
    if id "$username" &>/dev/null; then
        echo "用户 $username 已存在！"
    else
        useradd -m "$username"
        passwd "$username"
        echo "用户 $username 创建成功！"
    fi
}

# 删除用户
delete_user() {
    read -p "请输入要删除的用户名: " username
    read -p "是否同时删除用户主目录？(y/n): " del_home
    if [ "$del_home" = "y" ]; then
        userdel -r "$username"
    else
        userdel "$username"
    fi
    echo "用户 $username 已被删除"
}

# 修改用户密码
change_password() {
    read -p "请输入用户名: " username
    passwd "$username"
}

# 查看所有用户
list_users() {
    echo "系统中的所有用户："
    cat /etc/passwd | cut -d: -f1
    read -p "按回车键继续..."
}

# 添加用户到组
add_user_to_group() {
    read -p "请输入用户名: " username
    read -p "请输入组名: " groupname
    usermod -aG "$groupname" "$username"
    echo "已将用户 $username 添加到组 $groupname"
}

# 锁定用户账户
lock_user() {
    read -p "请输入要锁定的用户名: " username
    usermod -L "$username"
    echo "用户 $username 已被锁定"
}

# 解锁用户账户
unlock_user() {
    read -p "请输入要解锁的用户名: " username
    usermod -U "$username"
    echo "用户 $username 已被解锁"
}

# 主循环
while true; do
    show_menu
    read -p "请选择操作 [0-7]: " choice
    case $choice in
        1) add_user ;;
        2) delete_user ;;
        3) change_password ;;
        4) list_users ;;
        5) add_user_to_group ;;
        6) lock_user ;;
        7) unlock_user ;;
        0) echo "感谢使用！"; exit 0 ;;
        *) echo "无效选择，请重试" ;;
    esac
    echo
    read -p "按回车键继续..."
done 

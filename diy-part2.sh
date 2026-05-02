#!/bin/bash
set -e

# 移除冲突的 autosamba
rm -rf package/lean/autosamba

# 拉取 DDNS-GO
[ ! -d package/ddns-go ] && git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go package/ddns-go || true

# ========== FileBrowser ==========
# 不再手动 clone，使用 feeds.conf.default 里 kenzok8/openwrt-packages 的版本
# filebrowser + luci-app-filebrowser 已包含在 kenzok8/openwrt-packages feed 中
echo ">>> filebrowser 将从 kenzok8/openwrt-packages feed 编译..."

# ========== iStore ==========
# 使用官方 feeds 方式集成，不再手动下载 ipk（链接已失效）
# feeds.conf.default 已添加 istore feed，编译时会自动处理
# 需要确保 luci-compat 依赖已安装（21.x 固件必需）
echo ">>> iStore 将从官方 feed 编译..."

# ========== 网络优化 ==========
mkdir -p files/etc
echo "net.core.somaxconn=65535" >> files/etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog=65535" >> files/etc/sysctl.conf

echo ">>> 所有自定义组件集成完毕！"
echo ">>> 注意：filebrowser 编译需要 golang + node，可能耗时较长"

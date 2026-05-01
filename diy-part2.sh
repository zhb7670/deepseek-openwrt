#!/bin/bash
set -e

# 移除冲突的 autosamba
rm -rf package/lean/autosamba

# 拉取 DDNS-GO
[ ! -d package/ddns-go ] && git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go package/ddns-go || true

# ========== FileBrowser 版（支持自动下载二进制）==========
echo ">>> 集成 luci-app-filebrowser（自动下载版）..."
rm -rf package/luci-app-filebrowser
git clone --depth=1 https://github.com/kenzok78/luci-app-filebrowser package/luci-app-filebrowser

# ========== iStore 稳定集成（离线 ipk 安装）==========
echo ">>> 集成 iStore（离线安装模式）..."
mkdir -p files/tmp/istore_ipk

# 下载必要的 ipk 包（直接放入固件，避免在线拉取失败）
wget -q -O files/tmp/istore_ipk/taskd.ipk https://github.com/linkease/taskd/releases/download/0.1.0/taskd_1.0.3-1_x86_64.ipk || \
wget -q -O files/tmp/istore_ipk/taskd.ipk https://raw.githubusercontent.com/zhb7670/deepseek-openwrt/main/bins/taskd_1.0.3-1_x86_64.ipk || \
echo "Warning: taskd ipk download failed"

wget -q -O files/tmp/istore_ipk/luci-app-store.ipk https://github.com/linkease/istore/releases/download/0.1.32-1/luci-app-store_0.1.32-1_all.ipk || \
echo "Warning: luci-app-store ipk download failed"

wget -q -O files/tmp/istore_ipk/luci-lib-taskd.ipk https://github.com/linkease/istore/releases/download/0.1.32-1/luci-lib-taskd_1.0.25_all.ipk || \
echo "Warning: luci-lib-taskd ipk download failed"

wget -q -O files/tmp/istore_ipk/luci-i18n-istore-zh-cn.ipk https://github.com/linkease/istore/releases/download/0.1.32-1/luci-i18n-istore-zh-cn_1.0.0-1_all.ipk || \
echo "Warning: zh-cn ipk download failed"

# 创建首次启动自动安装脚本
mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/99-install-istore << 'EOF'
#!/bin/sh
IPK_DIR="/tmp/istore_ipk"
if [ -d "$IPK_DIR" ]; then
    for ipk in "$IPK_DIR"/*.ipk; do
        [ -f "$ipk" ] && opkg install "$ipk"
    done
    rm -rf "$IPK_DIR"
fi
EOF
chmod +x files/etc/uci-defaults/99-install-istore

# ========== 网络优化 ==========
mkdir -p files/etc
echo "net.core.somaxconn=65535" >> files/etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog=65535" >> files/etc/sysctl.conf

echo ">>> 所有自定义组件集成完毕！"

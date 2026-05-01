#!/bin/bash
# 移除冲突的 autosamba
rm -rf package/lean/autosamba

# 拉取 DDNS-GO
if [ ! -d package/ddns-go ]; then
    git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go package/ddns-go || true
fi

# ---------- iStore 修复 ----------
rm -rf package/istore
git clone --depth=1 https://github.com/linkease/istore package/istore

# 修补 iStore 的依赖（taskd 必须安装）
if [ -f package/istore/luci-app-store/Makefile ]; then
    if ! grep -q "luci-lib-taskd" package/istore/luci-app-store/Makefile; then
        sed -i '/DEPENDS:=/ s/$/ +luci-lib-taskd/' package/istore/luci-app-store/Makefile
    fi
    if ! grep -q "libmbedtls21" package/istore/luci-app-store/Makefile; then
        sed -i '/DEPENDS:=/ s/$/ +libmbedtls21/' package/istore/luci-app-store/Makefile
    fi
fi

# 手动放 taskd 二进制（防止源里缺包）
mkdir -p package/base-files/files/usr/bin
wget -q -O package/base-files/files/usr/bin/taskd \
  https://raw.githubusercontent.com/zhb7670/deepseek-openwrt/main/bins/taskd 2>/dev/null || echo "taskd download skipped"
chmod +x package/base-files/files/usr/bin/taskd 2>/dev/null

# ---------- 预置 iStore 中文包 ipk ----------
mkdir -p package/base-files/files/tmp/ipk
wget -q -O package/base-files/files/tmp/ipk/luci-i18n-istore-zh-cn.ipk \
  https://github.com/linkease/istore/raw/master/luci-i18n-istore-zh-cn_1.0.0-1_all.ipk 2>/dev/null || echo "zh-cn ipk download skipped"
# 启动时自动安装中文包
cat >> package/base-files/files/etc/uci-defaults/99_install_istore_zh << 'EOF'
if [ -f /tmp/ipk/luci-i18n-istore-zh-cn.ipk ]; then
    opkg install /tmp/ipk/luci-i18n-istore-zh-cn.ipk
    rm -rf /tmp/ipk
fi
EOF

# ---------- filebrowser：不再手动下载，完全交给 .config 中的 CONFIG_PACKAGE_filebrowser ----------
# 高并发优化
echo "net.core.somaxconn=65535" >> package/base-files/files/etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog=65535" >> package/base-files/files/etc/sysctl.conf

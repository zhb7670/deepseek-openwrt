#!/bin/bash
# diy-part2.sh - 插件集成与依赖修正

# 克隆 DDNS‑GO
git clone https://github.com/sirpdboy/luci-app-ddns-go package/ddns-go || true

# 克隆 iStore
git clone https://github.com/linkease/istore package/istore || true

# 修复 iStore 依赖
if [ -f package/istore/luci-app-store/Makefile ]; then
    if ! grep -q "luci-lib-taskd" package/istore/luci-app-store/Makefile; then
        sed -i '/DEPENDS:=/ s/$/ +luci-lib-taskd/' package/istore/luci-app-store/Makefile
    fi
    if ! grep -q "libmbedtls21" package/istore/luci-app-store/Makefile; then
        sed -i '/DEPENDS:=/ s/$/ +libmbedtls21/' package/istore/luci-app-store/Makefile
    fi
fi

# 高并发优化
echo "net.core.somaxconn=65535" >> package/base-files/files/etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog=65535" >> package/base-files/files/etc/sysctl.conf

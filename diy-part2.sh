#!/bin/bash
# 克隆其他常用插件源码，确保最新
git clone https://github.com/sirpdboy/luci-app-ddns-go package/ddns-go
git clone https://github.com/linkease/istore package/istore

# 修复 iStore 依赖 (确宝应用商店内软件可以安装)
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
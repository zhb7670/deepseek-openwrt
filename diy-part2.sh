#!/bin/bash
# 移除冲突的 autosamba（与 luci-app-samba4 冲突）
rm -rf package/lean/autosamba

# 拉取 iStore 商店
if [ ! -d package/istore ]; then
    git clone --depth=1 https://github.com/linkease/istore package/istore || true
fi

# 拉取 DDNS-GO
if [ ! -d package/ddns-go ]; then
    git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go package/ddns-go || true
fi

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

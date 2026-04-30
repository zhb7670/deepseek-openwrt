#!/bin/bash
# 移除冲突的 autosamba（与 luci-app-samba4 冲突）
rm -rf package/lean/autosamba

# 拉取 DDNS-GO
if [ ! -d package/ddns-go ]; then
    git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go package/ddns-go || true
fi

# 拉取 iStore 并强制编译 taskd
rm -rf package/istore
git clone --depth=1 https://github.com/linkease/istore package/istore
# 关键：确保 taskd 一定被编译成二进制
if [ -f package/istore/luci-app-store/Makefile ]; then
    sed -i 's/include $(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/include $(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk\n\nPKG_USE_MIPS16:=0\nGO_PKG:=github.com\/linkease\/taskd/g' package/istore/taskd/Makefile 2>/dev/null
    # 补依赖
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

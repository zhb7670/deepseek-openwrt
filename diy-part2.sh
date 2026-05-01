#!/bin/bash
# 移除冲突的 autosamba
rm -rf package/lean/autosamba

# 拉取 DDNS-GO
[ ! -d package/ddns-go ] && git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go package/ddns-go || true

# ---------- iStore 完整修复 ----------
rm -rf package/istore
git clone --depth=1 https://github.com/linkease/istore package/istore

# 1. 修正 taskd 输出路径为 /usr/bin/taskd
if [ -f package/istore/taskd/Makefile ]; then
    sed -i 's|/usr/libexec/taskd|/usr/bin/taskd|g' package/istore/taskd/Makefile
fi

# 2. 同步修正 taskd 自带启动脚本中的路径
if [ -f package/istore/taskd/files/taskd.init ]; then
    sed -i 's|/usr/libexec/taskd|/usr/bin/taskd|g' package/istore/taskd/files/taskd.init
fi

# 3. 确保 luci-app-store 声明对 taskd 的依赖
if [ -f package/istore/luci-app-store/Makefile ]; then
    if ! grep -q "taskd" package/istore/luci-app-store/Makefile; then
        sed -i '/DEPENDS:=/ s/$/ +taskd/' package/istore/luci-app-store/Makefile
    fi
    if ! grep -q "luci-lib-taskd" package/istore/luci-app-store/Makefile; then
        sed -i '/DEPENDS:=/ s/$/ +luci-lib-taskd/' package/istore/luci-app-store/Makefile
    fi
    if ! grep -q "libmbedtls21" package/istore/luci-app-store/Makefile; then
        sed -i '/DEPENDS:=/ s/$/ +libmbedtls21/' package/istore/luci-app-store/Makefile
    fi
fi

# 4. 预备必要的目录（修复本次编译错误）
mkdir -p files/etc/uci-defaults files/etc/init.d

# 5. 预置 iStore 身份文件
echo '{"arch":"x86_64","uid":"000000000000000"}' > files/etc/.app_store.id

# 6. 网络与并发优化
echo "net.core.somaxconn=65535" >> files/etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog=65535" >> files/etc/sysctl.conf

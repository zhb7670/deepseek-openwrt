#!/bin/bash
# 移除冲突的 autosamba
rm -rf package/lean/autosamba

# 拉取 DDNS-GO
[ ! -d package/ddns-go ] && git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go package/ddns-go || true

# ---------- iStore 完整修复 ----------
# 拉取最新 istore 源码
rm -rf package/istore
git clone --depth=1 https://github.com/linkease/istore package/istore

# 核心修复：强制编译 taskd 并确保路径正确
if [ -f package/istore/taskd/Makefile ]; then
    # 修改 Makefile 使 taskd 输出到 /usr/bin/taskd
    sed -i 's|/usr/libexec/taskd|/usr/bin/taskd|g' package/istore/taskd/Makefile
fi

# 确保 luci-app-store 依赖 taskd
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

# ---------- filebrowser 修复 ----------
# 确保 filebrowser 主程序被编译（已在 .config 中勾选）
# 如果 kenzok8 源里的 filebrowser 有冲突，强制使用我们自己下载的稳定版
# 这里不做额外下载，完全信任 feeds 编译

# 网络优化
echo "net.core.somaxconn=65535" >> files/etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog=65535" >> files/etc/sysctl.conf

#!/bin/bash
# 移除冲突的 autosamba（与 luci-app-samba4 冲突）
rm -rf package/lean/autosamba

# 拉取 DDNS-GO
if [ ! -d package/ddns-go ]; then
    git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go package/ddns-go || true
fi

# 拉取 iStore 源码（但不再依赖它自己编译 taskd，我们直接放二进制）
rm -rf package/istore
git clone --depth=1 https://github.com/linkease/istore package/istore
if [ -f package/istore/luci-app-store/Makefile ]; then
    # 补依赖
    if ! grep -q "luci-lib-taskd" package/istore/luci-app-store/Makefile; then
        sed -i '/DEPENDS:=/ s/$/ +luci-lib-taskd/' package/istore/luci-app-store/Makefile
    fi
    if ! grep -q "libmbedtls21" package/istore/luci-app-store/Makefile; then
        sed -i '/DEPENDS:=/ s/$/ +libmbedtls21/' package/istore/luci-app-store/Makefile
    fi
fi

# 预置二进制文件存放目录
mkdir -p package/base-files/files/usr/bin

# ---------- 下载并放置 taskd (iStore 的核心后台) ----------
echo ">>> 下载 taskd 可执行文件 ..."
wget -O package/base-files/files/usr/bin/taskd \
  https://github.com/linkease/taskd/releases/download/v0.1.0/taskd_linux_amd64 2>/dev/null
if [ $? -ne 0 ]; then
    echo "!!! 下载 taskd 失败，尝试备用链接 ..."
    # 如果上面链接失效，可改用从 iStoreOS 的软件源里提取的临时地址（需确认可用）
    wget -O package/base-files/files/usr/bin/taskd \
      https://raw.githubusercontent.com/zhb7670/deepseek-openwrt/main/bins/taskd 2>/dev/null || echo "跳过 taskd"
fi
chmod +x package/base-files/files/usr/bin/taskd 2>/dev/null

# ---------- 下载并放置 filebrowser (文件管理器) ----------
echo ">>> 下载 filebrowser 可执行文件 ..."
wget -O package/base-files/files/usr/bin/filebrowser \
  https://github.com/filebrowser/filebrowser/releases/download/v2.32.0/linux-amd64-filebrowser 2>/dev/null
if [ $? -ne 0 ]; then
    echo "!!! 下载 filebrowser 失败，请后续手动上传。"
fi
chmod +x package/base-files/files/usr/bin/filebrowser 2>/dev/null

# 高并发优化
echo "net.core.somaxconn=65535" >> package/base-files/files/etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog=65535" >> package/base-files/files/etc/sysctl.conf

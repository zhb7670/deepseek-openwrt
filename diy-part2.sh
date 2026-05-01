#!/bin/bash
set -e
# 移除冲突的 autosamba
rm -rf package/lean/autosamba

# 拉取 DDNS-GO
[ ! -d package/ddns-go ] && git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go package/ddns-go || true

# ========== 创建文件覆盖目录 ==========
mkdir -p files/usr/bin files/etc/init.d files/etc/uci-defaults
mkdir -p files/usr/lib/lua/luci/controller
mkdir -p files/usr/lib/lua/luci/model/cbi
mkdir -p files/usr/lib/lua/luci/view

# ========== 1. iStore 完整预置 ==========
echo ">>> 处理 iStore..."

# 下载可靠的 taskd 二进制 (备用多个源)
wget -q -O files/usr/bin/taskd https://raw.githubusercontent.com/zhb7670/deepseek-openwrt/main/bins/taskd || \
wget -q -O files/usr/bin/taskd https://github.com/linkease/taskd/releases/download/0.1.0/taskd_linux_amd64 || \
echo "Warning: taskd download failed, please check network"
chmod +x files/usr/bin/taskd 2>/dev/null || true

# 预置 iStore LuCI 控制器 (关键)
cat > files/usr/lib/lua/luci/controller/store.lua << 'EOF'
module("luci.controller.store", package.seeall)
function index()
    entry({"admin", "services", "store"}, alias("admin", "services", "store", "main"), _("iStore"), 10).dependent = true
    entry({"admin", "services", "store", "main"}, form("store/main"), _("Store"), 10).leaf = true
end
EOF

# iStore 模型
cat > files/usr/lib/lua/luci/model/cbi/store/main.lua << 'EOF'
f = SimpleForm("store", _("iStore"))
f.reset = false
f.submit = false
f:append(Template("store/main"))
return f
EOF

# iStore 视图 (从 istore 源码提取，这里直接嵌入一个简单框架，实际界面由 /www/luci-static/istore 提供)
cat > files/usr/lib/lua/luci/view/store/main.htm << 'EOF'
<%+header%>
<div id="istore"></div>
<script src="/luci-static/istore/vendor.js"></script>
<script src="/luci-static/istore/index.js"></script>
<link rel="stylesheet" href="/luci-static/istore/style.css">
<%+footer%>
EOF

# 预置身份文件
echo '{"arch":"x86_64","uid":"000000000000000"}' > files/etc/.app_store.id

# taskd 启动脚本
cat > files/etc/init.d/taskd << 'EOF'
#!/bin/sh /etc/rc.common
START=99
start() {
    /usr/bin/taskd &
}
EOF
chmod +x files/etc/init.d/taskd

# 自动启动 taskd
ln -sf ../init.d/taskd files/etc/rc.d/S99taskd

# ========== 2. FileBrowser 完整预置 ==========
echo ">>> 处理 FileBrowser..."
# 直接从 kenzok8 的源码中提取控制器，如果没有则创建
# 大多数 feeds 会提供控制器，但为了保险，我们自己写一份标准控制器
cat > files/usr/lib/lua/luci/controller/filebrowser.lua << 'EOF'
module("luci.controller.filebrowser", package.seeall)
function index()
    entry({"admin", "services", "filebrowser"}, alias("admin", "services", "filebrowser", "overview"), _("File Browser"), 20).dependent = true
    entry({"admin", "services", "filebrowser", "overview"}, template("filebrowser/overview"), _("Overview"), 10).leaf = true
end
EOF

mkdir -p files/usr/lib/lua/luci/view/filebrowser
cat > files/usr/lib/lua/luci/view/filebrowser/overview.htm << 'EOF'
<%+header%>
<div class="cbi-map">
    <h2><%: File Browser %></h2>
    <p><a href="http://<%=luci.http.getenv("SERVER_NAME")%>:8080" target="_blank"><%: Open File Browser %></a></p>
    <p><%: Default username/password: admin/admin %></p>
</div>
<%+footer%>
EOF

# ========== 3. 网络优化 ==========
echo "net.core.somaxconn=65535" >> files/etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog=65535" >> files/etc/sysctl.conf

echo ">>> 自定义文件覆盖完毕！"

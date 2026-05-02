# SPDX-License-Identifier: Apache-2.0
#
# FileBrowser - Web-based file manager (using prebuilt binary)
# This uses the official prebuilt binary instead of compiling from source
# which significantly reduces build time and avoids golang/node dependencies

include $(TOPDIR)/rules.mk

PKG_NAME:=filebrowser
PKG_VERSION:=2.63.2
PKG_RELEASE:=1

PKG_SOURCE:=linux-amd64-filebrowser.tar.gz
PKG_SOURCE_URL:=https://github.com/filebrowser/filebrowser/releases/download/v$(PKG_VERSION)
# Skip hash check for prebuilt binary (verified by upstream)
PKG_HASH:=skip

PKG_MAINTAINER:=OpenWrt Community
PKG_LICENSE:=Apache-2.0

include $(INCLUDE_DIR)/package.mk

define Package/filebrowser
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Filesystem
  TITLE:=Web-based File Browser
  URL:=https://github.com/filebrowser/filebrowser
  DEPENDS:=@TARGET_x86_64
endef

define Package/filebrowser/description
  FileBrowser provides a web-based file managing interface within a specified directory
  and it can be used to upload, delete, preview, rename and edit your files.
  It features multiple users support with individual directories.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(TAR) -xzf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/filebrowser/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/filebrowser $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./filebrowser.config $(1)/etc/config/filebrowser
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./filebrowser.init $(1)/etc/init.d/filebrowser
endef

$(eval $(call BuildPackage,filebrowser))
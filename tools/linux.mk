
LINUX_DOWNLOAD_LINK = https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(LINUX_VERSION).tar.xz
LINUX_DOWNLOAD_SRC  = $(DOWNLOAD_DIR)/linux-$(LINUX_VERSION).tar.xz

LINUX_BUILD_DIR = $(BUILD_DIR)/linux-$(LINUX_VERSION)

LINUX_TARGET ?= all
LINUX_CFLAGS_MODULE ?= -fno-pic

ifdef LINUX_DTS_CUSTOM
LINUX_DTB     = $(subst .dts,.dtb,$(notdir $(LINUX_DTS_CUSTOM)))
else
LINUX_DTB     = $(subst .dts,.dtb,$(notdir $(LINUX_DTS)))
endif


ifdef LINUX_PATCHES_DIR
LINUX_PATCHES = $(shell find $(LINUX_PATCHES_DIR) -name '*.patch')
endif


LINUX_STAMP_EXTRACTED  = $(call STAMP_EXTRACTED,linux)
LINUX_STAMP_PATCHED    = $(call STAMP_PATCHED,linux)
LINUX_STAMP_CONFIGURED = $(call STAMP_CONFIGURED,linux)
LINUX_STAMP_BUILT      = $(call STAMP_BUILT,linux)
LINUX_STAMP_INSTALLED  = $(call STAMP_INSTALLED,linux)


linux-download:
ifeq ($(wildcard $(LINUX_DOWNLOAD_SRC)),)
	$(call banner,"Linux downloading ...")
	$(call download,$(LINUX_DOWNLOAD_LINK),$(LINUX_DOWNLOAD_SRC))
	$(call banner,"Linux downloading done")
endif

linux-extract: linux-download
ifeq ($(wildcard $(LINUX_STAMP_EXTRACTED)),)
	$(call banner,"Linux extracting ...")
	tar xf $(LINUX_DOWNLOAD_SRC) -C $(BUILD_DIR)
	touch $(LINUX_STAMP_EXTRACTED)
	$(call banner,"Linux extracting done")
endif


linux-patch: linux-extract
ifeq ($(wildcard $(LINUX_STAMP_PATCHED)),)
ifdef LINUX_PATCHES
	$(call banner,"Linux patching ...")
	$(foreach patch,$(sort $(LINUX_PATCHES)),$(DEFED_DIR)/tools/apply-patch.sh $(LINUX_BUILD_DIR) $(patch);)
	touch $(LINUX_STAMP_PATCHED)
	$(call banner,"Linux patching done")
endif
endif


linux-configure: linux-patch
ifeq ($(wildcard $(LINUX_STAMP_CONFIGURED)),)
	$(call banner,"Linux configuration ...")

ifdef LINUX_CONFIG_CUSTOM
#   apply custom configuration
	cp $(LINUX_CONFIG_CUSTOM) $(LINUX_BUILD_DIR)/.config
	cd $(LINUX_BUILD_DIR) && make ARCH=$(LINUX_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) olddefconfig
else
#   use build-in configuration
	cd $(LINUX_BUILD_DIR) && make ARCH=$(LINUX_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(LINUX_CONFIG)
endif

ifdef LINUX_DTS_CUSTOM
#   copy custom device tree file
	cp $(LINUX_DTS_CUSTOM) $(LINUX_BUILD_DIR)/arch/$(LINUX_ARCH)/boot/dts/
endif

	touch $(LINUX_STAMP_CONFIGURED)
	$(call banner,"Linux configuration done")
endif

linux: linux-configure
ifeq ($(wildcard $(LINUX_STAMP_BUILT)),)
	$(call banner,"Linux compilation ...")
	# compile kernel
	cd $(LINUX_BUILD_DIR) && make ARCH=$(LINUX_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -j$(NUMJOBS) $(LINUX_TARGET)
	# compile modules
	cd $(LINUX_BUILD_DIR) && make ARCH=$(LINUX_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -j$(NUMJOBS) CFLAGS_MODULE=$(LINUX_CFLAGS_MODULE) modules
	# compile device tree file
	cd $(LINUX_BUILD_DIR) && make ARCH=$(LINUX_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(LINUX_DTB)
	
	touch $(LINUX_STAMP_BUILT)
	$(call banner,"Linux compilation done")
endif


linux-install:
ifeq ($(wildcard $(LINUX_STAMP_INSTALLED)),)
	$(call banner,"Linux installation ...")
	$(call linux-install-hook)
	touch $(LINUX_STAMP_INSTALLED)
	$(call banner,"Linux installation done")
endif


linux-menuconfig: linux-configure
	cd $(LINUX_BUILD_DIR) && make ARCH=$(LINUX_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) menuconfig
	rm -f $(LINUX_STAMP_BUILT)
	rm -f $(LINUX_STAMP_INSTALLED)

linux-savedefconfig:
	cd $(LINUX_BUILD_DIR) && make ARCH=$(LINUX_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) savedefconfig

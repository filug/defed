

UBOOT_DOWNLOAD_LINK = ftp://ftp.denx.de/pub/u-boot/u-boot-$(UBOOT_VERSION).tar.bz2
UBOOT_DOWNLOAD_SRC  = $(DOWNLOAD_DIR)/u-boot-$(UBOOT_VERSION).tar.bz2

UBOOT_BUILD_DIR = $(BUILD_DIR)/u-boot-$(UBOOT_VERSION)


ifdef UBOOT_PATCHES_DIR
UBOOT_PATCHES = $(shell find $(UBOOT_PATCHES_DIR) -name '*.patch')
endif


UBOOT_STAMP_EXTRACTED  = $(call STAMP_EXTRACTED,uboot)
UBOOT_STAMP_PATCHED    = $(call STAMP_PATCHED,uboot)
UBOOT_STAMP_CONFIGURED = $(call STAMP_CONFIGURED,uboot)
UBOOT_STAMP_BUILT      = $(call STAMP_BUILT,uboot)
UBOOT_STAMP_INSTALLED  = $(call STAMP_INSTALLED,uboot)


uboot-download:
ifeq ($(wildcard $(UBOOT_DOWNLOAD_SRC)),)
	$(call banner,"U-Boot downloading ...")
	$(call download,$(UBOOT_DOWNLOAD_LINK),$(UBOOT_DOWNLOAD_SRC))
	$(call banner,"U-Boot downloading done")
endif

uboot-extract: uboot-download
ifeq ($(wildcard $(UBOOT_STAMP_EXTRACTED)),)
	$(call banner,"U-Boot extracting ...")
	tar xf $(UBOOT_DOWNLOAD_SRC) -C $(BUILD_DIR)
	touch $(UBOOT_STAMP_EXTRACTED)
	$(call banner,"U-Boot extracting done")
endif


uboot-patch: uboot-extract
ifeq ($(wildcard $(UBOOT_STAMP_PATCHED)),)
ifdef UBOOT_PATCHES
	$(call banner,"U-Boot patching ...")
	$(foreach patch,$(sort $(UBOOT_PATCHES)),$(DEFED_DIR)/tools/apply-patch.sh $(UBOOT_BUILD_DIR) $(patch);)
	touch $(UBOOT_STAMP_PATCHED)
	$(call banner,"U-Boot patching done")
endif
endif

uboot-configure: uboot-patch
ifeq ($(wildcard $(UBOOT_STAMP_CONFIGURED)),)
	$(call banner,"U-Boot configuration ...")

ifdef UBOOT_CONFIG_CUSTOM
#   apply custom configuration
	cp $(UBOOT_CONFIG_CUSTOM) $(UBOOT_BUILD_DIR)/.config
	cd $(UBOOT_BUILD_DIR) && make ARCH=$(UBOOT_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) olddefconfig
else
#   use build-in configuration
	cd $(UBOOT_BUILD_DIR) && make ARCH=$(UBOOT_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(UBOOT_CONFIG)
endif

	touch $(UBOOT_STAMP_CONFIGURED)
	$(call banner,"U-Boot configuration done")
endif


uboot: uboot-configure
ifeq ($(wildcard $(UBOOT_STAMP_BUILT)),)
	$(call banner,"U-Boot compilation ...")
	cd $(UBOOT_BUILD_DIR) && make ARCH=$(UBOOT_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -j$(NUMJOBS) all
	touch $(UBOOT_STAMP_BUILT)
	$(call banner,"U-Boot compilation done")
endif


uboot-install: uboot
ifeq ($(wildcard $(UBOOT_STAMP_INSTALLED)),)
	$(call banner,"U-Boot installation ...")
	$(call uboot-install-hook)
	touch $(UBOOT_STAMP_INSTALLED)
	$(call banner,"U-Boot installation done")
endif


uboot-menuconfig: uboot-configure
	cd $(UBOOT_BUILD_DIR) && make ARCH=$(UBOOT_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) menuconfig
	rm -f $(UBOOT_STAMP_BUILT)
	rm -f $(UBOOT_STAMP_INSTALLED)

uboot-savedefconfig:
	cd $(UBOOT_BUILD_DIR) && make ARCH=$(UBOOT_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) savedefconfig

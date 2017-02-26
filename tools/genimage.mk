GENIMAGE_VERSION ?= 9

GENIMAGE_DOWNLOAD_LINK = http://public.pengutronix.de/software/genimage/genimage-$(GENIMAGE_VERSION).tar.xz
GENIMAGE_DOWNLOAD_SRC  = $(DOWNLOAD_DIR)/genimage-$(GENIMAGE_VERSION).tar.xz
GENIMAGE_BUILD_DIR     = $(BUILD_DIR)/genimage-$(GENIMAGE_VERSION)

GENIMAGE_STAMP_EXTRACTED  = $(call STAMP_EXTRACTED,genimage)
GENIMAGE_STAMP_BUILT      = $(call STAMP_BUILT,genimage)
GENIMAGE_STAMP_INSTALLED  = $(call STAMP_INSTALLED,genimage)

GENIMAGE_TMP = $(BUILD_DIR)/genimage.tmp

genimage-download:
ifeq ($(wildcard $(GENIMAGE_DOWNLOAD_SRC)),)
	$(call banner,"Genimage downloading ...")
	$(call download,$(GENIMAGE_DOWNLOAD_LINK),$(GENIMAGE_DOWNLOAD_SRC))
	$(call banner,"Genimage downloading done")
endif

genimage-extract: genimage-download
ifeq ($(wildcard $(GENIMAGE_STAMP_EXTRACTED)),)
	$(call banner,"Genimage extracting ...")
	tar xf $(GENIMAGE_DOWNLOAD_SRC) -C $(BUILD_DIR)
	touch $(GENIMAGE_STAMP_EXTRACTED)
	$(call banner,"Genimage extracting done")
endif

genimage-build: genimage-extract
ifeq ($(wildcard $(GENIMAGE_STAMP_BUILT)),)
	$(call banner,"Genimage building ...")
	cd $(GENIMAGE_BUILD_DIR) && ./configure
	cd $(GENIMAGE_BUILD_DIR) && make
	touch $(GENIMAGE_STAMP_BUILT)
	$(call banner,"Genimage building done")
endif


genimage: genimage-build
	sudo rm -rf $(GENIMAGE_TMP)
	sudo $(GENIMAGE_BUILD_DIR)/genimage --config $(GENIMAGE_CFG) --tmppath $(GENIMAGE_TMP) --outputpath $(IMAGES_DIR) --inputpath $(IMAGES_DIR) --rootpath $(ROOTFS_DIR)

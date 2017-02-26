
include tools/dirs.mk

# select configuration directory
ifdef DEFED_EXTERNAL
DEFED_CONFIG_DIR ?= $(DEFED_EXTERNAL)/configs
else
DEFED_CONFIG_DIR ?= $(DEFED_DIR)/configs
endif


NUMJOBS ?= `grep processor /proc/cpuinfo | wc -l`


# apply user configuration
configure:
ifeq ($(wildcard $(PWD)/config.mk),)
	$(error error: DEFED not configured)
else
include config.mk
include tools/lib.mk
include tools/stamps.mk
include tools/debian-$(DEBIAN_RELEASE).mk
include tools/u-boot.mk
include tools/linux.mk
include tools/rootfs.mk
include tools/genimage.mk
endif


setup: configure dirs-setup

%_defconfig:
	@if [ -f $(DEFED_CONFIG_DIR)/$@ ]; then\
		echo "Using config file: $@";\
		cp $(DEFED_CONFIG_DIR)/$@ $(DEFED_DIR)/config.mk;\
	else\
		echo "Missing config file!";\
		exit 1;\
	fi

all: setup uboot-install linux debian linux-install rootfs-image genimage
	@echo DONE!

.DEFAULT_GOAL := all
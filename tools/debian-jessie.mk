
DEBIAN_STAMP_CONFIGURED = $(call STAMP_CONFIGURED,debian)
DEBIAN_STAMP_BUILT      = $(call STAMP_BUILT,debian)
DEBIAN_STAMP_POSTBUILT  = $(call STAMP_POSTBUILT,debian)
DEBIAN_STAMP_CLEANED    = $(call STAMP_CLEANED,debian)


DEBIAN_BUILD_DIR = $(BUILD_DIR)/debian

DEBIAN_ENVS ?= DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C

QEMU_BIN = $(notdir $(QEMU_EMULATOR))


debian-setup:
	@mkdir -p $(DEBIAN_BUILD_DIR)

debian-configure: debian-setup
ifeq ($(wildcard $(DEBIAN_STAMP_CONFIGURED)),)
	$(call banner,Configuring Debian ...)
	cp $(MULTISTRAP_CONF) $(DEBIAN_BUILD_DIR)/multistrap.conf
	sed -i -- 's\directory=.*\directory=$(ROOTFS_DIR)\g' $(DEBIAN_BUILD_DIR)/multistrap.conf
	sed -i -- 's\source=.*\source=$(DEBIAN_SOURCE)\g'    $(DEBIAN_BUILD_DIR)/multistrap.conf
	touch $(DEBIAN_STAMP_CONFIGURED)
	$(call banner,Configuring Debian done)
endif

debian-build: debian-configure
ifeq ($(wildcard $(DEBIAN_STAMP_BUILT)),)
	$(call banner,Bulding Debian ...)
	sudo multistrap -a $(DEBIAN_ARCH) -f $(DEBIAN_BUILD_DIR)/multistrap.conf
	# allow to use QEMU
	sudo cp $(QEMU_EMULATOR) $(ROOTFS_DIR)/usr/bin/$(QEMU_BIN)
	# prepare to start
	sudo mount -o bind /dev $(ROOTFS_DIR)/dev/
	sudo mount -o bind /sys $(ROOTFS_DIR)/sys/
	sudo mount -o bind /proc $(ROOTFS_DIR)/proc/
	# finalize installation
	sudo $(DEBIAN_ENVS) chroot $(ROOTFS_DIR) /var/lib/dpkg/info/dash.preinst install
	sudo $(DEBIAN_ENVS) chroot $(ROOTFS_DIR) dpkg --configure -a
	# done
	touch $(DEBIAN_STAMP_BUILT)
	$(call banner,Bulding Debian done)
endif

debian-postbuild:
ifeq ($(wildcard $(DEBIAN_STAMP_POSTBUILT)),)
ifdef DEBIAN_POSTBUILD_SCRIPT
	$(call banner,Post-bulding Debian ...)
	
	DEBIAN_ENVS="$(DEBIAN_ENVS)" ROOTFS_DIR=$(ROOTFS_DIR) DEFED_DIR=$(DEFED_DIR) BOARD_DIR=$(BOARD_DIR) $(DEBIAN_POSTBUILD_SCRIPT)
	
	touch $(DEBIAN_STAMP_POSTBUILT)
	$(call banner,Post-bulding Debian done)
endif
endif

debian-cleanup:
ifeq ($(wildcard $(DEBIAN_STAMP_CLEANED)),)
	$(call banner,Cleaning up Debian ...)

	sudo umount $(ROOTFS_DIR)/proc/
	sudo umount $(ROOTFS_DIR)/sys/
	sudo umount $(ROOTFS_DIR)/dev/
	sudo rm $(ROOTFS_DIR)/usr/bin/$(QEMU_BIN)

	touch $(DEBIAN_STAMP_CLEANED)
	$(call banner,Cleaning up Debian done)
endif

debian: debian-build debian-postbuild debian-cleanup

rootfs-image:
ifneq (,$(findstring ext2,$(ROOTFS_IMAGE_FILE)))
	sudo tools/mke2img -G 2 -R 1 -d $(ROOTFS_DIR) -o $(IMAGES_DIR)/$(ROOTFS_IMAGE_FILE)
endif
ifneq (,$(findstring ext3,$(ROOTFS_IMAGE_FILE)))
	sudo tools/mke2img -G 3 -R 1 -d $(ROOTFS_DIR) -o $(IMAGES_DIR)/$(ROOTFS_IMAGE_FILE)
endif
ifneq (,$(findstring ext4,$(ROOTFS_IMAGE_FILE)))
	sudo tools/mke2img -G 4 -R 1 -d $(ROOTFS_DIR) -o $(IMAGES_DIR)/$(ROOTFS_IMAGE_FILE)
endif

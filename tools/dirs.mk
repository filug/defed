# Main directory
DEFED_DIR = $(PWD)

OUTPUT_DIR = $(DEFED_DIR)/output
IMAGES_DIR = $(OUTPUT_DIR)/images
BUILD_DIR  = $(OUTPUT_DIR)/build

ROOTFS_DIR = $(OUTPUT_DIR)/rootfs

STAMPS_DIR = $(OUTPUT_DIR)/stamps


DOWNLOAD_DIR = $(DEFED_DIR)/dl


dirs-setup:
	@mkdir -p $(OUTPUT_DIR)
	@mkdir -p $(IMAGES_DIR)
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(ROOTFS_DIR)
	@mkdir -p $(STAMPS_DIR)
	@mkdir -p $(DOWNLOAD_DIR)
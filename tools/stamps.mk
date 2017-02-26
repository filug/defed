# list of generic stamps to indicate finalized step

define STAMP
$(STAMPS_DIR)/stamp_
endef

define STAMP_DOWNLOADED
$(call STAMP,)$(1)_downloaded
endef

define STAMP_EXTRACTED
$(call STAMP,)$(1)_extracted
endef

define STAMP_PATCHED
$(call STAMP,)$(1)_patched
endef

define STAMP_CONFIGURED
$(call STAMP,)$(1)_configured
endef

define STAMP_BUILT
$(call STAMP,)$(1)_built
endef

define STAMP_POSTBUILT
$(call STAMP,)$(1)_postbuilt
endef

define STAMP_INSTALLED
$(call STAMP,)$(1)_installed
endef

define STAMP_CLEANED
$(call STAMP,)$(1)_cleaned
endef

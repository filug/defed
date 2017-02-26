


define banner
	@echo "#############################################"
	@echo "# $(1)"
	@echo "#############################################"
endef

define download
	@echo "Downloading $(1)"
	wget -q --show-progress $(1) -O $(2)
endef
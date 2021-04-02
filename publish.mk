
.PHONY: packer-build install_packer \
   clean print_img_path print_box_name

SHELL=bash

include ./vars.mk

print_box_desc:
	@printf '%s' $(DESCRIPTION)



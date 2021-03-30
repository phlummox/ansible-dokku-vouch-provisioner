
# version being built

BOX_VERSION=0.0.1

# packer config file to use
PACKER_FILE=dokku.pkr.hcl

# input box to use
BASE_BOX_NAME=ubuntu2004
BASE_BOX=generic/$(BASE_BOX_NAME)
BASE_BOX_VERSION=3.2.6
UBUNTU_IMG_PATH=$(HOME)/.vagrant.d/boxes/generic-VAGRANTSLASH-$(BASE_BOX_NAME)/$(BASE_BOX_VERSION)/libvirt/box.img

# name for our built box
BOX_NAME=ubuntu-dokku

SHORT_DESCRIPTION=Dokku installed on Ubuntu 20.04

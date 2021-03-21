
.PHONY: packer_build install_packer

PACKER_VERSION=1.7.0
PACKER_URL=https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip

# installs packer if it's not on path.
# Assumes you have ~/.local/bin, and
# that that's a sensible place to put things

install_packer:
	@if (which packer) ; then \
	  echo "packer already installed"; \
	else \
	  dir=`mktemp -d tmp-downloaded-packer-exe-XXXXX`; \
	  set -ex; \
	  (cd $$dir && curl -O -L $(PACKER_URL) ); \
	  unzip -d ~/.local/bin $$dir/packer*zip packer ; \
	  : "done"; \
	fi

VAGRANT_VERSION=2.2.14

install_vagrant:
	@if (dpkg -s vagrant | grep 'Status.*installed') ; then \
	  echo "vagrant already installed"; \
	else \
	  set -ex; \
	  dir=`mktemp -d tmp-downloaded-vagrant-deb-XXXXX`; \
	  curl -L https://releases.hashicorp.com/vagrant/$(VAGRANT_VERSION)/vagrant_$(VAGRANT_VERSION)_x86_64.deb > $$dir/vagrant.deb; \
	  sudo apt install $$PWD/$$dir/vagrant.deb; \
	fi



PACKER_FILE=dokku.pkr.hcl

BASE_BOX=generic/ubuntu2004
BASE_BOX_VERSION=3.2.6
UBUNTU_IMG_PATH=$(HOME)/.vagrant.d/boxes/generic-VAGRANTSLASH-ubuntu2004/$(BASE_BOX_VERSION)/libvirt/box.img

# our versioning
BOX_VERSION=0.1

print_img_path:
	echo $(UBUNTU_IMG_PATH)

$(UBUNTU_IMG_PATH):
	$(MAKE) install_vagrant
	vagrant box add \
	  --provider libvirt \
	  --box-version $(BASE_BOX_VERSION) \
	  $(BASE_BOX)

# to work out the disk size:
# we need to run `qemu-img info /path/to/box.img`,
# and look for a line in the output that says:
#     virtual size: 128G (137438953472 bytes)
# or similar.

#	export DISK_SIZE=`qemu-img info $(UBUNTU_IMG_PATH) | grep '^virtual size' | sed 's/(//g' | awk '{ print $4; }'`; \

.ubuntu_checksum.md5: $(UBUNTU_IMG_PATH)
	cat $(UBUNTU_IMG_PATH) | pv | md5sum | awk '{ print $$1; }' > $@


packer_build: install_packer \
	                install_vagrant \
	                $(UBUNTU_IMG_PATH) \
	                .ubuntu_checksum.md5
	@if [ ! -f $(UBUNTU_IMG_PATH) ]; then \
	  printf 'no box.img found at %s!\n' $(UBUNTU_IMG_PATH); \
	  exit 1; \
	fi
	set -ex; \
	export PKR_VAR_UBUNTU_IMG_PATH=$(UBUNTU_IMG_PATH); \
	export PKR_VAR_DISK_SIZE=`qemu-img info $(UBUNTU_IMG_PATH) | grep '^virtual size' | sed 's/(//g' | awk '{ print $$4; }'`; \
	export PKR_VAR_DISK_CHECKSUM=`cat .ubuntu_checksum.md5`; \
	export PKR_VAR_BOX_VERSION=$(BOX_VERSION); \
	packer validate $(PACKER_FILE); \
	PACKER_LOG=1 packer build $(PACKER_FILE)


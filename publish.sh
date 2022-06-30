#!/usr/bin/env bash

# script to publish box to vagrant cloud.
# shamelessly copied ^H^H^H adapted from
# https://github.com/sdorsett/packer-centos7-esxi/blob/cb61c913911fafb35432eca4bd7cb532087ffa24/build-scripts/generic-packer-build-script.sh

# expects VAGRANT_CLOUD_TOKEN
# env var to be set in calling environmnent.

set -e
set -x

cd packer-boxmaker-config

# if set (e.g. cos running in github CI),
# take box version from ${release_name}
if [ -n "$release_name" ] ; then
  BOX_VERSION="${release_name}";
else
  BOX_VERSION="$(make print_box_version)";
fi

set -uo pipefail

AUTHOR="$(grep '"Author":' templates/info.json | awk '{ print $2; }' | sed ' s/"//g; s/,//g; ')"
BOX_NAME="$(make print_box_name)"
PROVIDER_TYPE="libvirt"

SHORT_DESC="$(make print_short_desc)"


PATH_TO_BUILT_BOX="$(find output/ -name '*.box')"

echo "ensuring vagrant-cloud box exists named ${AUTHOR}/$BOX_NAME has been created"
curl https://vagrantcloud.com/api/v1/boxes \
        -X POST \
        -d "access_token=$VAGRANT_CLOUD_TOKEN" \
        -d "box[username]=$AUTHOR" \
        -d "box[name]=$BOX_NAME" \
        -d "box[is_private]=false" \
        -d "box[short_description]=$SHORT_DESC" \
        --data-binary "$(make print_desc)"

echo "ensuring vagrant-cloud box named $AUTHOR/$BOX_NAME has version $BOX_VERSION created"
curl "https://vagrantcloud.com/api/v1/box/$AUTHOR/$BOX_NAME/versions" \
        -X POST \
        -d "version[version]=$BOX_VERSION" \
        --data-binary "version[description]=Version $BOX_VERSION. $(make print_desc) See <https://github.com/phlummox/ansible-dokku-vouch-provisioner/releases/tag/v$BOX_VERSION>" \
        -d access_token="$VAGRANT_CLOUD_TOKEN"

echo "ensuring vagrant-cloud box named $AUTHOR/$BOX_NAME has ${PROVIDER_TYPE} provider created"
curl "https://vagrantcloud.com/api/v1/box/$AUTHOR/$BOX_NAME/version/$BOX_VERSION/providers" \
-X POST \
-d provider[name]="${PROVIDER_TYPE}" \
-d access_token="$VAGRANT_CLOUD_TOKEN"

echo "uploading $AUTHOR/$BOX_NAME vmware_desktop packer .box file"
VAGRANT_CLOUD_PATH=$(curl -L "https://vagrantcloud.com/api/v1/box/$AUTHOR/$BOX_NAME/version/$BOX_VERSION/provider/${PROVIDER_TYPE}/upload?access_token=$VAGRANT_CLOUD_TOKEN" |cut -d "," -f1 | cut -d'"' -f4)
echo "$VAGRANT_CLOUD_PATH"

curl \
  --progress-bar \
  --verbose \
  -X PUT --upload-file "$PATH_TO_BUILT_BOX" "$VAGRANT_CLOUD_PATH" > res || true

cat -n res

echo "releasing version $BOX_VERSION of $AUTHOR/$BOX_NAME $PROVIDER_TYPE"
curl \
  --progress-bar \
  --verbose \
  "https://vagrantcloud.com/api/v1/box/$AUTHOR/$BOX_NAME/version/$BOX_VERSION/release" -X PUT -d access_token="$VAGRANT_CLOUD_TOKEN" > release_result

cat -n release_result


#!/bin/bash

set -ex

BASE_IMAGE=`cat /app/conf/base-image.txt`

echo "BASE_IMAGE=[$BASE_IMAGE]"
IMAGE_FULL_NAME=$(echo $BASE_IMAGE | cut -d ":" -f 2)
echo "IMAGE_FULL_NAME=[$IMAGE_FULL_NAME]"

DEBIAN_VERSION=$(echo $IMAGE_FULL_NAME | cut -d "-" -f 1)
echo "DEBIAN_VERSION=[$DEBIAN_VERSION]"

declare -A repo_url_dict
declare -A repo_list_dict

GPG_KEY_FILE="/usr/share/keyrings/lesbonscomptes.gpg"

if [ ! -f "${GPG_KEY_FILE}" ]; then
    wget https://www.lesbonscomptes.com/pages/lesbonscomptes.gpg -O "${GPG_KEY_FILE}"
fi

REPO_X86_64="https://www.lesbonscomptes.com/upmpdcli/pages/upmpdcli-$DEBIAN_VERSION.list"
REPO_ARM="https://www.lesbonscomptes.com/upmpdcli/pages/upmpdcli-r$DEBIAN_VERSION.list"

repo_url_dict[x86_64]=$REPO_X86_64
repo_url_dict[armv7l]=$REPO_ARM
repo_url_dict[aarch64]=$REPO_ARM

repo_list_dict[x86_64]=upmpdcli-$DEBIAN_VERSION.list
repo_list_dict[armv7l]=upmpdcli-r$DEBIAN_VERSION.list
repo_list_dict[aarch64]=upmpdcli-r$DEBIAN_VERSION.list

ARCH=`uname -m`
REPO_URL=${repo_url_dict["${ARCH}"]};
REPO_LIST=${repo_list_dict["${ARCH}"]};

REPO_FILE="/etc/apt/sources.list.d/${REPO_LIST}"

if [ ! -f "${REPO_FILE}" ]; then
    wget $REPO_URL -O "/etc/apt/sources.list.d/${REPO_LIST}"
fi

cat /etc/apt/sources.list.d/upmpdcli-$DEBIAN_VERSION.list

apt-get update

apt-get install -y upplay

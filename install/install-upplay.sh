#/bin/bash

declare -A repo_url_dict

REPO_X86_64="https://www.lesbonscomptes.com/upmpdcli/pages/upmpdcli-bullseye.list"
REPO_ARM="https://www.lesbonscomptes.com/upmpdcli/pages/upmpdcli-rbullseye.list"

repo_url_dict[x86_64]=$REPO_X86_64
repo_url_dict[armv7l]=$REPO_ARM
repo_url_dict[aarch64]=$REPO_ARM

ARCH=`uname -m`
REPO_URL=${repo_url_dict["${ARCH}"]};

wget $REPO_URL -O /etc/apt/sources.list.d/upmpdcli-bullseye.list

apt-get update

apt-get install -y upplay
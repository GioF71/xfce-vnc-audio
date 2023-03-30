#!/bin/bash

# error codes
# 2 Invalid base image
# 3 Invalid proxy parameter

declare -A base_image_tags

base_image_tags[jammy]=ubuntu:jammy

declare -A local_tag
local_tag[bullseye]=local-jammy

DEFAULT_BASE_IMAGE=jammy
DEFAULT_TAG=local
DEFAULT_USE_PROXY=N

tag=""
git_branch="$DEFAULT_GIT_VERSION"

while getopts b:t:p: flag
do
    case "${flag}" in
        b) base_image_tag=${OPTARG};;
        t) tag=${OPTARG};;
        p) proxy=${OPTARG};;
    esac
done

echo "base_image_tag: $base_image_tag";
echo "tag: $tag";
echo "proxy: [$proxy]";

if [ -z "${base_image_tag}" ]; then
  base_image_tag=$DEFAULT_BASE_IMAGE
fi

selected_image_tag=${base_image_tags[$base_image_tag]}
if [ -z "${selected_image_tag}" ]; then
  echo "invalid base image ["${base_image_tag}"]"
  exit 2
fi

select_tag=${local_tag[$base_image_tag]}
if [[ -n "$select_tag" ]]; then
  tag=$select_tag
else
  tag=$DEFAULT_TAG
fi

if [ -z "${proxy}" ]; then
  proxy="N"
fi
if [[ "${proxy}" == "Y" || "${proxy}" == "y" ]]; then  
  proxy="Y"
elif [[ "${proxy}" == "N" || "${proxy}" == "n" ]]; then  
  proxy="N"
else
  echo "invalid proxy parameter ["${proxy}"]"
  exit 3
fi

echo "Base Image Tag: [$selected_image_tag]"
echo "Build Tag: [$tag]"
echo "Proxy: [$proxy]"

docker build . \
    --build-arg BASE_IMAGE=${selected_image_tag} \
    --build-arg USE_APT_PROXY=${proxy} \
    -t giof71/xfce-vnc-audio:$tag

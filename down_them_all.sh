#!/bin/bash

mkdir -p dist
cd dist

version=$1
version_post=$2

if [[ "$1" == "" ]]; then
    echo "Usage: down_them_all.sh <version>"
    exit 1
fi


declare -a wheel_abis=(
	"cp39-cp39"
	"cp310-cp310"
	"cp311-abi3"
	"cp313-cp313t"
	"cp314-cp314t")

declare -a wheel_platforms=(
	"macosx_10_13_x86_64"
	"macosx_11_0_arm64"
	"manylinux_2_17_x86_64.manylinux2014_x86_64"
	"manylinux_2_17_aarch64.manylinux2014_aarch64"
	"manylinux_2_17_ppc64le.manylinux2014_ppc64le"
	"win_amd64")

for abi in "${wheel_abis[@]}"
do
  for platform in "${wheel_platforms[@]}"
  do
    curl -L -O https://github.com/symengine/symengine-wheels/releases/download/v${version}${version_post}/symengine-${version}-${abi}-${platform}.whl;
  done
done

curl -L -O https://github.com/symengine/symengine-wheels/releases/download/v${version}${version_post}/symengine-${version}.tar.gz;

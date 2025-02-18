#!/bin/bash

mkdir -p dist
cd dist

version=$1
version_post=$2

if [[ "$1" == "" ]]; then
    echo "Usage: down_them_all.sh <version>"
    exit 1
fi

declare -a arr=(
	"-cp39-cp39-macosx_10_13_x86_64.whl"
	"-cp310-cp310-macosx_10_13_x86_64.whl"
	"-cp311-cp311-macosx_10_13_x86_64.whl"
	"-cp312-cp312-macosx_10_13_x86_64.whl"
	"-cp313-cp313-macosx_10_13_x86_64.whl"
	"-cp313-cp313t-macosx_10_13_x86_64.whl"
	"-cp39-cp39-macosx_11_0_arm64.whl"
	"-cp310-cp310-macosx_11_0_arm64.whl"
	"-cp311-cp311-macosx_11_0_arm64.whl"
	"-cp312-cp312-macosx_11_0_arm64.whl"
	"-cp313-cp313-macosx_11_0_arm64.whl"
	"-cp313-cp313t-macosx_11_0_arm64.whl"
	"-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
	"-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
	"-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
	"-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
	"-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
	"-cp313-cp313t-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
	"-cp39-cp39-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
	"-cp310-cp310-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
	"-cp311-cp311-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
	"-cp312-cp312-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
	"-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
	"-cp313-cp313t-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
	"-cp39-cp39-manylinux_2_17_ppc64le.manylinux2014_ppc64le.whl"
	"-cp310-cp310-manylinux_2_17_ppc64le.manylinux2014_ppc64le.whl"
	"-cp311-cp311-manylinux_2_17_ppc64le.manylinux2014_ppc64le.whl"
	"-cp312-cp312-manylinux_2_17_ppc64le.manylinux2014_ppc64le.whl"
	"-cp313-cp313-manylinux_2_17_ppc64le.manylinux2014_ppc64le.whl"
	"-cp313-cp313t-manylinux_2_17_ppc64le.manylinux2014_ppc64le.whl"
	"-cp39-cp39-win_amd64.whl"
	"-cp310-cp310-win_amd64.whl"
	"-cp311-cp311-win_amd64.whl"
	"-cp312-cp312-win_amd64.whl"
	"-cp313-cp313-win_amd64.whl"
	".tar.gz")
for whl_file in "${arr[@]}"
do
    curl -L -O https://github.com/symengine/symengine-wheels/releases/download/v${version}${version_post}/symengine-${version}${whl_file};
done

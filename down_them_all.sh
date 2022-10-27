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
	"-cp38-cp38-macosx_10_9_x86_64.whl"
	"-cp39-cp39-macosx_10_9_x86_64.whl"
	"-cp310-cp310-macosx_10_9_x86_64.whl"
	"-cp311-cp311-macosx_10_9_x86_64.whl"
	"-cp38-cp38-macosx_11_0_arm64.whl"
	"-cp39-cp39-macosx_11_0_arm64.whl"
	"-cp310-cp310-macosx_11_0_arm64.whl"
	"-cp311-cp311-macosx_11_0_arm64.whl"
	"-cp38-cp38-manylinux2010_x86_64.whl"
	"-cp39-cp39-manylinux2010_x86_64.whl"
	"-cp310-cp310-manylinux2010_x86_64.whl"
	"-cp311-cp311-manylinux2010_x86_64.whl"
	"-cp38-cp38-manylinux2014_aarch64.whl"
	"-cp39-cp39-manylinux2014_aarch64.whl"
	"-cp310-cp310-manylinux2014_aarch64.whl"
	"-cp311-cp311-manylinux2014_aarch64.whl"
	"-cp38-cp38-manylinux2014_ppc64le.whl"
	"-cp39-cp39-manylinux2014_ppc64le.whl"
	"-cp310-cp310-manylinux2014_ppc64le.whl"
	"-cp311-cp311-manylinux2014_ppc64le.whl"
	"-cp38-cp38-win_amd64.whl"
	"-cp39-cp39-win_amd64.whl"
	"-cp310-cp310-win_amd64.whl"
	"-cp311-cp311-win_amd64.whl"
        "-pp38-pypy38_pp73-macosx_10_9_x86_64.whl"
        "-pp39-pypy39_pp73-macosx_10_9_x86_64.whl"
        "-pp38-pypy38_pp73-manylinux2010_x86_64.whl"
        "-pp39-pypy39_pp73-manylinux2010_x86_64.whl"
        "-pp38-pypy38_pp73-manylinux2014_aarch64.whl"
        "-pp39-pypy39_pp73-manylinux2014_aarch64.whl"
        "-pp38-pypy38_pp73-manylinux2014_ppc64le.whl"
        "-pp39-pypy39_pp73-manylinux2014_ppc64le.whl"
	".tar.gz")
for whl_file in "${arr[@]}"
do
    curl -L -O https://github.com/symengine/symengine-wheels/releases/download/v${version}${version_post}/symengine-${version}${whl_file};
done



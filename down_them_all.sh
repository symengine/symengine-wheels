
#!/bin/bash

mkdir -p dist
cd dist

version=$1

if [[ "$1" == "" ]]; then
    echo "Usage: down_them_all.sh <version>"
    exit 1
fi

declare -a arr=(
        "-cp27-cp27m-macosx_10_9_x86_64.whl"
	"-cp36-cp36m-macosx_10_9_x86_64.whl"
	"-cp37-cp37m-macosx_10_9_x86_64.whl"
	"-cp38-cp38-macosx_10_9_x86_64.whl"
	"-cp27-cp27m-manylinux1_x86_64.whl"
	"-cp27-cp27mu-manylinux1_x86_64.whl"
	"-cp35-cp35m-manylinux1_x86_64.whl"
	"-cp36-cp36m-manylinux1_x86_64.whl"
	"-cp37-cp37m-manylinux1_x86_64.whl"
	"-cp38-cp38-manylinux1_x86_64.whl"
	"-cp35-cp35m-win_amd64.whl"
	"-cp36-cp36m-win_amd64.whl"
	"-cp37-cp37m-win_amd64.whl"
	"-cp38-cp38-win_amd64.whl"
	".tar.gz")
for whl_file in "${arr[@]}"
do
    curl -L -O https://github.com/symengine/symengine-wheels/releases/download/v${version}/symengine-${version}${whl_file};
done

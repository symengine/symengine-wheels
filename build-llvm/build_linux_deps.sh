#!/bin/bash
set -e -x

cd /io
export MAKEFLAGS="-j32"
LLVM_VERSION=8.0.1
mkdir -p /deps
cd /deps
LICENSE_DIR=/io/llvm-$LLVM_VERSION/share/doc/llvm
mkdir -p $LICENSE_DIR

yum install -y git yum libxml2-devel xz

# newer cmake for LLVM
/opt/python/cp37-cp37m/bin/pip install cmake
export PATH="/opt/python/cp37-cp37m/lib/python3.7/site-packages/cmake/data/bin/:${PATH}"

# LLVM for pocl
curl -L -O https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/llvm-${LLVM_VERSION}.src.tar.xz
unxz llvm-${LLVM_VERSION}.src.tar.xz
tar -xf llvm-${LLVM_VERSION}.src.tar
pushd llvm-${LLVM_VERSION}.src
mkdir -p build
pushd build
cmake -DPYTHON_EXECUTABLE=/opt/python/cp37-cp37m/bin/python \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DLLVM_TARGETS_TO_BUILD=host \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_RTTI=ON \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_GO_TESTS=OFF \
    -DLLVM_INCLUDE_UTILS=ON \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_ENABLE_TERMINFO=OFF \
    -DLLVM_ENABLE_LIBXML2=OFF \
    -DLLVM_ENABLE_ZLIB=OFF \
    -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON \
    ..

make
make install
make install DESTDIR=/io/llvm-$LLVM_VERSION
popd
cp LICENSE.TXT $LICENSE_DIR/LLVM_LICENSE.txt
popd

# clang for pocl
curl -L -O https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/cfe-${LLVM_VERSION}.src.tar.xz
unxz cfe-${LLVM_VERSION}.src.tar.xz
tar -xf cfe-${LLVM_VERSION}.src.tar
pushd cfe-${LLVM_VERSION}.src
mkdir -p build
pushd build
cmake \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_PREFIX_PATH=/usr/local \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_RTTI=ON \
    -DCLANG_INCLUDE_TESTS=OFF \
    -DCLANG_INCLUDE_DOCS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_ENABLE_LIBXML2=OFF \
    -DLLVM_ENABLE_ZLIB=OFF \
    -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON \
    ..
make
make install
make install DESTDIR=/io/llvm-$LLVM_VERSION
popd
cp LICENSE.TXT $LICENSE_DIR/clang_LICENSE.txt
popd

pushd /io/
tar -czvf llvm-$LLVM_VERSION-manylinux1_x86-64.tar.gz pocl-$LLVM_VERSION

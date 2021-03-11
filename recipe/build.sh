#!/usr/bin/env bash

pushd cxx

mkdir build
cd build

if [[ "$target_platform" == linux-* ]]; then
    export LDFLAGS="$LDFLAGS -static-libstdc++"
fi

cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_BENCHMARKS=no \
    -DINTEGER_CLASS=flint \
    -DWITH_SYMENGINE_THREAD_SAFE=yes \
    -DWITH_MPC=yes \
    -DWITH_FLINT=yes \
    -DWITH_LLVM=yes \
    -DBUILD_FOR_DISTRIBUTION=yes \
    -DBUILD_SHARED_LIBS=no \
    ..

cmake --build . -- -j${CPU_COUNT}
cmake --build . --target install

ctest

popd

pushd python
  python setup.py bdist_wheel
  if [[ "$target_platform" == linux-64 ]]; then
    rm -rf $PREFIX/lib/libstdc++.*
    rm -rf $PREFIX/lib/libgcc*
    auditwheel repair dist/*.whl -w $PWD/fixed_wheels --plat manylinux2010_x86_64
  elif [[ "$target_platform" == linux-* ]]; then
    rm -rf $PREFIX/lib/libstdc++.*
    rm -rf $PREFIX/lib/libgcc*
    auditwheel repair dist/*.whl -w $PWD/fixed_wheels --plat manylinux2014_$ARCH
  else
    rm -rf $PREFIX/lib/libc++.*
    delocate-wheel -w fixed_wheels -v dist/*.whl
  fi
popd

for whl in python/fixed_wheels/*.whl; do
  if [[ "$build_platform" == "osx-*" ]]; then
    cp $whl /Users/runner/miniforge3/conda-bld/
  elif [[ "$build_platform" == "linux-*" ]]; then
    cp $whl /home/conda/feedstock_root/build_artifacts/
  fi
done

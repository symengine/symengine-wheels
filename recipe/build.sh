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
    -DBUILD_SHARED_LIBS=yes \
    ..

cmake --build . -- -j${CPU_COUNT}
cmake --build . --target install

ctest

popd

pushd python
  python setup.py build_ext -i --symengine-dir=$PREFIX bdist_wheel
  if [[ "$target_platform" == linux-* ]]; then
    auditwheel repair dist/*.whl -w $PWD/fixed_wheels
  else
    rm $PREFIX/lib/libc++.*
    delocate-wheel -w fixed_wheels -v dist/*.whl
  fi
popd

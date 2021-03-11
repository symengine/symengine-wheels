#!/usr/bin/env bash

set -x

pushd cxx

mkdir build
cd build

if [[ "$target_platform" == linux-* ]]; then
    export LDFLAGS="$LDFLAGS -static-libstdc++"
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DBUILD_TESTS=no"
fi

cmake ${CMAKE_ARGS} \
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
    -DWITH_COTIRE=no \
    -DBUILD_FOR_DISTRIBUTION=yes \
    -DBUILD_SHARED_LIBS=no \
    ..

cmake --build . -- -j${CPU_COUNT}
cmake --build . --target install

ctest

popd

pushd python
  PYTHON_ARGS="-D IGNORE_THIS=1"
  for ARG in $CMAKE_ARGS; do
    if [[ "$ARG" == "-DCMAKE_"* ]] && [[ "$ARG" != *";"* ]]; then
      cmake_arg=$(echo $ARG | cut -d= -f1)
      cmake_arg=$(echo $cmake_arg| cut -dD -f2-)
      cmake_val=$(echo $ARG | cut -d= -f2-)
      PYTHON_ARGS="$PYTHON_ARGS;${cmake_arg}=${cmake_val}"
    fi
  done
  $PYTHON setup.py bdist_wheel build_ext -i $PYTHON_ARGS
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
  if [[ "$build_platform" == "osx-"* ]]; then
    WHL_DEST=$SRC_DIR/build_artifacts/pypi_wheels
  elif [[ "$build_platform" == "linux-"* ]]; then
    WHL_DEST=/home/conda/feedstock_root/build_artifacts/pypi_wheels
  fi
  mkdir -p $WHL_DEST
  cp $whl $WHL_DEST
done

for whl in python/fixed_wheels/*.whl; do
   $PYTHON -m pip install $whl
done

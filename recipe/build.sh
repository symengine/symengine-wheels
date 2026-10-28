#!/usr/bin/env bash

set -x

# Build the C++ library
pushd cxx

mkdir build
cd build

if [[ "$target_platform" == linux-* ]]; then
    export LDFLAGS="$LDFLAGS -static-libstdc++ -Wl,--exclude-libs,ALL"
fi

if [[ "$target_platform" == linux-ppc64le ]]; then
    export CXXFLAGS="$CXXFLAGS -fplt"
    export LDFLAGS="$LDFLAGS -fplt"
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
    -DWITH_LLVM_DYLIB=no \
    ..

make -j${CPU_COUNT} VERBOSE=1
make install

ctest

popd

rm -rf $PREFIX/lib/libc++.*

# Build the python wheel
pushd python
  echo "" >> LICENSE
  cat $RECIPE_DIR/UPSTREAM_LICENSES.txt >> LICENSE
  $PYTHON -m pip wheel . -vv --no-deps --no-build-isolation -w dist \
    -Ccmake.define.SymEngine_DIR=$PREFIX \
    -Ccmake.define.CMAKE_VERBOSE_MAKEFILE=ON
popd

# Repair the wheel
pushd python
  if [[ "$target_platform" == linux-64 ]]; then
    rm -rf $PREFIX/lib/libstdc++.*
    rm -rf $PREFIX/lib/libgcc*
    $PYTHON -m auditwheel repair dist/*.whl -w $PWD/fixed_wheels --plat manylinux2014_x86_64
  elif [[ "$target_platform" == linux-* ]]; then
    rm -rf $PREFIX/lib/libstdc++.*
    rm -rf $PREFIX/lib/libgcc*
    $PYTHON -m auditwheel repair dist/*.whl -w $PWD/fixed_wheels --plat manylinux2014_$ARCH
  else
    $PYTHON $(which delocate-wheel) -w fixed_wheels --sanitize-rpaths -v dist/*.whl
  fi
popd

# Copy the wheel to destination
for whl in python/fixed_wheels/*.whl; do
  if [[ "$build_platform" == "osx-"* ]]; then
    WHL_DEST=$RECIPE_DIR/../build_artifacts/pypi_wheels
  elif [[ "$build_platform" == "linux-"* ]]; then
    WHL_DEST=/home/conda/feedstock_root/build_artifacts/pypi_wheels
  fi
  mkdir -p $WHL_DEST
  cp $whl $WHL_DEST
done

# Install the wheel
for whl in python/fixed_wheels/*.whl; do
  if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" && "$target_platform" == linux-* ]]; then
    # crossenv>=1.6 only accepts linux_<arch> wheels
    mkdir -p python/linux_wheels
    linux_whl=python/linux_wheels/$(basename $whl | sed -E "s/-manylinux[^-]*\.whl$/-linux_${target_platform#linux-}.whl/")
    cp $whl $linux_whl
    whl=$linux_whl
  fi
  $PYTHON -m pip install $whl
done

# debug
if [[ "$target_platform" == "osx-"* ]]; then
  for f in $(find $SP_DIR/symengine -name "*.so" -or -name "*.dylib"); do
    echo $f
    otool -l $f
  done
fi

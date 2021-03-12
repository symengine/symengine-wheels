cd cxx

mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_BENCHMARKS=no ^
    -DINTEGER_CLASS=flint ^
    -DWITH_MPC=yes ^
    -DWITH_LLVM=yes ^
    -DWITH_COTIRE=no ^
    -DWITH_SYMENGINE_THREAD_SAFE=yes ^
    -DBUILD_FOR_DISTRIBUTION=yes ^
    -DBUILD_SHARED_LIBS=yes ^
    -DMSVC_USE_MT=no ^
    -DBUILD_SHARED_LIBS=no ^
    ..

ninja -j%CPU_COUNT%
ninja install
ctest

cd ..
cd ..

cd python
%PYTHON% setup.py bdist_wheel build_ext --generator=Ninja install --symengine-dir=%LIBRARY_PREFIX%

set dep_dir=%LIBRARY_BIN%
%PYTHON% %SRC_DIR%\fix_windows_wheel.py %dep_dir%\mpir.dll %dep_dir%\mpfr.dll %dep_dir%\mpc.dll %dep_dir%\flint-15.dll

mkdir %SRC_DIR%\build_artifacts
mkdir %SRC_DIR%\build_artifacts\pypi_wheels

for %%f in (dist\*.whl) do (
  cp %%f %SRC_DIR%\build_artifacts\pypi_wheels\
  %PYTHON% -m pip install %%f
)

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
if errorlevel 1 exit 1

ninja -j%CPU_COUNT%
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1
ctest
if errorlevel 1 exit 1

cd ..
cd ..

cd python
type %RECIPE_DIR%\\UPSTREAM_LICENSES.txt >> LICENSE
%PYTHON% setup.py bdist_wheel build_ext --generator=Ninja install --symengine-dir=%LIBRARY_PREFIX%
if errorlevel 1 exit 1

set dep_dir=%LIBRARY_BIN%
python %RECIPE_DIR%\fix_windows_wheel.py ^
  %dep_dir%\mpir.dll ^
  %dep_dir%\mpfr.dll ^
  %dep_dir%\mpc.dll ^
  %dep_dir%\flint-17.dll ^
  %dep_dir%\pthreadVSE2.dll ^
  %dep_dir%\zstd.dll ^
  %dep_dir%\zlib.dll
if errorlevel 1 exit 1

mkdir %RECIPE_DIR%\..\build_artifacts
mkdir %RECIPE_DIR%\..\build_artifacts\pypi_wheels

for %%f in (dist\*.whl) do (
  copy %%f %RECIPE_DIR%\..\build_artifacts\pypi_wheels\
  if errorlevel 1 exit 1
  %PYTHON% -m pip install %%f
)

@Echo off 
SETLOCAL

mkdir symengine\dist
if [%UPLOAD_ARCHIVES%] == [yes] appveyor DownloadFile http://mpir.org/mpir-3.0.0.tar.bz2 && mv mpir-3.0.0.tar.bz2 symengine/dist/mpir-3.0.0.tar.bz2
if [%UPLOAD_ARCHIVES%] == [yes] appveyor DownloadFile http://ftp.gnu.org/gnu/mpfr/mpfr-4.0.2.tar.gz && mv mpfr-4.0.2.tar.gz symengine/dist/mpfr-4.0.2.tar.gz
if [%UPLOAD_ARCHIVES%] == [yes] appveyor DownloadFile http://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz && mv mpc-1.1.0.tar.gz symengine/dist/mpc-1.1.0.tar.gz
if [%UPLOAD_ARCHIVES%] == [yes] appveyor DownloadFile http://flintlib.org/flint-2.6.3.tar.gz && mv flint-2.6.3.tar.gz symengine/dist/flint-2.6.3.tar.gz
if [%UPLOAD_ARCHIVES%] == [yes] appveyor DownloadFile https://github.com/llvm/llvm-project/releases/download/llvmorg-8.0.1/llvm-8.0.1.src.tar.xz && mv llvm-8.0.1.src.tar.xz symengine/dist/llvm-8.0.1.src.tar.xz

call %CONDA_INSTALL_LOCN%\Scripts\activate.bat
conda.exe config --add channels conda-forge
conda.exe create -n symengine --yes symengine mpir=3.0.0 mpfr=4.0.2 mpc=1.1.0 vc=14 llvmdev=8.0.1 libflint=2.6.3
call activate symengine
conda.exe remove --yes --force vs2015_runtime

::back to Standard commission
ENDLOCAL

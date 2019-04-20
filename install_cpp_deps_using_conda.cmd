@Echo off 
SETLOCAL

mkdir symengine\dist
if [%UPLOAD_ARCHIVES%] == [yes] appveyor DownloadFile http://mpir.org/mpir-3.0.0.tar.bz2 && mv mpir-3.0.0.tar.bz2 symengine/dist/mpir-3.0.0.tar.bz2
if [%UPLOAD_ARCHIVES%] == [yes] appveyor DownloadFile http://ftp.gnu.org/gnu/mpfr/mpfr-4.0.1.tar.gz && mv mpfr-4.0.1.tar.gz symengine/dist/mpfr-4.0.1.tar.gz
if [%UPLOAD_ARCHIVES%] == [yes] appveyor DownloadFile http://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz && mv mpc-1.1.0.tar.gz symengine/dist/mpc-1.1.0.tar.gz
if [%UPLOAD_ARCHIVES%] == [yes] appveyor DownloadFile http://releases.llvm.org/7.0.0/llvm-7.0.0.src.tar.xz && mv llvm-7.0.0.src.tar.xz symengine/dist/llvm-7.0.0.src.tar.xz

call %CONDA_INSTALL_LOCN%\Scripts\activate.bat
conda.exe config --add channels conda-forge
conda.exe create -n symengine --yes symengine mpir=3.0.0 mpfr=4.0.1 mpc=1.1.0 vc=14 llvmdev=7.0.0
call activate symengine
conda.exe remove --yes --force vs2015_runtime

::back to Standard commission
ENDLOCAL

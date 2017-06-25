@Echo off 
SETLOCAL

mkdir symengine\dist
if [%UPLOAD_ARCHIVES%] == [yes] appveyor DownloadFile http://mpir.org/mpir-3.0.0.tar.bz2 && mv mpir-3.0.0.tar.bz2 symengine/dist/mpir-3.0.0.tar.bz2
if [%UPLOAD_ARCHIVES%] == [yes] appveyor DownloadFile https://github.com/isuruf/mpfr/archive/3.1.5-win.tar.gz && mv 3.1.5-win.tar.gz symengine/dist/mpfr-3.1.5-win.tar.gz
if [%UPLOAD_ARCHIVES%] == [yes] appveyor DownloadFile https://github.com/isuruf/mpc/archive/1.0.3-win.tar.gz && mv 1.0.3-win.tar.gz symengine/dist/mpc-1.0.3-win.tar.gz


call %CONDA_INSTALL_LOCN%\Scripts\activate.bat
conda config --add channels conda-forge
conda create -n symengine --yes symengine=0.3.0 mpir=3.0.0 mpfr=3.1.5 mpc=1.0.3 vc=14
call activate symengine
conda remove --yes --force vs2015_runtime

::back to Standard commission
ENDLOCAL

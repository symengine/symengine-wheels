@Echo off 
SETLOCAL

call %CONDA_INSTALL_LOCN%\Scripts\activate.bat
conda config --add channels conda-forge
conda create -n symengine --yes symengine=0.3.0 mpir=3.0.0 vc=14
call activate symengine
conda remove --yes --force vc
conda remove --yes --force vs2015_runtime

::back to Standard commission
ENDLOCAL

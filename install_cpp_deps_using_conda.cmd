@Echo off 
SETLOCAL

call %CONDA_INSTALL_LOCN%\Scripts\activate.bat
conda config --add channels conda-forge
conda create -n symengine symengine=0.3.0 mpir=3.0.0 vc=14
activate symengine
conda remove --force vc
conda remove --force vs2015_runtime

::back to Standard commission
ENDLOCAL

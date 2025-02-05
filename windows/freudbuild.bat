if exist "%USERPROFILE%\code\freud" (
cd "%USERPROFILE%\code\freud"
echo "Using conda environment: %CONDA_PREFIX%"
set "TBB_INCLUDE=%CONDA_PREFIX%\Library\include"
set "TBB_LINK=%CONDA_PREFIX%\Library\lib"
python setup.py install --ENABLE-CYTHON
) else (
echo "Did not find freud repository."
)

REM This script runs the bare essentials for setup on a new system

REM Install miniforge
REM curl -O https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Windows-x86_64.exe
REM cmd /C Mambaforge-Windows-x86_64.exe
REM del /f Mambaforge-Windows-x86_64.exe

REM Call installation scripts
cd windows
cmd /C repo-installer.bat
cmd /C conda-env-setup.bat
cd ..

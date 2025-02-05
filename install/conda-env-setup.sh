#!/bin/bash

# Set up conda environment with desired packages

# Detect Platform
if [ "$(uname -s)" == "Darwin" ]; then
    OS_PLATFORM="Mac"
elif [ "$(uname -s)" == "Linux" ]; then
    OS_PLATFORM="Linux"
else
    # Default to Linux
    OS_PLATFORM="Linux"
fi

PYDATA_PKGS="python=3.12 numpy pandas tqdm cython"
DEV_PKGS="\
    black \
    conda-package-handling \
    isort \
    ipython \
    pre-commit \
    pudb \
    pytest \
    pytest-xdist"
SYS_PKGS="cmake gh ninja ripgrep jq"
if [ "$(uname -m)" = "x86_64" ]; then
    # go-yq not available on aarch64 yet
    SYS_PKGS="${SYS_PKGS} go-yq"
fi

ALL_PKGS="$PYDATA_PKGS $DEV_PKGS $SYS_PKGS"

# Set up channels
conda config --add channels conda-forge

# Create environments if they don't exist
if [ -d $HOME/miniforge3-aarch64/bin ] && [ "$(uname -m)" = "aarch64" ]; then
    export CONDA_PATH="$HOME/miniforge3-aarch64"
elif [ -d $HOME/mambaforge-aarch64/bin ] && [ "$(uname -m)" = "aarch64" ]; then
    export CONDA_PATH="$HOME/mambaforge-aarch64"
elif [ -d $HOME/miniforge3/bin ] && [ "$(uname -m)" = "x86_64" ]; then
    export CONDA_PATH="$HOME/miniforge3"
elif [ -d $HOME/mambaforge/bin ] && [ "$(uname -m)" = "x86_64" ]; then
    export CONDA_PATH="$HOME/mambaforge"
elif [ -d $HOME/miniconda3/bin ] && [ "$(uname -m)" = "x86_64" ]; then
    export CONDA_PATH="$HOME/miniconda3"
elif [ -d $HOME/anaconda3/bin ] && [ "$(uname -m)" = "x86_64" ]; then
    export CONDA_PATH="$HOME/anaconda3"
fi

if [ ! -d "$CONDA_PATH/envs/dice" ]; then
    mamba create --yes --name dice
fi

# Update/install packages
mamba install --name dice $ALL_PKGS

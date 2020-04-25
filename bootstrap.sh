#!/bin/bash

# This script runs the bare essentials for setup on a new system

# Run the sync script for .bashrc, etc.
bash home/sync.sh

# Set up vundle
bash install/install-vundle.sh

# Grab miniconda
cd $HOME
if [ "$(uname -s)" == "Darwin" ]; then
    # Mac
    curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
    chmod +x Miniconda3-latest-MacOSX-x86_64.sh
    bash Miniconda3-latest-MacOSX-x86_64.sh
else
    # Linux
    curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    chmod +x Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh
fi

#!/bin/bash

# This script runs the bare essentials for setup on a new system

# Run the sync script for .bashrc, etc.
bash home/sync.sh

# Set up vundle
bash install/install-vundle.sh

# Set up miniforge
bash install/install-miniforge3.sh

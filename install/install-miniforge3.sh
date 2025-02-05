#!/bin/bash
if [ "$(uname -s)" == "Darwin" ]; then
    # Mac
    installer_name=Miniforge3-MacOSX-x86_64.sh
    target_dir="$HOME/miniforge3"
elif [ "$(uname -m)" == "x86_64" ]; then
    # Linux x86_64
    installer_name=Miniforge3-Linux-x86_64.sh
    target_dir="$HOME/miniforge3"
elif [ "$(uname -m)" == "aarch64" ]; then
    # Linux aarch64
    installer_name=Miniforge3-Linux-aarch64.sh
    target_dir="$HOME/miniforge3-aarch64"
else
    echo "No supported platform found."
    exit 1
fi

flags="-b -p ${target_dir}"

if [ ! -d "${target_dir}" ]; then
    pushd ${HOME}
    curl -O -L "https://github.com/conda-forge/miniforge/releases/latest/download/${installer_name}"
    chmod +x "${installer_name}"
    bash "${installer_name}" ${flags}
    rm "${installer_name}"
    popd
else
    echo "It appears miniforge3 is already installed."
fi

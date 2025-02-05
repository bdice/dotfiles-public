#!/bin/bash

set -eu

sudo apt install docker-buildx docker.io
sudo groupadd -f docker
sudo usermod -aG docker $USER

echo
echo "Now add the following lines to /etc/wsl.conf, and then restart WSL2 with 'wsl.exe --shutdown':"
echo
echo "[boot]"
echo "systemd=true"

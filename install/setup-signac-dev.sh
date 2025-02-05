#!/bin/bash

while true; do
    echo "CONDA_PREFIX: $CONDA_PREFIX"
    read -p "Install synced_collections, signac, signac-flow, signac-dashboard in dev mode? " yn
    case $yn in
        [Yy]* )
            cd $CODE_DIR/synced_collections
            pip install -e .
            cd $CODE_DIR/signac
            pip install -e .
            cd $CODE_DIR/signac-flow
            pip install -e .
            cd $CODE_DIR/signac-dashboard
            pip install -e .
            break
            ;;
        [Nn]* )
            exit
            ;;
        * ) echo "Please answer yes or no.";;
    esac
done

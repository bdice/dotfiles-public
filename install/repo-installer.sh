#!/bin/bash
if [ ! -d "${CODE_DIR}" ]; then
    echo "Environment variable \$CODE_DIR not set or does not exist."
    exit 1
fi

source $HOME/.bash_aliases

pushd ${CODE_DIR}

# Personal repositories
for repo in dotfiles rapids-sketches; do
    ghclone bdice/${repo}
done

# RAPIDS repositories
for repo in devcontainers rapids-cmake rmm kvikio cudf raft cuvs cumlprims_mg cuml cugraph cugraph-gnn nx-cugraph cuspatial cuxfilter ucxx ucx-py shared-workflows integration; do
    ghclone rapidsai/${repo}
done

popd

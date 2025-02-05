#!/bin/bash
if [[ "$(uname -s)" == "Darwin" ]]; then
    # Requires gnu-sed: brew install gnu-sed
    SED_COMMAND="gsed"
else
    SED_COMMAND="sed"
fi
DIR=${1:-${CODE_DIR}}
for file in ${DIR}/*/.git/config; do
    echo "Processing $file"
    ${SED_COMMAND} -i 's/git@github.com:/https:\/\/github\.com\//g' $file
done

#!/bin/bash

set -euo pipefail

# This script generates a key for use in GitHub code signing

KEYFILE="$HOME/.ssh/code_signing_ed25519"

if [ ! -f $KEYFILE ]; then
    ssh-keygen -t ed25519 -f $KEYFILE
fi

SUFFIX=$(uname)
if [[ $(uname -r) == *WSL* ]]; then
    SUFFIX="WSL"
fi

KEYTITLE="$(hostname) $SUFFIX $(date -r $KEYFILE +%Y-%m-%d)"
echo $KEYTITLE

gh ssh-key add ~/.ssh/code_signing_ed25519.pub --title "$KEYTITLE" --type signing

# Declaring the `git` namespace helps prevent cross-protocol attacks.
ALLOWED_SIGNER="$(git config --get user.email) namespaces=\"git\" $(cat $KEYFILE.pub)"
ALLOWED_SIGNERS_FILE="$HOME/.ssh/allowed_signers"
if [ ! -f $ALLOWED_SIGNERS_FILE ] || ! grep -q "$ALLOWED_SIGNER" "$ALLOWED_SIGNERS_FILE"; then
    echo $ALLOWED_SIGNER >> $ALLOWED_SIGNERS_FILE
    echo "Added allowed signer to $ALLOWED_SIGNERS_FILE."
else
    echo "Allowed signer already found in $ALLOWED_SIGNERS_FILE."
fi

echo "Code signing setup complete. Key is in $KEYFILE."

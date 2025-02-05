#!/bin/bash

function sync_file() {
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    FILENAME=$SCRIPT_DIR/$1
    REPLACE_PATH=$2
    if [ -e $FILENAME ]; then
        if [ -e "${REPLACE_PATH}" ]; then
            DIFF=$(diff $FILENAME ${REPLACE_PATH})
            if [ "$DIFF" != "" ]; then
                echo -e "\033[38;5;226mFile $FILENAME is different:\033[0m"
                diff $FILENAME ${REPLACE_PATH}
                while true; do
                    read -p "Replace file ${REPLACE_PATH}? " yn
                    case $yn in
                        [Yy]* ) cp -v $FILENAME ${REPLACE_PATH}; break;;
                        [Nn]* ) break;;
                        * ) echo "Please answer yes or no.";;
                    esac
                done
            fi
        else
            echo "Copying $FILENAME to ${REPLACE_PATH} since it doesn't exist."
            mkdir -p $(dirname ${REPLACE_PATH})
            cp -v $FILENAME ${REPLACE_PATH}
        fi
    else
        echo "File $FILENAME does not exist."
    fi
}

read -r -d '' SYNC_LIST <<'EOF'
.bash_aliases
.bash_profile
.bashrc
.completions/git-completion.bash
.dircolors
.gemrc
.gitconfig
.gitexcludes
.ipython/profile_default/ipython_config.py
.local/bin/extract
.local/bin/pr_get
.local/bin/rapids-ci
.local/bin/rapids-conda
.local/bin/rapids-dev
.local/bin/rapids-fix-forward-merge
.local/bin/rapids-update-default-branches
.local/bin/sync_compose_aliases
.local/bin/sync_repo_remotes
.ripgreprc
.signacrc
.ssh/config
.tmux.conf
.vim/colors/monokai.vim
.vimrc
EOF

for i in ${SYNC_LIST}; do
    sync_file $i $HOME/$i
done

if [ -e $HOME/.ssh/config ]; then
    chmod 600 $HOME/.ssh/config
fi

# Host-specific setup
if [ -e /proc/version ] && grep -iq microsoft /proc/version; then
    sync_file extras/wsl/.bashrc_extras $HOME/.bashrc_extras
fi

sync_file repo-updater.sh $HOME/repo-updater.sh

echo -e "\033[38;5;82mDone. Synced.\033[0m"

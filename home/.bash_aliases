# Detect Platform
if ! command -v uname &> /dev/null; then
    # Probably running on a super-bare platform or Cygwin
    OS_PLATFORM="Linux"
elif [ "$(uname -s)" == "Linux" ]; then
    OS_PLATFORM="Linux"
elif [ "$(uname -s)" == "Darwin" ]; then
    OS_PLATFORM="Mac"
else
    # Default to Linux
    OS_PLATFORM="Linux"
fi

# Aliases
if [ "$OS_PLATFORM" == "Mac" ]; then
    # Color ls
    export CLICOLOR=1
    export LSCOLORS=ExFxCxDxBxegedabagacad
    # Color grep
    export GREP_OPTIONS="--color=always"
    export GREP_COLOR="1;35;40"

    # Prevent path_helper from messing up PATH in tmux
    if [ -n $TMUX ] && [ -f /etc/profile ]; then
        PATH=""
        source /etc/profile
    fi
else
    alias ls="ls --color=auto"
    alias grep="grep --color=auto"
fi

alias ll="ls -alhF"
alias sl="ls"
alias l="ls"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."
alias ........="cd ../../../../../../.."
alias tmux="tmux -2 -u"
alias tl="tmux ls"
alias ta="tmux attach -t"
alias qq="squeue -u $USER"
alias pc="pre-commit run --all-files --show-diff-on-failure"
alias env_sorted="env -0 | sort -z | tr '\0' '\n'"

# Git quick commands.
alias s="git status"
alias ga="git add -p"
alias com="git commit -m"
alias ch="git checkout"
alias fetch="git fetch --all"
alias push="git push"
alias pull="git pull"
alias pul="git pull"
alias gsui="git submodule update --init"
alias gdiff="git diff --no-index --"
alias prs="gh pr list"
alias myprs="gh pr list --author bdice"

# cddir: if the argument is a file, cd to its directory.
# If directory, cd there directly.
function cddir() {
    TARGET=$1
    if [ -d "$TARGET" ]; then
        cd $TARGET
    elif [ -e "$TARGET" ]; then
        cd $(dirname $TARGET)
    else
        echo "$TARGET is not a file or directory."
    fi
}

# search:
# first argument is search pattern
# second arg (optional) is directory
function search() {
    grep -rn ${2:-.} -e "$1"
}

# keep repeats a task every 5 seconds
function keep() {
    "$@"
    while sleep 5; do
        "$@"
    done
}

# git clone with some defaults
function bbclone() {
    if [ -d ${3:-"${1}"} ]; then
        echo "${1} is already cloned."
    else
        git clone --recurse-submodules git@bitbucket.org:${2:-"bdice"}/${1}.git ${3:-"${1}"}
    fi
}

# git clone with some defaults
function ghclone() {
    # Assume the repo is named like "owner/repo"
    owner="$(awk -F'/' '{ print $1 }' <<< $1)"
    repo="$(awk -F'/' '{ print $2 }' <<< $1)"
    repo_dir=${2:-"${repo}"}

    # Handle errors
    if [ -d "${repo_dir}" ]; then
        echo "${repo} is already cloned."
        return 1
    elif [ -z "${repo}" ]; then
        echo "Repo is empty. Try using format owner/repo."
        return 1
    fi

    # Clone the repo
    if command -v gh &> /dev/null; then
        if [ "${owner}" = "bdice" ]; then
            gh repo clone "${owner}/${repo}" -- --recurse-submodules
        else
            gh repo fork --clone "${owner}/${repo}" -- --recurse-submodules
        fi
    else
        echo "gh not found; attempting normal git clone"
        git clone --recurse-submodules git@github.com:${owner}/${repo}.git "${repo_dir}"
    fi

    # Set up pre-commit and gh default upstream
    pushd "${repo_dir}" > /dev/null
    if command -v gh &> /dev/null; then
        gh repo set-default "${owner}/${repo}"
    fi
    if command -v pre-commit &> /dev/null && [ -f ".pre-commit-config.yaml" ]; then
        pre-commit install
    fi
    popd > /dev/null
}

# git clone RAPIDS repo with upstream remote
function rapidsclone() {
    repo_dir=${3:-"${1}"}
    ghclone $1 rapidsai $3
    if [[ "$?" == 0 ]]; then
        pushd "${repo_dir}" > /dev/null
        git remote rename origin upstream
        git config checkout.defaultRemote upstream
        git config "remote.upstream.gh-resolved" base
        git remote add origin git@github.com:${2:-"bdice"}/${1}.git
        popd > /dev/null
    fi
}

# jsonprettify pretty-prints a json file
function jsonprettify() {
    python -m json.tool $1 | pygmentize -l javascript
}

# Launch a webserver in the current directory
function webserve() {
    python -m http.server --bind localhost ${1:-8888}
}

# Render sphinx docs from the current directory
function sphinxserve() {
    make html || return 1
    trap "cd ../.." RETURN
    cd _build/html && webserve ${1:-8888}
}

# Jupyter setup
alias jn="jupyter notebook --port=8675 --no-browser"
alias jl="jupyter lab --port=8675 --no-browser"

# Get Python package path and version
function whichpy() {
    python -c "import $1; print('File: ' + $1.__file__); print('Version: ' + $1.__version__)"
}

# Set breakpoint() in Python to call pudb
alias setpudb="export PYTHONBREAKPOINT=\"pudb.set_trace\""

# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output. So make sure this doesn't display
# anything or bad things will happen!

umask 007

# Test for an interactive shell. There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
    # Shell is non-interactive. Be done now!
    return
fi

# Load command aliases from ~/.bash_aliases
if [[ -f ~/.bash_aliases ]] ; then
    . ~/.bash_aliases
fi

# Shell options
# Automatically enter directories
shopt -s autocd
# Correct spelling errors during cd
shopt -s cdspell
# Combine multi-line commands in history
shopt -s cmdhist
# Print timestamps in history
HISTTIMEFORMAT="%F %T "

# Colors in terminal
#export TERM=xterm-256color
export PS1="\[\033[1;32m\]\u@\h \[\033[38;5;12m\]\w $\[\033[0m\] "

# Autocomplete settings
complete -d cd
complete -f vim
if [ -f $HOME/.completions/git-completion.bash ]; then
    source $HOME/.completions/git-completion.bash
fi

# Set up ripgrep config
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# ==========
# PATH SETUP
# ==========

# Include .local/bin in front of PATH
if [[ ! ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
    export PATH=$HOME/.local/bin:$PATH
fi

# yarn setup
if [ -d $HOME/.yarn/bin ] && [[ ! ":$PATH:" == *":$HOME/.yarn/bin:"* ]]; then
    export PATH="$HOME/.yarn/bin:$PATH"
fi

# npm setup
if [ -d $HOME/node_modules/.bin ] && [[ ! ":$PATH:" == *":$HOME/node_modules/.bin:"* ]]; then
    export PATH="$HOME/node_modules/.bin:$PATH"
fi

# rust setup
if [ -d "$HOME/.cargo" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# go setup
if [ -d $HOME/go/bin ] && [[ ! ":$PATH:" == *":$HOME/go/bin:"* ]]; then
    export PATH="$HOME/go/bin:$PATH"
fi

# conda PATH setup
if [ -d $HOME/miniforge3-aarch64/bin ] && [ "$(uname -m)" = "aarch64" ]; then
    export CONDA_PATH="$HOME/miniforge3-aarch64"
elif [ -d $HOME/mambaforge-aarch64/bin ] && [ "$(uname -m)" = "aarch64" ]; then
    export CONDA_PATH="$HOME/mambaforge-aarch64"
elif [ -d $HOME/miniforge3/bin ] && [ "$(uname -m)" = "x86_64" ]; then
    export CONDA_PATH="$HOME/miniforge3"
elif [ -d $HOME/mambaforge/bin ] && [ "$(uname -m)" = "x86_64" ]; then
    export CONDA_PATH="$HOME/mambaforge"
elif [ -d $HOME/miniconda3/bin ] && [ "$(uname -m)" = "x86_64" ]; then
    export CONDA_PATH="$HOME/miniconda3"
elif [ -d $HOME/anaconda3/bin ] && [ "$(uname -m)" = "x86_64" ]; then
    export CONDA_PATH="$HOME/anaconda3"
fi
if [ "$CONDA_PATH" ] && [ -d "$CONDA_PATH" ]; then
    eval "$($CONDA_PATH/bin/conda shell.bash hook)"
    function deconda() {
        while [[ -n "$CONDA_DEFAULT_ENV" ]]; do
            echo "Deactivating ($CONDA_DEFAULT_ENV)..."
            conda deactivate
        done
        export PATH=$(echo $PATH | sed -e "s|${CONDA_PATH}/condabin:||")
    }
fi

# activate default conda environment
if [ -d "${CONDA_PATH}/envs/dice" ]; then
    source activate dice
elif [ -d "${CONDA_PATH}/envs/rapids" ]; then
    source activate rapids
fi

# Code directory
if [ -d $HOME/code ]; then
    export CODE_DIR="$HOME/code"
else
    export CODE_DIR="$HOME"
fi

# SSH Hosts
export PORTFWDS="-L 8675:localhost:8675 -L 8676:localhost:8676 -L 8888:localhost:8888 -L 8889:localhost:8889"

# Set editor
if command -v vim &> /dev/null; then
    export EDITOR=vim
fi

# Distro-specific setup
if [ -e /etc/os-release ]; then
    if [[ $(. /etc/os-release; printf '%s\n' "$NAME"; ) =~ (Ubuntu|Debian) ]]; then
        alias upg="sudo apt-get update && sudo apt-get full-upgrade && sudo apt-get autoremove"
    fi
fi

if [[ -f "$HOME/.bashrc_extras" ]]; then
    . $HOME/.bashrc_extras
fi

# Automatically add completion for all aliases to commands having completion functions
function alias_completion {
    local namespace="alias_completion"

    # parse function based completion definitions, where capture group 2 => function and 3 => trigger
    local compl_regex='complete( +[^ ]+)* -F ([^ ]+) ("[^"]+"|[^ ]+)'
    # parse alias definitions, where capture group 1 => trigger, 2 => command, 3 => command arguments
    local alias_regex="alias ([^=]+)='(\"[^\"]+\"|[^ ]+)(( +[^ ]+)*)'"

    # create array of function completion triggers, keeping multi-word triggers together
    eval "local completions=($(complete -p | sed -Ene "/$compl_regex/s//'\3'/p"))"
    (( ${#completions[@]} == 0 )) && return 0

    # create temporary file for wrapper functions and completions
    rm -f "/tmp/${namespace}-*.tmp" # preliminary cleanup
    local tmp_file; tmp_file="$(mktemp "/tmp/${namespace}-${RANDOM}XXX.tmp")" || return 1

    local completion_loader; completion_loader="$(complete -p -D 2>/dev/null | sed -Ene 's/.* -F ([^ ]*).*/\1/p')"

    # read in "<alias> '<aliased command>' '<command args>'" lines from defined aliases
    local line; while read line; do
        eval "local alias_tokens; alias_tokens=($line)" 2>/dev/null || continue # some alias arg patterns cause an eval parse error
        local alias_name="${alias_tokens[0]}" alias_cmd="${alias_tokens[1]}" alias_args="${alias_tokens[2]# }"

        # skip aliases to pipes, boolean control structures and other command lists
        # (leveraging that eval errs out if $alias_args contains unquoted shell metacharacters)
        eval "local alias_arg_words; alias_arg_words=($alias_args)" 2>/dev/null || continue
        # avoid expanding wildcards
        read -a alias_arg_words <<< "$alias_args"

        # skip alias if there is no completion function triggered by the aliased command
        if [[ ! " ${completions[*]} " =~ " $alias_cmd " ]]; then
            if [[ -n "$completion_loader" ]]; then
                # force loading of completions for the aliased command
                eval "$completion_loader $alias_cmd"
                # 124 means completion loader was successful
                [[ $? -eq 124 ]] || continue
                completions+=($alias_cmd)
            else
                continue
            fi
        fi
        local new_completion="$(complete -p "$alias_cmd")"

        # create a wrapper inserting the alias arguments if any
        if [[ -n $alias_args ]]; then
            local compl_func="${new_completion/#* -F /}"; compl_func="${compl_func%% *}"
            # avoid recursive call loops by ignoring our own functions
            if [[ "${compl_func#_$namespace::}" == $compl_func ]]; then
                local compl_wrapper="_${namespace}::${alias_name}"
                    echo "function $compl_wrapper {
                        (( COMP_CWORD += ${#alias_arg_words[@]} ))
                        COMP_WORDS=($alias_cmd $alias_args \${COMP_WORDS[@]:1})
                        (( COMP_POINT -= \${#COMP_LINE} ))
                        COMP_LINE=\${COMP_LINE/$alias_name/$alias_cmd $alias_args}
                        (( COMP_POINT += \${#COMP_LINE} ))
                        $compl_func
                    }" >> "$tmp_file"
                    new_completion="${new_completion/ -F $compl_func / -F $compl_wrapper }"
            fi
        fi

        # replace completion trigger by alias
        new_completion="${new_completion% *} $alias_name"
        echo "$new_completion" >> "$tmp_file"
    done < <(alias -p | sed -Ene "s/$alias_regex/\1 '\2' '\3'/p")
    source "$tmp_file" && rm -f "$tmp_file"
}; alias_completion

if [ -f "${CODE_DIR}/rapids-cmake/cmake-format-rapids-cmake.json" ]; then
    export RAPIDS_CMAKE_FORMAT_FILE="${CODE_DIR}/rapids-cmake/cmake-format-rapids-cmake.json"
fi

#!/bin/bash
ORIGINAL_DIR=${PWD}

if [ -d "${CODE_DIR}" ]; then

    for i in "$@"; do
        case ${i} in
            -u|--update)
                DO_UPDATE=1
                echo "Updating all repos."
                shift
            ;;
            *)
                echo "Option not recognized."
            ;;
        esac
    done

    function update_repo() {
        if [ -d "$1" ]; then
            cd "$1"
            if [ -d ".git" ]; then
                if [[ $(git remote) ]]; then
                    REPO="$(basename "$(git rev-parse --show-toplevel)")"
                    echo -n "${REPO} fetching repository status..."
                    BRANCH="$(git rev-parse --abbrev-ref HEAD)"
                    git fetch --quiet --all
                    if git config remote.upstream.url > /dev/null; then
                        PREFERRED_REMOTE="upstream"
                    else
                        PREFERRED_REMOTE="origin"
                    fi
                    BRANCH_EXISTS="$(git ls-remote --heads ${PREFERRED_REMOTE} ${BRANCH} | wc -l)"
                    #UPSTREAM_DEFAULT_BRANCH="$(git symbolic-ref refs/remotes/${PREFERRED_REMOTE}/HEAD | sed 's@^refs/remotes/${PREFERRED_REMOTE}/@@')"
                    UPSTREAM_DEFAULT_BRANCH="$(git remote show ${PREFERRED_REMOTE} | grep "HEAD branch" | sed 's/.*: //')"
                    if [ "${BRANCH_EXISTS}" = "1" ]; then
                        UPSTREAM="${PREFERRED_REMOTE}/${BRANCH}"
                    else
                        UPSTREAM="${PREFERRED_REMOTE}/${UPSTREAM_DEFAULT_BRANCH}"
                    fi
                    TITLE="${REPO} (${BRANCH}, ${UPSTREAM})"
                    LOCAL="$(git rev-parse HEAD)"
                    REMOTE="$(git rev-parse "${UPSTREAM}")"
                    BASE="$(git merge-base HEAD "${UPSTREAM}")"
                    BASE_MASTER="$(git merge-base HEAD ${PREFERRED_REMOTE}/${UPSTREAM_DEFAULT_BRANCH})"
                    CURRENT_TAG="$(git describe --exact-match --tags HEAD 2>/dev/null)"
                    if [[ $(git diff --stat) != '' ]]; then
                        DIRTY="1"
                    else
                        DIRTY="0"
                    fi

                    # Clear "${REPO} fetching..."
                    CLEAR_TO_EOL=$(tput el)
                    echo -ne "\r${CLEAR_TO_EOL}"

                    if [ -n "${CURRENT_TAG}" ] && [ "${BRANCH}" = "HEAD" ]; then
                        echo -e "${TITLE}:\t\033[38;5;69mFixed at tag ${CURRENT_TAG}\033[0m"
                    elif [ "${LOCAL}" = "${REMOTE}" ]; then
                        DIRTY_MESSAGE=""
                        if [ "${DIRTY}" = "1" ]; then
                            DIRTY_MESSAGE=", uncommitted changes (dirty)"
                        fi
                        echo -e "${TITLE}:\t\033[38;5;82mUp-to-date${DIRTY_MESSAGE}\033[0m"
                    elif [ "${LOCAL}" = "${BASE}" ]; then
                        if [ "${LOCAL}" = "${BASE_MASTER}" ]; then
                            if [ "${DIRTY}" = "1" ]; then
                                echo -e "${TITLE}:\t\033[38;5;226mNeed to pull ${UPSTREAM_DEFAULT_BRANCH}, but the working tree is dirty\033[0m"
                            else
                                echo -e "${TITLE}:\t\033[38;5;226mNeed to pull ${UPSTREAM_DEFAULT_BRANCH}\033[0m"
                                if [ "${DO_UPDATE}" = "1" ]; then
                                    echo "Pulling ${REPO} ${UPSTREAM_DEFAULT_BRANCH}..."
                                    git checkout ${UPSTREAM_DEFAULT_BRANCH}
                                    git pull
                                fi
                            fi
                        else
                            echo -e "${TITLE}:\t\033[38;5;226mNeed to pull\033[0m"
                            if [ "${DO_UPDATE}" = "1" ]; then
                                echo "Pulling ${REPO}..."
                                git pull
                            fi
                        fi
                    elif [ "${REMOTE}" = "${BASE}" ]; then
                        echo -e "${TITLE}:\t\033[38;5;196mNeed to push\033[0m"
                    else
                        echo -e "${TITLE}:\t\033[38;5;214mDiverged\033[0m"
                    fi
                else
                    echo -e "$1:\t\033[38;5;165mNo git remote found!\033[0m"
                fi
            else
                echo -e "$1:\t\033[38;5;165mNo .git found!\033[0m"
            fi
        else
            echo "Could not find repository path: $1"
        fi
    }

    # Update dotfiles-public first
    if [ -d "${CODE_DIR}/dotfiles-public" ]; then
        cd ${CODE_DIR}
        update_repo dotfiles-public
        if [ -e "${CODE_DIR}/dotfiles-public/home/sync.sh" ]; then
            if [ "${DO_UPDATE}" = "1" ]; then
                echo "Running dotfiles-public sync script..."
                ${CODE_DIR}/dotfiles-public/home/sync.sh
            fi
        fi
    fi

    for REPO in ${CODE_DIR}/*; do
        cd ${CODE_DIR}
        if [ -d ${REPO} ]; then
            update_repo ${REPO}
        fi
    done

    cd ${ORIGINAL_DIR}
else
    echo "Environment variable \${CODE_DIR} not set or does not exist."
fi

#!/bin/bash

# $PATH management
path_remove() {
    PATH=$(echo -n "$PATH" | awk -v RS=: -v ORS=: "\$0 != \"$1\"" | sed 's/:$//')
}

path_append() {
    path_remove "$1"
    PATH="${PATH:+"$PATH:"}$1"
}

path_prepend() {
    path_remove "$1"
    PATH="$1${PATH:+":$PATH"}"
}

# Update dotfiles
dfu() {
    (
        cd ~/.dotfiles && git pull --ff-only && ./install -q
    )
}

# pull dotfiles, but skip install (useful with only small changes)
# always color for dfp: https://unix.stackexchange.com/a/304025
dfl() {
    (cd ~/dotfiles/dotfiles_pub && git -c color.ui=always pull --ff-only)
    (cd ~/dotfiles/dotfiles_private && git -c color.ui=always pull --ff-only)
}

# push dotfiles to all known gpu hosts (or actually pull on all)
# depend on bin/lsgpu and shell/functions.sh:dfl (this file) on hosts
dfp() {
    gp && lsgpu -c 'source ~/.shell/functions.sh; dfl'
}

# Create a directory and cd into it
mcd() {
    mkdir -p "${1}" && cd "${1}" || return
}

# Use pip without requiring virtualenv
# syspip() {
#     PIP_REQUIRE_VIRTUALENV="" pip "$@"
# }

# syspip2() {
#     PIP_REQUIRE_VIRTUALENV="" pip2 "$@"
# }

# syspip3() {
#     PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
# }

# show repeat lines in file
file_repeat() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 filename"
        return 1
    fi
    local file=$1
    sort "$file" | uniq -c | sort -nr | awk '{ if ($1>1&&NF>1) print $0}' | less
}

# convert CRLF to LF for all files recursively (except '.git/')
CR2LF() {
    find . -not \( -path ./.git -prune \) -type f -exec dos2unix {} \;
}

# print ssh server ip
whereami() {
    echo "$SSH_CONNECTION" | awk '{ print $3 }'
}

conda_pull() {
    if [ "$#" -ne 1 ]; then
        echo "conda_pull: pull ~/.conda folder from host"
        echo "Usage: $0 host"
        return 1
    fi
    local host=$1
    yes | rsync_script "$host": ~/.conda  # rely on ~/.dotfiles/bin
}

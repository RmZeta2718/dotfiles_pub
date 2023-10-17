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
    gp && lsgpu -t 30 -c 'source ~/.shell/functions.sh; dfl'
}

# rs dotfiles from local machine to all hosts
dfs() {
    lsgpu -Tc 'yes | rsync_script ~/dotfiles {host}:'
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
    yes | rsync_script "$host": ~/.conda # rely on ~/.dotfiles/bin
}

# https://stackoverflow.com/a/46071447/17347885
# Print PYthon IMPort Path for a specific module
pyimp() {
    python -c "import $1 as _; print(_.__path__[0])"
}

# remove all files in ckpt directory except runs/ (for tensorboard)
clean_ckpt() {
    # loop over all args except the first one (which is the command name)
    for dir in "${@:1}"; do
        _clean_ckpt "$dir"
    done
}

_clean_ckpt() {
    if [ "$#" -ne 1 ]; then
        echo "_clean_ckpt: remove all files in ckpt directory except runs/ (for tensorboard)"
        echo "Usage: $0 dir"
        return 1
    fi
    dir=$1
    if [ ! -d "$dir/runs" ]; then
        echo "$dir/runs/ not found, so it's not considered as a checkpoint directory"
        return 1
    fi

    # remove anything but $dir/runs/
    echo "rm to be executed in $dir:"
    find "$dir" -mindepth 1 -maxdepth 1 -not -name runs \
        -exec echo rm -rf '{}' \;

    # prompt user for yes/no in zsh
    if ! read -q "choice?Do rm? [y/N] "; then
        echo ""
        echo "Abort"
        return 0
    fi

    echo ""
    echo "Cleaning"
    find "$dir" -mindepth 1 -maxdepth 1 -not -name runs \
        -exec rm -rf '{}' \;
    echo "Done"
}

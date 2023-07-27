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
dfl() {
    (cd ~/dotfiles/dotfiles_pub && git pull --ff-only)
    (cd ~/dotfiles/dotfiles_private && git pull --ff-only)
}

# Create a directory and cd into it
mcd() {
    mkdir -p "${1}" && cd "${1}"
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

there="$HOME/.shell.here"

here() {
    local loc
    if [ "$#" -eq 1 ]; then
        loc=$(realpath "$1")
    else
        loc=$(realpath ".")
    fi
    ln -sfn "${loc}" "$there"
    echo "here -> $(readlink $there)"
}


there() {
    cd "$(readlink "${there}")"
}

# show repeat lines in file
file_repeat() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 filename"
        return 1
    fi
    local file=$1
    cat "$file" | sort | uniq -c | sort -nr | awk '{ if ($1>1&&NF>1) print $0}' | less
}

# convert CRLF to LF for all files recursively (except '.git/')
CR2LF() {
    find . -not \( -path ./.git -prune \) -type f -exec dos2unix {} \;
}

# print ssh server ip
whereami() {
    echo $SSH_CONNECTION | awk '{ print $3 }'
}

# df all file systems except loop and tmpfs, sort by mounted path
dfa() {
    df -h | grep -Ev "loop|tmpfs" | (sed -u 1q; sort -k 6)
}

lsport() {
    # -a : use AND mode
    # -c ^ssh : exclude command ssh* (eg. ssh, sshd)
    # -u ... : specify all user (exclude root and other irrelevant UIDs)
    # -i $@ : allow filtering ports (eg. `lsport :9090`)
    # |& grep -v fuse: ignore stat() fuse error
    # sed; sort : sort by column 3 first (USER), and then by col 9 (port)
    sudo lsof -a -c ^ssh -u $(ls /home | tr '\n' ',') -i $@ |& \
    grep -Ev "can't stat\(\) fuse|Output information may be incomplete." | \
    (sed -u 1q; sort -k 3,3 -k 9)
}

conda_pull() {
    if [ "$#" -ne 1 ]; then
        echo "conda_pull: pull ~/.conda folder from host"
        echo "Usage: $0 host"
        return 1
    fi
    local host=$1
    yes | rsync_script $host: ~/.conda  # use script in ~/.dotfiles/bin
}

# make sudo available for functions and aliases
# https://unix.stackexchange.com/a/438712
# OP is bash, this is adapted to zsh builtins
Sudo() {
    local firstArg=$1
    local argType=$(type -w $firstArg | cut -d ' ' -f 2)
    if [ $argType = function ]; then
        shift && command sudo $SHELL -c "$(declare -f $firstArg);$firstArg $*"
    elif [ $argType = alias ]; then
        alias sudo='\sudo '
        eval "sudo $@"
    else
        command sudo "$@"
    fi
}


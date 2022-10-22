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


#!/bin/bash

######## PATH ########
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

######## dotfiles ########
# for local dotfiles: force update dotfiles to remote (use with caution)
dfu() {
    (
        cd ~/.dotfiles && git fetch && git reset --hard origin/master && ./install -q
    )
}

# for local dotfiles: pull but skip install (useful with only small changes)
dfl() {
    (cd ~/dotfiles/dotfiles_pub && git pull --ff-only)
    (cd ~/dotfiles/dotfiles_private && git pull --ff-only)
}

# for all hosts: force push dotfiles
# depend on bin/mc and shell/functions.sh:dfu (this file) on hosts
dfp() {
    gp && mc -t 30 -c 'source ~/.shell/functions.sh; dfu'
}

# for all hosts: rs dotfiles from local machine without install (useful with only small changes)
dfs() {
    mc -t 5 -Tc 'yes | rsync_script ~/dotfiles/ {host}:'
}

######## python ########
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

######## CUDA ########
# export cuda environ
ce() {
    # check first arg 11.8
    if [ "$#" -ne 1 ]; then
        echo "ce: export cuda environ"
        echo "Usage: $0 11.8"
        return 1

    fi
    if [ ! -d "/usr/local/cuda-$1" ]; then
        echo "ce: /usr/local/cuda-$1 not found"
        return 1
    fi
    echo "export CUDA_HOME=/usr/local/cuda-$1 && export PATH=\$CUDA_HOME/bin:\$PATH && export LD_LIBRARY_PATH=\$CUDA_HOME/lib64:\$LD_LIBRARY_PATH"
    export CUDA_HOME=/usr/local/cuda-$1 && export PATH=$CUDA_HOME/bin:$PATH && export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
}

# grep cuda environ
cg() {
    export | grep -i cuda
}

######## misc ########
# https://unix.stackexchange.com/a/502812
# https://github.com/mikesart/inotify-info
inotify-info() {
    _inotify-info "$@" | less -S
}

# https://www.svlik.com/t/ipapi/
qip() {
    curl -s "https://www.svlik.com/t/ipapi/ip.php?ip=$1" | jq
}

# Create a directory and cd into it
mcd() {
    mkdir -p "${1}" && cd "${1}" || return
}

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

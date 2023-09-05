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
    lsgpu -c 'source ~/.shell/functions.sh; dfl'
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

# du sort by size, with intermediate results
# https://stackoverflow.com/a/6075520
dus() {
    (echo '==========='; du -hd1 "$@") | tee /dev/tty | sort -h
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

# show sshd_config on all nodes
# rely on lsgpu
lssshd() {
    lsgpu -c 'grep --color=always -E "^(PasswordAuthentication|PubkeyAuthentication|PermitRootLogin)" /etc/ssh/sshd_config'
}

# prompt for sudo password and save to variable $password
# scope of prompt_sudo should be limited by () to prevent leaking $password
_prompt_sudo() {
    # mimic sudo prompt
    echo -n "[sudo] password for $USER: "
    read -s password
    echo ""
    # https://serverfault.com/q/967859
    sudo_pswd="echo '$password' | sudo -Sp ''"
}

# change sshd PasswordAuthentication on all nodes
# rely on lsgpu
_sshd_pswd() {
    if [ "$#" -ne 1 ]; then
        echo "_sshd_pswd: change PasswordAuthentication in /etc/ssh/sshd_config"
        echo "Usage: $0 yes|no"
        return 1
    fi
    (  # scope of prompt_sudo
        _prompt_sudo
        lsgpu -c " \
            $sudo_pswd sed -i 's/^PasswordAuthentication.*/PasswordAuthentication $1/' /etc/ssh/sshd_config && \
            $sudo_pswd systemctl restart sshd.service && \
            echo 'PasswordAuthentication set to $1'"
    )
}

# change sshd PubkeyAuthentication to yes on all nodes
sshd_pswd_on() {
    _sshd_pswd yes
}

# change sshd PubkeyAuthentication to no on all nodes
sshd_pswd_off() {
    _sshd_pswd no
}

# rely on lsgpu
create_users_all_nodes() {
    (  # scope of prompt_sudo
        _prompt_sudo
        # run users.sh on all nodes
        lsgpu -c "$sudo_pswd /mnt/public/app/users/users.sh"
    )
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


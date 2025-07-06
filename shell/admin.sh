#!/bin/bash
# functions and aliases for admin uses

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

# change sshd PasswordAuthentication on all nodes
# rely on lsgpu with automatic sudo detection
_sshd_pswd() {
    if [ "$#" -ne 1 ]; then
        echo "_sshd_pswd: change PasswordAuthentication in /etc/ssh/sshd_config"
        echo "Usage: $0 yes|no"
        return 1
    fi
    lsgpu -c "sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication $1/' /etc/ssh/sshd_config \
    && sudo systemctl restart sshd.service \
    && echo 'PasswordAuthentication set to $1'"
}

# change sshd PubkeyAuthentication to yes on all nodes
# rely on lsgpu
sshd_pswd_on() {
    _sshd_pswd yes
}

# change sshd PubkeyAuthentication to no on all nodes
# rely on lsgpu
sshd_pswd_off() {
    _sshd_pswd no
}

# show sshd_config on all nodes
# rely on lsgpu
lsshd() {
    lsgpu -c 'grep --color=always -E "^(PasswordAuthentication|PubkeyAuthentication|PermitRootLogin)" /etc/ssh/sshd_config'
}

lsport() {
    # -w : no warning
    # -a : use AND mode
    # +c0 : display full command
    # -c ^ssh : exclude command ssh* (eg. ssh, sshd)
    # -u ... : specify all user (exclude root and other irrelevant UIDs)
    # -i $@ : allow filtering ports (eg. `lsport :9090`)
    # sed; sort : sort by column 3 first (USER), and then by col 9 (port)
    sudo lsof -wa +c0 -c ^ssh -u "$(ls /home | tr '\n' ',')" -i "$@" |& (
        sed -u 1q
        sort -k 3,3 -k 9
    )
}

# df all file systems except loop and tmpfs, sort by mounted path
dfa() {
    df -h | grep -Ev "loop|tmpfs" | (
        sed -u 1q
        sort -k 6
    )
}

# du sort by size, with intermediate results
# https://stackoverflow.com/a/6075520
dus() {
    (
        echo '==========='
        du -hd1 "$@"
    ) | tee /dev/tty | sort -h
}

# cat log files, in reversed order (recent logs first)
# by Edge copilot
# shellcheck disable=SC2012
clog() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 log_file"
        return 1
    fi
    log_file=$1
    (
        ls -v "${log_file}"* |
            while read -r file; do
                echo "=== file: $file ==="
                if [[ $file == *.gz ]]; then
                    # in reversed order per file, so recent logs are shown first
                    # (files are named by recency, so ls is not reversed)
                    zcat "$file" | tac
                else
                    tac "$file"
                fi
            done
    )
}

# less log files
llog() {
    clog "$@" | less
}

# https://superuser.com/a/1486196
alias iftop="TERM=xterm sudo iftop -Bm 100M"

#!/bin/bash

alias x="xdg-open ."

alias m="make"

alias gh="glods --all"
# tags that contains a specific commit
alias gtc="git tag --sort=creatordate --format='%(creatordate:short) %(refname:short)' --contains"
alias jst="j --stat | less"

alias tm="tmux"
alias cdp="cd -P" # cd to physical path
alias lsgpu="mc -c '/usr/local/anaconda3/bin/gpustat --force-color --gpuname-width 10'"
alias LL="ll -L"

alias ca="conda activate"
alias pip="noglob pip"  # disable parsing [] in pip
alias pip3="noglob pip3"

# WSL
alias pb="clip.exe"
alias wsd="wsl.exe --shutdown"

vs() {
    cs "$@" -- --vs
}

#!/bin/bash

alias x="xdg-open ."

alias m="make"

alias gh="glods --all"
# tags that contains a specific commit
alias gtc="git tag --sort=creatordate --format='%(creatordate:short) %(refname:short)' --contains"
alias jst="j --stat | less"

alias tm="tmux"
alias lsgpu="mc -c '/usr/local/anaconda3/bin/gpustat --force-color --gpuname-width 10'"
alias LL="ll -L"

alias ca="conda activate"

# WSL
alias pb="clip.exe"
alias wsd="wsl.exe --shutdown"

vs() {
    cs "$@" -- --vs
}

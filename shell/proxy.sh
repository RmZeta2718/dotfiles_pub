#!/bin/bash

pg() {
    export | grep proxy
}

po() {
    local ip
    ip=${1:-"127.0.0.1"} # ip=$1, with default value
    if [ "$ip" = "_" ]; then
        ip="127.0.0.1"
    fi
    port=${2:-7890}
    port2=${3:-$((port + 1))}
    # cannot export to https://ip:port, must be http://
    export https_proxy="http://${ip}:${port}" http_proxy="http://${ip}:${port}" all_proxy="socks5://${ip}:${port2}"
}

pof() {
    unset https_proxy http_proxy all_proxy
}

pt() {
    local url
    url=${1:-"www.google.com"}
    curl -I "$url"
}

alias pth="pt https://huggingface.co"

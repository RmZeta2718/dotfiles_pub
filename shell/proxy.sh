#!/bin/bash

pg() {
    export | grep proxy
}

po() {
    local ip
    ip=${1:-"127.0.0.1"} # ip=$1, with default value
    # cannot export to https://ip:port, must be http://
    export https_proxy="http://${ip}:7890" http_proxy="http://${ip}:7890" all_proxy="socks5://${ip}:7891"
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

#!/bin/bash

proxy_grep() {
    export | grep proxy
}

proxy_on() {
    local ip
    ip=${1:-"127.0.0.1"}  # ip=$1, with default value
    # cannot export to https://ip:port, must be http://
    export https_proxy="http://${ip}:7890" http_proxy="http://${ip}:7890" all_proxy="socks5://${ip}:7891"
}

proxy_off() {
    unset https_proxy http_proxy all_proxy
}

alias proxy_test="curl -I google.com"


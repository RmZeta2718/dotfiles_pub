#!/bin/bash

# This script runs $cmd on each of the $hosts and print output
# By default cmd=gpustat and hosts are all hostnames that begins with g

cmd='/usr/local/anaconda3/bin/gpustat --force-color'

hosts=$(sed -rn 's/^\s*Host\s+(.*)\s*/\1/ip' ~/.ssh/config* | grep 'g')
# config* for config and config_local on my machine

for host in $hosts; do
    echo "host $host:"
    ssh $host $cmd 2>&1 # merge stdout&stderr
done

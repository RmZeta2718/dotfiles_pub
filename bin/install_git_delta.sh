#!/bin/bash

set -e

# Specify the URL of the .deb file to download
deb_url="https://github.com/dandavison/delta/releases/download/0.16.5/git-delta_0.16.5_amd64.deb"

# Specify the desired filename for the downloaded .deb file
deb_file="$HOME/$(basename "$deb_url")"

if [ ! -f "$deb_file" ]; then
    wget "$deb_url" -O "$deb_file"
else
    echo "Using existing $deb_file"
fi

sudo dpkg -i "$deb_file"
rm "$deb_file"

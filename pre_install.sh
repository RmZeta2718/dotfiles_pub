#!/bin/bash
# works in ubuntu linux

set -e    # Exit immediately if a command exits with a non-zero status.

if [ -f "$(which zsh)" ]; then
    # zsh is found, silent
    :
else
    echo "zsh not found, installing..."
    yes | sudo apt install zsh
fi

if [ "$(basename -- "$SHELL")" = "zsh" ]; then
    echo "Already using zsh as default shell."
else
    echo 'Changing default shell to zsh.'
    chsh -s "$(which zsh)"
fi


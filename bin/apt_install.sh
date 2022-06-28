#!/bin/bash
# works in ubuntu linux

# adapt from https://github.com/ohmyzsh/ohmyzsh/blob/master/tools/install.sh
command_exists() {
  command -v "$@" >/dev/null 2>&1
}
not_sudoer() {
  # The following command has 3 parts:
  #
  # 1. Run `sudo` with `-v`. Does the following:
  #    • with privilege: asks for a password immediately.
  #    • without privilege: exits with error code 1 and prints the message:
  #      Sorry, user <username> may not run sudo on <hostname>
  #
  # 2. Pass `-n` to `sudo` to tell it to not ask for a password. If the
  #    password is not required, the command will finish with exit code 0.
  #    If one is required, sudo will exit with error code 1 and print the
  #    message:
  #    sudo: a password is required
  #
  # 3. Check for the words "may not run sudo" in the output to really tell
  #    whether the user has privileges or not. For that we have to make sure
  #    to run `sudo` in the default locale (with `LANG=`) so that the message
  #    stays consistent regardless of the user's locale.
  #
  LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}

if ! command_exists apt-get; then
    # apt-get unavailable
    exit 0
fi

if ! command_exists sudo; then
    echo "sudo unavailable"
    exit 1
fi

if not_sudoer; then
    echo "No sudo permission, skipping apt install"
    exit 1
fi

packages=(
    zsh
    git
    tree
    htop
    python3
    # https://linuxpip.org/python-is-python3/
    python-is-python3  # ubuntu has python2 by default before 20.04
)

# Update the list of available packages and versions
sudo apt-get update -qq

for pkg in "${packages[@]}"; do
    sudo apt-get install -qq "$pkg"
done


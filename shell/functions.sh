# $PATH management
path_remove() {
    PATH=$(echo -n "$PATH" | awk -v RS=: -v ORS=: "\$0 != \"$1\"" | sed 's/:$//')
}

path_append() {
    path_remove "$1"
    PATH="${PATH:+"$PATH:"}$1"
}

path_prepend() {
    path_remove "$1"
    PATH="$1${PATH:+":$PATH"}"
}

# Update dotfiles
dfu() {
    (
        cd ~/.dotfiles && git pull --ff-only && ./install -q
    )
}

# Create a directory and cd into it
mcd() {
    mkdir -p "${1}" && cd "${1}"
}

# Use pip without requiring virtualenv
# syspip() {
#     PIP_REQUIRE_VIRTUALENV="" pip "$@"
# }

# syspip2() {
#     PIP_REQUIRE_VIRTUALENV="" pip2 "$@"
# }

# syspip3() {
#     PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
# }

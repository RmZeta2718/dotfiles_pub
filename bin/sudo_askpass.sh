#!/bin/sh
# This script is used as a sudo askpass program.
# It reads the sudo password from the environment variable SUDO_PASS
# and prints it to stdout.

printf "%s" "$SUDO_PASS"

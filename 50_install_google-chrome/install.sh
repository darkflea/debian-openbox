#!/bin/bash
# ACTION: Install Google Chrome, add to repositories and set has default browser
# INFO: Google Chrome is most popular web browser
# INFO: Its recommended config official repositories for weekly updates
# DEFAULT: y

# Check root
[ "$(id -u)" -ne 0 ] && { echo "Must run as root" 1>&2; exit 1; }

# Note: On Arch, Google Chrome is in the AUR. 
# This script assumes an AUR helper like 'yay' or manual build is used.
if ! command -v google-chrome &> /dev/null; then
    echo -e "\e[1mGoogle Chrome not found. Please install 'google-chrome' from the AUR.\e[0m"
fi

# Set as default
echo -e "\e[1mSetting as default alternative...\e[0m"
command -v google-chrome &>/dev/null && ln -sf /usr/bin/google-chrome /usr/bin/x-www-browser

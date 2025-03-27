#!/bin/bash
# ACTION: Install Microsoft Edge, add to repositories, and set as default browser
# INFO: Microsoft Edge is a fast and secure web browser
# INFO: It's recommended to configure official repositories for updates
# DEFAULT: y

# Check root
[ "$(id -u)" -ne 0 ] && { echo "Must run as root" 1>&2; exit 1; }

# Install repositories and update
if ! grep -R "packages.microsoft.com/repos/edge" /etc/apt/ &> /dev/null; then
	echo -e "\e[1mConfiguring repositories...\e[0m"
	wget -qO - "https://packages.microsoft.com/keys/microsoft.asc" | gpg --dearmor --yes -o /usr/share/keyrings/microsoft-edge-keyring.gpg
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge-keyring.gpg] https://packages.microsoft.com/repos/edge stable main" | tee /etc/apt/sources.list.d/microsoft-edge.list
	apt-get update
fi

# Install package
echo -e "\e
apt update
apt install microsoft-edge-stable -y
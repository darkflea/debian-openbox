#!/bin/bash
# ACTION: Install VirtualBox Guest Additions from Oracle
# INFO: VirtualBox Guest Additions is a bundle of device drivers and system applications installed inside a virtual machine to improve performance, graphics, and usability.
# DEFAULT: n

# Check system run on VirtualBox VM
if [ "$(systemd-detect-virt)" != "oracle" ]; then
  echo "ERROR: Current system not running on VirtualBox guest VM" 1>&2
  exit 1
fi

echo -e "\e[1mVirtualBox guest detected. Installing Guest Additions...\e[0m"
pacman -S --noconfirm virtualbox-guest-utils
systemctl enable --now vboxservice.service

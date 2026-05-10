#!/bin/bash
# ACTION: Install VirtualBox and Extension Pack from Oracle and add to repositories
# INFO: VirtualBox is a free opensource hosted hypervisor
# DEFAULT: n

# Check root
[ "$(id -u)" -ne 0 ] && { echo "Must run as root" 1>&2; exit 1; }

# On Arch, VirtualBox is in the official 'extra' repository.
echo -e "\e[1mInstalling VirtualBox packages...\e[0m"
pacman -S --noconfirm virtualbox virtualbox-host-dkms linux-headers

# Add VirtualBox in OpenBox menu:
echo -e "\n\e[1mAdding Openbox menu entry...\e[0m"
for d in /etc/skel/  /home/*/ ; do
	f="$d/.config/openbox/menu.xml"
	[ ! -f "$f" ] && continue
	! grep -q '<command>virtualbox<\/command>' "$f" && sed -i '0,/<separator\/>/s//<separator\/> <item label="VirtualBox" icon="\/usr\/share\/icons\/openbox-menu\/virtualbox.png"><action name="Execute"><command>virtualbox<\/command><\/action><\/item> /' "$f"
done


# Check if virtualbox is installed
if ! which vboxmanage &> /dev/null; then
  echo "VirtualBox is not installed"
  exit 1
fi

# Install extension pack
echo -e "\n\e[1mDownloading and installing Extension Pack ${vb_version} ...\e[0m"
vb_version=$(vboxmanage --version | cut -d'r' -f1)
ep_url="https://download.virtualbox.org/virtualbox/${vb_version}/Oracle_VirtualBox_Extension_Pack-${vb_version}.vbox-extpack"
t=$(mktemp -d)
wget -P "$t" "$ep_url"  
[ $? -eq 0 ] && yes | vboxmanage extpack install --replace "$t"/*extpack 
rm -rf "$t"

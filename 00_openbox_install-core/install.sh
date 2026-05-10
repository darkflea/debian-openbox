#!/bin/bash
# ACTION: Install Openbox WM and essential tools and configs
# INFO: Openbox is a lightweight window manager, but needs some additional tools and configs for make it usable
# DEFAULT: y

# Config variables
base_dir="$(dirname "$(readlink -f "$0")")"

# Check root
[ "$(id -u)" -ne 0 ] && { echo "Must run as root" 1>&2; exit 1; }

# Install packages
echo -e "\n\e[1mInstalling packages...\e[0m"
pacman -S --noconfirm xorg-server xorg-xinit xorg-utils xorg-server-utils xorg-xkbutils xterm dbus polkit
pacman -S --noconfirm xdg-utils xdg-user-dirs xdg-desktop-portal xdg-desktop-portal-gtk shared-mime-info desktop-file-utils
pacman -S --noconfirm openbox obconf lxappearance picom xfce4-clipman-plugin xfce4-power-manager upower arandr gsimplecal xcape file-roller xautomation yad inxi
pacman -S --noconfirm libcanberra adwaita-icon-theme gsettings-desktop-schemas
pacman -S --noconfirm networkmanager nm-connection-editor wpa_supplicant
systemctl disable NetworkManager-wait-online.service 2>/dev/null

# Installing graphics drivers
echo -e "\n\e[1mInstalling graphics drivers...\e[0m"
if systemd-detect-virt -q; then
    virt=$(systemd-detect-virt)
    case "$virt" in
        oracle) 	gpu_pkgs=""    						 ;;
        vmware) 	gpu_pkgs="xf86-video-vmware"         ;;
        qemu|kvm)   gpu_pkgs="xf86-video-qxl"            ;;
        *)          gpu_pkgs="xf86-video-fbdev"          ;;
    esac
else
	gpu="$(lspci -nn | grep -Ei 'vga|3d|display')"
    if echo "$gpu" | grep -qi intel; then
        gpu_pkgs="xf86-video-intel"
    elif echo "$gpu" | grep -Eqi "amd|radeon"; then
        gpu_pkgs="xf86-video-amdgpu"
    elif echo "$gpu" | grep -qi nvidia; then
        pacman -Qs nvidia &>/dev/null && gpu_pkgs="nvidia" || gpu_pkgs="xf86-video-nouveau"
    else
        gpu_pkgs="xf86-video-fbdev"
    fi
fi
pacman -S --noconfirm $gpu_pkgs

echo -e "\n\e[1mCopying themes and tools...\e[0m"
# Copy theme
tar -xzvf "$base_dir"/openbox_theme.tgz -C /usr/share/themes/ || true

# Install help docs
d="help"
cp -rv "$base_dir/$d" "/usr/share/doc/openbox/"

# Install system info dependences
wget -P /usr/bin "https://raw.githubusercontent.com/pixelb/ps_mem/master/ps_mem.py" && chmod a+x /usr/bin/ps_mem.py
sed -i 's/#\!\/usr\/bin\/env python/#\!\/usr\/bin\/env python3/g' /usr/bin/ps_mem.py
wget -P /usr/bin "https://raw.githubusercontent.com/aristocratos/bashtop/master/bashtop" && chmod a+x /usr/bin/bashtop
pacman -S --noconfirm s-tui dfc htop hwinfo

# Copy cups-session
cp -v ${base_dir}/cups-session /usr/bin
chmod a+x /usr/bin/cups-session
# Copy bt-session
cp -v ${base_dir}/bt-session /usr/bin
chmod a+x /usr/bin/bt-session
# Copy welcome
cp -v ${base_dir}/welcome /usr/bin
chmod a+x /usr/bin/welcome
cp -v ${base_dir}/welcome.desktop /usr/share/applications/

# Copy users config
echo -e "\n\e[1mSetting configs to all users...\e[0m"
for d in /etc/skel /home/*/ /root; do
    [ "$(dirname "$d")" = "/home" ] && ! id "$(basename "$d")" &>/dev/null && continue	# Skip dirs that no are homes

	# Create config folder if no exists
	d="$d/.config/"; [ ! -d "$d" ] && mkdir -v "$d" && chown -R $(stat "$(dirname "$d")" -c %u:%g) "$d"
	
	# Copy compton file
	f="compton.conf"
	cp -v "$base_dir/$f" "$d" && chown -R $(stat "$d" -c %u:%g) "$d/$f"	
	# Copy mimeapps.list file
	f="mimeapps.list"
	cp -v "$base_dir/$f" "$d" && chown -R $(stat "$d" -c %u:%g) "$d/$f"	
	
	# Create config folders if no exists
	d2="$d"
	d="$d/openbox/";  [ ! -d "$d" ] && mkdir -v "$d" && chown -R $(stat "$(dirname "$d")" -c %u:%g) "$d"

	# Copy openbox config file
	f="rc.xml"
	cp -v "$base_dir/$f" "$d" && chown -R $(stat "$d" -c %u:%g) "$d/$f"
	# Copy openbox autostart file
	f="autostart"
	cp -v "$base_dir/$f" "$d" && chown -R $(stat "$d" -c %u:%g) "$d/$f"
	# Copy openbox menu file
	f="menu.xml"
	cp -v "$base_dir/$f" "$d" && chown -R $(stat "$d" -c %u:%g) "$d/$f"	
	# Delete bluetooth item from menu if no BT present
	dmesg | grep -qi bluetooth || sed -i '/DEBIAN-OPENBOX-bluetooth/Id' "$d/$f"	
	# Create welcome link
	ln -s /usr/bin/welcome "$d/welcome"
	
	# Copy fonts.conf
	d="$d2/fontconfig/";  [ ! -d "$d" ] && mkdir -v "$d" && chown -R $(stat "$(dirname "$d")" -c %u:%g) "$d"
	f="fonts.conf"
	cp -v "$base_dir/$f" "$d" && chown -R $(stat "$d" -c %u:%g) "$d/$f"

done


# Set as default
echo -e "\n\e[1mSetting as default alternative...\e[0m"
# Arch compatibility layer (manual symlinks)
ln -sf /usr/bin/openbox-session /usr/bin/x-session-manager
ln -sf /usr/bin/terminator /usr/bin/x-terminal-emulator
ln -sf /usr/bin/thunar /usr/bin/x-file-manager
ln -sf /usr/bin/vim /usr/bin/x-text-editor

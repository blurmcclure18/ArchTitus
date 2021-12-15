#!/usr/bin/env bash
#-------------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗████████╗██╗████████╗██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║╚══██╔══╝██║╚══██╔══╝██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║   ██║   ██║   ██║   ██║   ██║███████╗
#  ██╔══██║██╔══██╗██║     ██╔══██║   ██║   ██║   ██║   ██║   ██║╚════██║
#  ██║  ██║██║  ██║╚██████╗██║  ██║   ██║   ██║   ██║   ╚██████╔╝███████║
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
#-------------------------------------------------------------------------
echo "--------------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager
echo "-------------------------------------------------"
echo "Setting up mirrors for optimal download          "
echo "-------------------------------------------------"
pacman -S --noconfirm pacman-contrib curl
pacman -S --noconfirm reflector rsync
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -gt 8000000 ]]; then
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf
fi
echo "-------------------------------------------------"
echo "       Setup Language to US and set locale       "
echo "-------------------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone America/Chicago
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8"

# Set keymaps
localectl --no-ask-password set-keymap us

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

#Add parallel downloading
sed -i 's/^#Para/Para/' /etc/pacman.conf

#Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

read -p $'\nDesktop Environments:\n 1.Gnome\n 2.KDE\n 3.LxQT\n 4.XFCE\nPlease select a Desktop Environment:' desktopenv
echo "desktopenv=$desktopenv" >> ${HOME}/ArchTitus/desktopenv.conf

if [[ $desktopenv -eq 1 ]]
then
    echo $'\nYou chose Gnome as your Desktop Environment'
elif [[ $desktopenv -eq 2 ]]
then
	echo $'\nYou chose KDE as your Desktop Environment'
elif [[ $desktopenv -eq 4 ]]
then
    echo $'\nYou chose XFCE as your Desktop Environment'
else
    echo $'\nYou chose LxQT as your Desktop Environment'
fi

read -p $'\nPress Enter to Continue...'

echo -e "\nInstalling Base System\n"

GNOMEPKGS=(
	'mesa' # Essential Xorg First
	'xorg'
	'xorg-server'
	'xorg-apps'
	'xorg-drivers'
	'xorg-xkill'
	'xorg-xinit'
	'alsa-plugins' # audio plugins
	'alsa-utils' # audio utils
	'autoconf' # build
	'automake' # build
	'base'
	'bash-completion'
	'baobab'
	'bind'
	'binutils'
	'bison'
	'bluez'
	'bluez-libs'
	'bluez-utils'
	'bridge-utils'
	'btrfs-progs'
	'celluloid' # video players
	'cmatrix'
	'code' # Visual Studio code
	'cronie'
	'cups'
	'dconf'
	'dialog'
	'discord'
	'dosfstools'
	'dtc'
	'efibootmgr' # EFI boot
	'egl-wayland'
	'exfat-utils'
	'extra-cmake-modules'
	'flex'
	'fuse2'
	'fuse3'
	'fuseiso'
	'gamemode'
	'gcc'
	'gdm'
	'git'
	'gnome'
	'gnome-backgrounds'
	'gnome-boxes'
	'gnome-passwordsafe'
	'gnome-shell-extensions'
	'gnome-tweaks'
	'gparted' # partition management
	'gptfdisk'
	'grub'
	'grub-customizer'
	'gst-libav'
	'gst-plugins-good'
	'gst-plugins-ugly'
	'haveged'
	'htop'
	'iptables-nft'
	'layer-shell-qt'
	'libdvdcss'
	'libnewt'
	'libtool'
	'linux'
	'linux-firmware'
	'linux-headers'
	'lsof'
	'lutris'
	'lzop'
	'm4'
	'make'
	'nano'
	'neofetch'
	'networkmanager'
	'ntfs-3g'
	'ntp'
	'openbsd-netcat'
	'openssh'
	'os-prober'
	'p7zip'
	'pacman-contrib'
	'patch'
	'picom'
	'pkgconf'
	'powerline-fonts'
	'pulseaudio'
	'pulseaudio-alsa'
	'pulseaudio-bluetooth'
	'python-notify2'
	'python-psutil'
	'python-pyqt5'
	'python-pip'
	'rsync'
	'sddm'
	'steam'
	'sudo'
	'swtpm'
	'terminus-font'
	'traceroute'
	'ufw'
	'unrar'
	'unzip'
	'usbutils'
	'wget'
	'which'
	'wine-gecko'
	'wine-mono'
	'winetricks'
	'xdg-desktop-portal-gnome'
	'xdg-user-dirs'
	'xfce4-terminal'
	'zeroconf-ioslave'
	'zip'
	'zsh'
	'zsh-syntax-highlighting'
	'zsh-autosuggestions'
)

KDEPKGS=(
	'mesa' # Essential Xorg First
	'xorg'
	'xorg-server'
	'xorg-apps'
	'xorg-drivers'
	'xorg-xkill'
	'xorg-xinit'
	'xterm'
	'plasma-desktop' # KDE Load second
	'alsa-plugins' # audio plugins
	'alsa-utils' # audio utils
	'ark' # compression
	'audiocd-kio' 
	'autoconf' # build
	'automake' # build
	'base'
	'bash-completion'
	'bind'
	'binutils'
	'bison'
	'bluedevil'
	'bluez'
	'bluez-libs'
	'bluez-utils'
	'breeze'
	'breeze-gtk'
	'bridge-utils'
	'btrfs-progs'
	'celluloid' # video players
	'cmatrix'
	'code' # Visual Studio code
	'cronie'
	'cups'
	'dialog'
	'discover'
	'dolphin'
	'dosfstools'
	'dtc'
	'efibootmgr' # EFI boot
	'egl-wayland'
	'exfat-utils'
	'extra-cmake-modules'
	'filelight'
	'flex'
	'fuse2'
	'fuse3'
	'fuseiso'
	'gamemode'
	'gcc'
	'gimp' # Photo editing
	'git'
	'gparted' # partition management
	'gptfdisk'
	'grub'
	'grub-customizer'
	'gst-libav'
	'gst-plugins-good'
	'gst-plugins-ugly'
	'gwenview'
	'haveged'
	'htop'
	'iptables-nft'
	'jdk-openjdk' # Java 17
	'kate'
	'kcodecs'
	'kcoreaddons'
	'kdeplasma-addons'
	'kde-gtk-config'
	'kinfocenter'
	'kscreen'
	'kvantum-qt5'
	'kitty'
	'konsole'
	'kscreen'
	'layer-shell-qt'
	'libdvdcss'
	'libnewt'
	'libtool'
	'linux'
	'linux-firmware'
	'linux-headers'
	'lsof'
	'lutris'
	'lzop'
	'm4'
	'make'
	'milou'
	'nano'
	'neofetch'
	'networkmanager'
	'ntfs-3g'
	'ntp'
	'okular'
	'openbsd-netcat'
	'openssh'
	'os-prober'
	'oxygen'
	'p7zip'
	'pacman-contrib'
	'patch'
	'picom'
	'pkgconf'
	'plasma-meta'
	'plasma-nm'
	'powerdevil'
	'powerline-fonts'
	'print-manager'
	'pulseaudio'
	'pulseaudio-alsa'
	'pulseaudio-bluetooth'
	'python-notify2'
	'python-psutil'
	'python-pyqt5'
	'python-pip'
	'qemu'
	'rsync'
	'sddm'
	'sddm-kcm'
	'snapper'
	'spectacle'
	'steam'
	'sudo'
	'swtpm'
	'synergy'
	'systemsettings'
	'terminus-font'
	'traceroute'
	'ufw'
	'unrar'
	'unzip'
	'usbutils'
	'vim'
	'virt-manager'
	'virt-viewer'
	'wget'
	'which'
	'wine-gecko'
	'wine-mono'
	'winetricks'
	'xdg-desktop-portal-kde'
	'xdg-user-dirs'
	'zeroconf-ioslave'
	'zip'
	'zsh'
	'zsh-syntax-highlighting'
	'zsh-autosuggestions'
)

LXQTPKGS=(
	'mesa' # Essential Xorg First
	'xorg'
	'xorg-server'
	'xorg-apps'
	'xorg-drivers'
	'xorg-xkill'
	'xorg-xinit'
	'alsa-plugins' # audio plugins
	'alsa-utils' # audio utils
	'autoconf' # build
	'automake' # build
	'base'
	'bash-completion'
	'baobab'
	'bind'
	'binutils'
	'bison'
	'bluez'
	'bluez-libs'
	'bluez-utils'
	'bridge-utils'
	'btrfs-progs'
	'celluloid' # video players
	'cmatrix'
	'code' # Visual Studio code
	'cronie'
	'cups'
	'dconf'
	'dialog'
	'discord'
	'dosfstools'
	'dtc'
	'efibootmgr' # EFI boot
	'egl-wayland'
	'exfat-utils'
	'extra-cmake-modules'
	'firefox'
	'flex'
	'fuse2'
	'fuse3'
	'fuseiso'
	'gamemode'
	'gcc'
	'git'
	'gparted' # partition management
	'gptfdisk'
	'grub'
	'grub-customizer'
	'gst-libav'
	'gst-plugins-good'
	'gst-plugins-ugly'
	'haveged'
	'htop'
	'iptables-nft'
	'layer-shell-qt'
	'libdvdcss'
	'libnewt'
	'libtool'
	'libvirt'
	'linux'
	'linux-firmware'
	'linux-headers'
	'lsof'
	'lutris'
	'lzop'
	'lxqt'
	'm4'
	'make'
	'midori'
	'nano'
	'nautilus'
	'neofetch'
	'networkmanager'
	'ntfs-3g'
	'ntp'
	'openbsd-netcat'
	'openssh'
	'os-prober'
	'p7zip'
	'pacman-contrib'
	'patch'
	'picom'
	'pkgconf'
	'powerline-fonts'
	'pulseaudio'
	'pulseaudio-alsa'
	'pulseaudio-bluetooth'
	'python-notify2'
	'python-psutil'
	'python-pyqt5'
	'python-pip'
	'rsync'
	'sddm'
	'steam'
	'sudo'
	'swtpm'
	'terminus-font'
	'traceroute'
	'ufw'
	'unrar'
	'unzip'
	'usbutils'
	'wget'
	'which'
	'wine-gecko'
	'wine-mono'
	'winetricks'
	'xdg-user-dirs'
	'xfce4-terminal'
	'zeroconf-ioslave'
	'zip'
	'zsh'
	'zsh-syntax-highlighting'
	'zsh-autosuggestions'
)

XFCEPKGS=(
	'mesa' # Essential Xorg First
	'xorg'
	'xorg-server'
	'xorg-apps'
	'xorg-drivers'
	'xorg-xkill'
	'xorg-xinit'
	'alsa-plugins' # audio plugins
	'alsa-utils' # audio utils
	'autoconf' # build
	'automake' # build
	'base'
	'bash-completion'
	'baobab'
	'bind'
	'binutils'
	'bison'
	'bluez'
	'bluez-libs'
	'bluez-utils'
	'bridge-utils'
	'btrfs-progs'
	#'celluloid' # video players
	'cmatrix'
	#'code' # Visual Studio code
	'cronie'
	'cups'
	'dconf'
	'dialog'
	#'discord'
	'dosfstools'
	'dtc'
	'efibootmgr' # EFI boot
	'egl-wayland'
	'exfat-utils'
	'extra-cmake-modules'
	'firefox'
	'flex'
	'fuse2'
	'fuse3'
	'fuseiso'
	#'gamemode'
	'gcc'
	'git'
	'gparted' # partition management
	'gptfdisk'
	'grub'
	'grub-customizer'
	'gst-libav'
	'gst-plugins-good'
	'gst-plugins-ugly'
	'haveged'
	'htop'
	'iptables-nft'
	'layer-shell-qt'
	'libdvdcss'
	'libnewt'
	'libtool'
	'libvirt'
	'linux'
	'linux-firmware'
	'linux-headers'
	'lsof'
	'lutris'
	'lzop'
	'm4'
	'make'
	'midori'
	'nano'
	'nautilus'
	'neofetch'
	'networkmanager'
	'ntfs-3g'
	'ntp'
	'openbsd-netcat'
	'openssh'
	'os-prober'
	'p7zip'
	'pacman-contrib'
	'patch'
	'picom'
	'pkgconf'
	'powerline-fonts'
	'pulseaudio'
	'pulseaudio-alsa'
	'pulseaudio-bluetooth'
	'python-notify2'
	'python-psutil'
	'python-pyqt5'
	'python-pip'
	'rsync'
	'sddm'
	#'steam'
	'sudo'
	'swtpm'
	'terminus-font'
	'traceroute'
	'ufw'
	'unrar'
	'unzip'
	'usbutils'
	'wget'
	'which'
	'wine-gecko'
	'wine-mono'
	'winetricks'
	'xdg-user-dirs'
	'xfce4'
	'xfce4-terminal'
	'zeroconf-ioslave'
	'zip'
	'zsh'
	'zsh-syntax-highlighting'
	'zsh-autosuggestions'
)

BOTHPKGS=(
	'mesa' # Essential Xorg First
	'xorg'
	'xorg-server'
	'xorg-apps'
	'xorg-drivers'
	'xorg-xkill'
	'xorg-xinit'
	'xterm'
	'plasma-desktop' # KDE Load second
	'alsa-plugins' # audio plugins
	'alsa-utils' # audio utils
	'ark' # compression
	'audiocd-kio' 
	'autoconf' # build
	'automake' # build
	'base'
	'bash-completion'
	'baobab'
	'bind'
	'binutils'
	'bison'
	'bluedevil'
	'bluez'
	'bluez-libs'
	'bluez-utils'
	'breeze'
	'breeze-gtk'
	'bridge-utils'
	'btrfs-progs'
	'celluloid' # video players
	'cmatrix'
	'code' # Visual Studio code
	'cronie'
	'cups'
	'dconf'
	'dialog'
	'discord'
	'discover'
	'dolphin'
	'dosfstools'
	'dtc'
	'efibootmgr' # EFI boot
	'egl-wayland'
	'exfat-utils'
	'extra-cmake-modules'
	'filelight'
	'flex'
	'fuse2'
	'fuse3'
	'fuseiso'
	'gamemode'
	'gcc'
	'gdm'
	'gimp'
	'git'
	'gnome'
	'gnome-boxes'
	'gnome-passwordsafe'
	'gnome-shell-extensions'
	'gnome-tweaks'
	'gparted' # partition management
	'gptfdisk'
	'grub'
	'grub-customizer'
	'gst-libav'
	'gst-plugins-good'
	'gst-plugins-ugly'
	'gwenview'
	'haveged'
	'htop'
	'iptables-nft'
	'jdk-openjdk' # Java 17
	'kate'
	'kcodecs'
	'kcoreaddons'
	'kdeplasma-addons'
	'kde-gtk-config'
	'kinfocenter'
	'kscreen'
	'kvantum-qt5'
	'konsole'
	'kscreen'
	'layer-shell-qt'
	'libdvdcss'
	'libnewt'
	'libtool'
	'linux'
	'linux-firmware'
	'linux-headers'
	'lsof'
	'lutris'
	'lzop'
	'm4'
	'make'
	'milou'
	'nano'
	'neofetch'
	'networkmanager'
	'ntfs-3g'
	'ntp'
	'okular'
	'openbsd-netcat'
	'openssh'
	'os-prober'
	'oxygen'
	'p7zip'
	'pacman-contrib'
	'patch'
	'picom'
	'pkgconf'
	'plasma-meta'
	'plasma-nm'
	'powerdevil'
	'powerline-fonts'
	'print-manager'
	'pulseaudio'
	'pulseaudio-alsa'
	'pulseaudio-bluetooth'
	'python-notify2'
	'python-psutil'
	'python-pyqt5'
	'python-pip'
	'qemu'
	'rsync'
	'sddm'
	'sddm-kcm'
	'snapper'
	'spectacle'
	'steam'
	'sudo'
	'swtpm'
	'synergy'
	'systemsettings'
	'terminus-font'
	'traceroute'
	'ufw'
	'unrar'
	'unzip'
	'usbutils'
	'vim'
	'virt-manager'
	'virt-viewer'
	'wget'
	'which'
	'wine-gecko'
	'wine-mono'
	'winetricks'
	'xdg-desktop-portal-gnome'
	'xdg-desktop-portal-kde'
	'xdg-user-dirs'
	'xfce4-terminal'
	'zeroconf-ioslave'
	'zip'
	'zsh'
	'zsh-syntax-highlighting'
	'zsh-autosuggestions'
)

if [[ $desktopenv -eq 1 ]]
then
    PKGS=("${GNOMEPKGS[@]}")
elif [[ $desktopenv -eq 2 ]]
then
    PKGS=("${KDEPKGS[@]}")
elif [[ $desktopenv -eq 4 ]]
then
    PKGS=("${XFCEPKGS[@]}")
else
    PKGS=("${LXQTPKGS[@]}")
fi

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

#
# determine processor type and install microcode
# 
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		print "Installing Intel microcode"
		pacman -S --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		print "Installing AMD microcode"
		pacman -S --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac	

# Graphics Drivers find and install
if lspci | grep -E "NVIDIA|GeForce"; then
    pacman -S nvidia --noconfirm --needed
	nvidia-xconfig
elif lspci | grep -E "Radeon"; then
    pacman -S xf86-video-amdgpu --noconfirm --needed
elif lspci | grep -E "Integrated Graphics Controller"; then
    pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

echo -e "\nDone!\n"
if ! source install.conf; then
	read -p "Please enter username(Must Be lowercase!):" username
echo "username=$username" >> ${HOME}/ArchTitus/install.conf
fi
if [ $(whoami) = "root"  ];
then
    useradd -m -G wheel,libvirt -s /bin/bash $username 
	passwd $username
	cp -R /root/ArchTitus /home/$username/
    chown -R $username: /home/$username/ArchTitus
	read -p "Please name your machine:" nameofmachine
	echo $nameofmachine > /etc/hostname
else
	echo "You are already a user proceed with aur installs"
fi
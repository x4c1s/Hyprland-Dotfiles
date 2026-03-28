#!/bin/bash


sudo pacman -Syu

echo "[*] Installing core packages"
sudo pacman -S NetworkManager dunst ly firewalld discord libnotify fastfetch ttd-iosevka-nerd quickshell fzf hyprlock hyprshot exa fd ripgrep bat pcmanfm  make cmake hyprland wayland pipewire ghostty swww rofi pavucontrol pulseaudio mpv feh maim dbus wl-clipboard tmux docker docker-compose rust go cargo uv python3 doas openvpn net-tools 7zip zip netcat socat wget curl spotify zoxide octopi cuda nvidia-settings nvidia-utils opencl-nvidia bore  grex protonvpn keepassxc flameshot power-profiles-daemon flatpak pass

flatpak install flathub com.stremio.Stremio

echo "[*] Building yay"
git clone https://aur.archlinux.org/yay.git && cd yay && sudo makepkg -si


echo "[*] Installing yay packges"
yay -S librewolf-bin xwaylandvideobridge croc ttyd stremio satty


echo "[*] Adding the blackarch repo"
mkdir -p $HOME/Downloads
sudo curl -o $HOME/Downloads/strap.sh https://blackarch.org/strap.sh
sudo chmod +x $HOME/Downloads/strap.sh
sudo $HOME/Downloads/strap.sh
sudo pacman -Syu


echo "[*] Downloading Wallpapers"
curl -LJ https://github.com/JaKooLit/Wallpaper-Bank/archive/refs/heads/main.zip -o $HOME/Downloads/main.zip 2>&1
unzip $HOME/Downloads/main.zip -d $HOME

echo "[*] Setting up rofi"
mkdir -p ~/.config/rofi
cp rofi/* ~/.config/rofi

echo "[*] Setting up swaync"
mkdir -p ~/.config/swaync
cp swaync/style.css ~/.config/swaync

echo "[*] Setting up tmux"
mkdir -p ~/.config/tmux
cp tmux/tmux.conf ~/.config/tmux

echo "[*] Setting up ghostty"
cp -r ghostty ~/.config/

echo "[*] Setting up hyprlock"
cp -r hyprlock ~/.config/

echo "[*] Setting up hyprland"
mkdir -p ~/.config/hypr 
cp  hyprland/* ~/.config/hypr

echo "[*] Setting up quickshell"
cp -r quickshell ~/.config/

echo "[*] Setting up ly"
sudo mkdir -p /etc/ly
sudo cp ly/config.ini /etc/ly/config.ini


echo "[*] Setting up desktop manager"
sudo systemctl disable getty@tty2.service
sudo systemctl enable ly@tty2.service


echo "[*] Setting up firewall"
sudo systemctl enable firewalld


echo "[*] Reboot Required. Reboot Now? [Y/n]"
read -r bool

case "$bool" in
    y|Y)
        echo "[*] Rebooting..."
        systemctl reboot
        ;;
    *)
        exit 0
        ;;
esac





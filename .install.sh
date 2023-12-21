#!/bin/bash

echo "The following script assumes you've already got a basic Arch Linux installation with AwesomeWM and Grub installed either manually or through something like archinstall. If you do not, this script may fail or produce unexecpted results."

read -p "Continue? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

# Install yay
echo "Installing yay..."
pacman -S --needed git base-devel
git clone  https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay

# Install packages
echo "Installing packages..."
pacman -S neofetch neovim wezterm onefetch lightdm lightdm-webkit2-greeter lightdm-webkit-theme-litarvan luarocks lua man-pages man-db nodejs networkmanager npm unzip upower ueberzugpp obs-studio clang flameshot feh accountsservice pamixer imagemagick
yay -S joshuto onedrive-abraunegg discord librewolf-bin

# Install configuration
echo "Installing configuration..."
git clone https://github.com/neph-iap/dotfiles.git
cd dotfiles
cp -R * ~/

# Enable services
echo "Enabling services..."
sudo systemctl enable lightdm
sudo systemctl enable NetworkManager
systemctl enable --user onedrive

# Print messages
echo "Installation complete! Reload AwesomeWM for changes to take effect."

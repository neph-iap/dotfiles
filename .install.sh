#!/bin/bash

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
pacman -S firefox neofetch neovim wezterm onefetch
yay -S joshuto onedrive

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

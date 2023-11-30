#!/bin/bash

# Install yay
pacman -S --needed git base-devel
git clone  https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay

# Install packages
pacman -S firefox neofetch neovim wezterm onefetch
yay -S joshuto 

# Install configuration
git clone https://github.com/neph-iap/dotfiles.git
cd dotfiles
cp -R * ~/

# Print messages
echo "Installation complete! Reload AwesomeWM for changes to take effect."

#/usr/sh
set -e

git clone "https://github.com/neph-iap/dotfiles.git"
mkdir -p ~/.config/
cp -R ./dotfiles/* ~/.config/
rm ./dotfiles -rf
echo 'export $PATH="$PATH:~/.config/scripts"' >> "~/.bashrc"
. ~/.bashrc

read -p "Enable version control with git? (Y/n)" use_git
if [[ $use_git =~ ^[Yy]$ ]] ; then
	read -p "Remote origin URL: " remote_url
	git remote set origin $remote_url
fi

rebuild-nix
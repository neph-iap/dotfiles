# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Environment variables
export PS1="┣━ " # Set Bash prompt
export BUN_INSTALL="$HOME/.bun" # Set Bun install location
export MANPAGER='nvim +Man!' # Set Neovim as the editor for man pages
export MANWIDTH=999 # Set the max width for manpages
export TERM="wezterm" # Set the terminal type: $ curl https://raw.githubusercontent.com/wez/wezterm/master/termwiz/data/wezterm.terminfo | tic -x -

# PATH variables
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="~/Documents/Coding/Lua/lush:$PATH"

function color() {
	echo "\033[38;2;$1;$2;${3}m"
}

NO_COLOR='\033[0m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'

# Print the file icon of a given filename
function file_to_icon() {
	case $1 in
		*.bash)
			echo ""
			;;
		*.c)
			echo "$(color 100 100 255)"
			;;
		*.cpp)
			echo ""
			;;
		*.cs)
			echo ""
			;;
		*.d)
			echo ""
			;;
		*.dark)
			echo ""
			;;
		*.ex)
			echo ""
			;;
		*.gyp)
			echo ""
			;;
		*.h)
			echo "$(color 200 100 255)ﴧ"
			;;
		*.html)
			echo -e "$(color 227 76 38)"
			;;
		*.java)
			echo ""
			;;
		*.jpg)
			echo ""
			;;
		*.js)
			echo "$(color 241 224 90)"
			;;
		*.json)
			echo "$(color 255 255 0)"
			;;
		LICENSE)
			echo "$(color 255 255 150)"
			;;
		*.lock)
			echo "$(color 255 255 150)"
			;;
		*.lua)
			echo "$(color 100 125 255)"
			;;
		*.md)
			echo ""
			;;
		*.png)
			echo ""
			;;
		*.py)
			echo "$(color 225 225 50)"
			;;
		*.rb)
			echo "$(color 255 50 50)"
			;;
		*.rkt)
			echo "λ"
			;;
		*.rs)
			echo "$(color 222 165 132)"
			;;
		*.toml)
			echo "$(color 150 150 150)"
			;;
		*.ts)
			echo "$(color 49 120 198)"
			;;
		*.zig)
			echo "$(color 236 145 92)𝒁"
			;;
		*.zip)
			echo "$(color 255 50 50)"
			;;
		*)
			echo ""
			;;
	esac
}

function directory_to_icon() {
	case $1 in
		*) 	
			echo "${BLUE}"
			;;
	esac
}

# Overload the cd function to list non-hidden files and folders in the
# cd'd directory. Before this I was in a never ending loop of cd ls cd ls cd ls
function cd() {
    NOCOLOR='\033[0m'

	builtin cd "$1"
	clear
	echo "┏━ $PWD:"
	echo "┃"
	FILES=$(ls -pv | grep -v /)
	DIRECTORIES=$(ls -pv | grep /)
	readarray -t FILELIST <<<"$FILES"
	readarray -t DIRLIST <<<"$DIRECTORIES"

	for DIRECTORY in "${DIRLIST[@]}"; do
        DIRECTORY=${DIRECTORY%/*}
		dir_icon=$(directory_to_icon $DIRECTORY)
		(echo "$DIRECTORY" | grep -Eq \\S ) && echo -e "┃ $dir_icon  $DIRECTORY${NOCOLOR}"
	done
	for FILE in "${FILELIST[@]}"; do
		file_icon=$(file_to_icon $FILE)	
		(echo "$FILE" | grep -Eq \\S ) && echo -e "┃ $file_icon  ${WHITE}$FILE${NOCOLOR}"
	done

    echo "┃"
}

# Wrapper around joshuto for preivews and exiting into cwd with q
function files() {
	ID="$$"
	mkdir -p /tmp/$USER
	OUTPUT_FILE="/tmp/$USER/joshuto-cwd-$ID"
	env joshuto --output-file "$OUTPUT_FILE" $@
	exit_code=$?

	case "$exit_code" in
		0)
			;;
		101)
			JOSHUTO_CWD=$(cat "$OUTPUT_FILE")
			cd "$JOSHUTO_CWD"
			;;
		102)
			;;
		*)
			echo "Exit code: $exit_code"
			;;
	esac
}

# Quickly configure dotfiles
function cfg() {
	if [[ $# < 1 ]] ; then
		echo "Error: Please provide one argument; For examle, cfg nvim"
		return 1
	fi

	case "$1" in
		"awesome")
			nvim ~/.config/awesome/rc.lua
			;;
		"lush")
			nvim ~/.config/lush/rc.lua
			;;
		"nvim")
			nvim ~/.config/nvim/init.lua
			;;
		"bash")
			nvim ~/.bashrc
			;;
		"picom")
			nvim ~/.config/picom.conf
			;;
		"wezterm")
			nvim ~/.config/wezterm/wezterm.lua
			;;
		*)
			echo "Unknown configuration: $1"
			;;
	esac
}

# Print the here directory
cd .

# Source cargo
. "$HOME/.cargo/env"

# Aliases
alias logoff="i3-msg exit" # Logoff 
alias i="sudo pacman -S" # Install a package
alias img="kitty icat" # View images with Kitty
alias dim="brightnessctl set 10%-" # Lower brightness
alias archbtw="clear; neofetch" # I use Arch by the way
alias ls='ls --color=auto' # Add colors to ls
alias grep='grep --color=auto' # Add colors to grep
alias tux="ssh $tux"
alias neofetch="neofetch --iterm2 ~/Pictures/arch.png --size 500"

export tux="ndi26@tux.cs.drexel.edu"

# Compile .ll (LLVM) files to native executable
function llvmc() {
	fname="${1%.*}"
	llc -filetype=obj $1 -o "$fname.o"
	clang "$fname.o" -o "$fname"
	rm "$fname.o"
}

# Run C files
function c() {
	fname="${1%.*}"
	gcc -o "$fname" "$fname.c"
	./"$fname"
}

# Set tab size
tabs -4

# Start joshuto

# cd ~/Documents/Coding/Lua/lush
# lua init.lua
# lush

# files

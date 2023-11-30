return {
	terminal = "wezterm",
	editor = "nvim",
	editor_cmd = "wezterm -e nvim",
	profile_picture = os.getenv("HOME") .. "/Pictures/profile.png",
	name = os.getenv("USER"):upper(),
	username = os.getenv("USER") .. "@" .. io.open("/etc/hostname"):read("a"):gsub("\n$", ""),
}

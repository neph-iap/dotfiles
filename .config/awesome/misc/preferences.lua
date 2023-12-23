return {
	terminal = "wezterm",
	editor = "nvim",
	editor_cmd = "wezterm -e nvim",
	profile_picture = os.getenv("HOME") .. "/Pictures/profile.png",
	name = os.getenv("USER"):upper(),
	username = os.getenv("USER") .. "@" .. io.open("/etc/hostname"):read("a"):gsub("\n$", ""),
	apps = {
		calculator = "/home/neph/Documents/Coding/Desktop\\ Apps/honey/src-tauri/target/release/honey",
		file_explorer = "nemo --geometry=1000x650",
	},
}

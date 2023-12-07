prompt = "> "

local editor = nvim

function cfg(app)
	local config_files = {
		awesome = "~/.config/awesome/rc.lua",
		bash = "~/.bashrc",
		lush = "~/.config/lush/rc.lua",
		nvim = "~/.config/nvim/init.lua",
		wezterm = "~/.config/wezterm/wezterm.lua",
	}

	if config_files[app] then
		editor(config_files[app])
	else
		print("Unknown app: " .. app)
	end
end

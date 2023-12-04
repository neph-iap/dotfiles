local wezterm = require("wezterm")

local config = {}

config.font = wezterm.font("Fira Code")
config.font_size = 14

config.colors = {
	background = "#060115",
	foreground = "white",
	cursor_bg = "dodgerblue",
	cursor_fg = "black",
}

config.default_cursor_style = "BlinkingBar"
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.cursor_blink_rate = 500
config.allow_square_glyphs_to_overflow_width = "Never"

config.keys = {
	{ key = "v", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },
	-- { key = "a", mods = "CTRL", action = wezterm.action({ SelectText = {} }) },
}

return config

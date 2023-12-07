local theme = {}

-- Values to be ignored by beautiful and used for custom widgets
theme.custom = {
	primary_background = "#0E0C12",
	primary_foreground = "#9280FF",
	secondary_foreground = "#50496B",
	default_margin = 10,
}

-- Titlebar
theme.titlebar_enabled = true
theme.titlebar_bg = theme.custom.primary_background
theme.border_focus = "#000000"
theme.border_normal = "#000000"
theme.titlebar_close_button_focus = os.getenv("HOME") .. "/.config/awesome/icons/close_focus.svg"

theme.border_width = 0

return theme

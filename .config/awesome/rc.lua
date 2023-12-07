--[[

AwesomeWM configuration

--]]

pcall(require, "luarocks.loader") -- Check luarocks packages if luarocks is installed

-- Standard awesome libraries
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful") -- Theme handling library
local menubar = require("menubar")

require("awful.autofocus")
require("awful.hotkeys_popup.keys")

local preferences = require("misc.preferences")

require("misc.startup") -- Handle errors on startup

beautiful.init(os.getenv("HOME") .. "/.config/awesome/theme.lua") -- Initialize theme

-- Initialize widgets
local sidebar = require("widgets.sidebar")
local menu = require("widgets.menu")
local tags = require("widgets.tags")
local volume_bar = require("widgets.volume")
local brightness_bar = require("widgets.brightness")
local dock = require("widgets.dock")
local launcher = require("widgets.launcher")

menu.setup({
	sidebar = sidebar.widget,
	menu = menu.widget,
	tags = tags.widget,
	volume = volume_bar.widget,
	brightness = brightness_bar.widget,
	dock = dock.widget,
	launcher = launcher.widget,
})

require("widgets.notification")

-- Initialize hotkeys
local keys = require("misc.keys")
keys.setup({
	sidebar = sidebar.widget,
	menu = menu.widget,
	tags = tags.widget,
	volume = volume_bar.widget,
	brightness = brightness_bar.widget,
	dock = dock.widget,
	launcher = launcher.widget,
})

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.floating,
}

-- Menubar configuration
menubar.utils.terminal = preferences.terminal -- Set the terminal for applications that require it

local function set_wallpaper(s)
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	set_wallpaper(s)
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
end)

root.buttons(gears.table.join(awful.button({}, 4, awful.tag.viewnext), awful.button({}, 5, awful.tag.viewprev)))

-- Set keys
root.keys(keys.globalkeys)

require("misc.window")

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		awful.placement.no_offscreen(c) -- Prevent clients from being unreachable after screen count changes.
	end
end)

awful.spawn("picom -b --config " .. os.getenv("HOME") .. "/.config/picom/picom.conf")

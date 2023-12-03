--[[

AwesomeWM configuration

--]]

pcall(require, "luarocks.loader") -- Check luarocks packages if luarocks is installed

-- Standard awesome libraries
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox") -- Widget and layout library
local beautiful = require("beautiful") -- Theme handling library
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

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

-- ==========================================================================================================
-- Menu ---------- Menu ---------- Menu
-- ==========================================================================================================

local myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "manual", preferences.terminal .. " -e man awesome" },
	{ "edit config", preferences.editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

local mymainmenu = awful.menu({
	items = {
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "open terminal", preferences.terminal },
	},
})

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

root.buttons(gears.table.join(
	awful.button({}, 3, function()
		mymainmenu:toggle()
	end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.

local clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ keys.modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ keys.modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(keys.globalkeys)

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = keys.clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
			},
			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = {
			floating = true,
		},
	},

	-- Add titlebars to normal clients and dialogs
	{
		rule_any = {
			type = { "normal", "dialog" },
		},
		properties = { titlebars_enabled = true },
	},
}

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		awful.placement.no_offscreen(c) -- Prevent clients from being unreachable after screen count changes.
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),

		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c, { size = 32 }):setup({
		-- Left
		{
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},

		-- Middle
		{
			{
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},

		-- Right
		{
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},

		layout = wibox.layout.align.horizontal,
	})
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)

awful.spawn("picom -b --config " .. os.getenv("HOME") .. "/.config/picom/picom.conf")

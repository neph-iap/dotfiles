local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local keys = require("misc.keys")

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
local function close_button(c)
	local widget = wibox.widget({
		{
			wibox.widget.textbox(" "),
			widget = wibox.container.margin,
			top = 5,
			bottom = 5,
			right = 5,
			left = 5,
		},
		widget = wibox.container.background,
		bg = "#FF4444",
		shape = gears.shape.circle,
	})

	widget:connect_signal("button::press", function()
		c:kill()
	end)

	return widget
end

local function workspace_button(c, tag_number)
	local current_tag = awful.tag.selected(1).index
	local color = "#7700FF"
	if current_tag == tag_number then
		color = "#EEAAFF"
	end

	local widget = wibox.widget({
		{
			wibox.widget.textbox(" "),
			widget = wibox.container.margin,
			top = 5,
			bottom = 5,
			right = 5,
			left = 5,
		},
		widget = wibox.container.background,
		bg = color,
		shape = gears.shape.circle,
	})

	widget:connect_signal("button::press", function()
		c:move_to_tag(client.focus.screen.tags[tag_number])
		for _, some_client in ipairs(client.get()) do
			some_client:emit_signal("request::titlebars")
		end
	end)

	return {
		widget,
		widget = wibox.container.margin,
		right = 7,
	}
end

local function layout_widget()
	local current_tag = awful.tag.selected(1)

	local current_layout = tostring(current_tag.layout.name)
	local current_layout_color = "#FFFFFF"

	if current_layout == "tile" then
		current_layout = "﩯"
		current_layout_color = "#00FFAA"
	elseif current_layout == "floating" then
		current_layout = "󰅟"
		current_layout_color = "#00AAFF"
	end

	local layout = wibox.widget.textbox(('<span color="%s">%s</span>'):format(current_layout_color, current_layout))
	layout.font = "OpenSans 15"

	layout:connect_signal("button::press", function()
		awful.layout.inc(1)

		for _, c in ipairs(client.get()) do
			c:emit_signal("request::titlebars")
		end
	end)

	return layout
end

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
			{
				workspace_button(c, 1),
				workspace_button(c, 2),
				workspace_button(c, 3),
				workspace_button(c, 4),
				workspace_button(c, 5),
				layout = wibox.layout.fixed.horizontal(),
			},
			widget = wibox.container.margin,
			left = 10,
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
			{
				layout_widget(),
				close_button(c),
				layout = wibox.layout.fixed.horizontal(),
				spacing = 10,
			},
			widget = wibox.container.margin,
			right = 10,
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

local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local theme = require("misc.theme")

local public = {}

local slide_speed = 70
local top = -700

local menu = wibox({ visible = false, ontop = true, type = "dock", screen = screen.primary })
menu.width = 500
menu.height = 700
menu.visible = true
menu.bg = theme.custom.primary_background
menu.border_width = 2
menu.border_color = theme.custom.primary_foreground
menu.shape = function(cr, width, height)
	gears.shape.rounded_rect(cr, width, height, 15)
end

awful.placement.top_right(menu, { honor_workarea = true, margins = { right = theme.custom.default_margin, top = theme.custom.default_margin } })

local time = wibox.widget.textclock("%H:%M")
time.font = "OpenSans 72"
time.align = "center"

local name = wibox.widget.textbox()
name.markup = ("<b>%s</b>"):format(os.getenv("USER"):upper())
name.align = "center"
name.font = "OpenSans 20"

local username = wibox.widget.textbox()
username.markup = ('<span color="#777777">%s</span>'):format(os.getenv("USER") .. "@" .. io.open("/etc/hostname"):read("a"))
username.align = "center"
username.font = "OpenSans 20"

local wifi = wibox.widget.textbox()
wifi.markup = ('<span color="#BBBBBB">%s</span>'):format("󰖩 " .. io.popen("iwgetid -r"):read("a"))
wifi.align = "center"
wifi.font = "OpenSans 15"

local profile = wibox.widget.imagebox(os.getenv("HOME") .. "/Pictures/profile.png")
profile.forcd_width = 200
profile.forced_height = 200
profile.clip_shape = function(cr, width, height)
	gears.shape.circle(cr, width, height, 80)
end

local function power_button(text, command)
	local power_button_widget = wibox.widget.textbox()
	power_button_widget.markup = ('<span color="%s">%s</span>'):format("white", text)
	power_button_widget.font = "OpenSans 32"
	power_button_widget.align = "center"

	power_button_widget:connect_signal("button::press", function()
		command()
	end)

	power_button_widget = {
		{
			power_button_widget,
			widget = wibox.container.margin,
			top = 25,
			bottom = 25,
			right = 25,
			left = 25,
		},
		widget = wibox.container.background,
		shape = gears.shape.circle,
	}

	return power_button_widget
end

local sleep = power_button("a", awesome.restart)
local shutdown = power_button("󰐥", function()
	awful.spawn("shutdown")
end)
local restart = power_button("󰜉", function()
	awful.spawn("reboot")
end)
local logout = power_button("󰍃", awesome.quit)

function menu:refresh_numbers()
	local today = os.date("*t")
	local days = {
		"Sunday",
		"Monday",
		"Tuesday",
		"Wednesday",
		"Thursday",
		"Friday",
		"Saturday",
	}

	local today_day = days[today.wday]

	local months = {
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"Septemeber",
		"October",
		"November",
		"December",
	}

	local suffixes = {
		"st",
		"nd",
		"rd",
	}
	local today_suffix = suffixes[today.day] or "th"

	local today_month = months[today.month]

	local date_widget = wibox.widget.textbox()
	date_widget.markup = ('<span color="%s">%s, %s %s%s</span>'):format("#AAAAAA", today_day, today_month, today.day, today_suffix)
	date_widget.font = "OpenSans 15"
	date_widget.align = "center"

	local volume = tonumber(io.popen("pamixer --get-volume"):read("a"))
	local volume_percent = volume / 100

	local volume_icon = wibox.widget.textclock("    " .. (volume > 0 and "󰕾" or "󰝟") .. "    ")
	volume_icon.font = "OpenSans 20"

	local volume_widget = wibox.widget.slider({
		maximum = 100,
		value = volume,
		minimum = 0,
		bar_height = 20,
		forced_height = 60,
		handle_color = "#FFFFFF",
		bar_color = gears.color({
			type = "linear",
			from = { 0, 0 },
			to = { 300, 0 },
			stops = {
				{ 0, theme.custom.primary_foreground },
				{ volume_percent - 0.01, theme.custom.primary_foreground },
				{ volume_percent, theme.custom.secondary_foreground },
				{ 1, theme.custom.secondary_foreground },
			},
		}),
		handle_shape = gears.shape.circle,
		bar_shape = gears.shape.rounded_bar,
		forced_width = 300,
	})

	local volume_text = wibox.widget.textclock("    " .. tostring(volume) .. "%%")
	volume_text.font = "OpenSans 20"
	volume_text.align = "center"

	local brightness = tonumber(io.popen("brightnessctl get"):read("a"))
	local max_brightness = tonumber(io.popen("brightnessctl max"):read("a"))
	local brightness_percent = brightness / max_brightness

	local brightness_icon = wibox.widget.textclock("    " .. "󰃠" .. "    ")
	brightness_icon.font = "OpenSans 20"

	local brightness_widget = wibox.widget.slider({
		maximum = max_brightness,
		value = brightness,
		minimum = 0,
		bar_height = 20,
		forced_height = 60,
		handle_color = "#FFFFFF",
		bar_color = gears.color({
			type = "linear",
			from = { 0, 0 },
			to = { 300, 0 },
			stops = {
				{ 0, theme.custom.primary_foreground },
				{ brightness_percent - 0.01, theme.custom.primary_foreground },
				{ brightness_percent, theme.custom.secondary_foreground },
				{ 1, theme.custom.secondary_foreground },
			},
		}),
		handle_shape = gears.shape.circle,
		bar_shape = gears.shape.rounded_bar,
		forced_width = 300,
	})

	local brightness_text = wibox.widget.textclock("    " .. tostring(math.floor(brightness_percent * 100)) .. "%%")
	brightness_text.font = "OpenSans 20"
	brightness_text.align = "center"

	menu:setup({
		{
			{
				{
					time,
					top = 25,
					widget = wibox.container.margin,
				},
				date_widget,
				{
					widget = wibox.container.margin,
					top = 15,
				},
				{
					profile,
					widget = wibox.container.margin,
					left = 150,
				},
				name,
				username,
				{
					volume_icon,
					volume_widget,
					volume_text,
					layout = wibox.layout.fixed.horizontal,
				},
				{
					brightness_icon,
					brightness_widget,
					brightness_text,
					layout = wibox.layout.fixed.horizontal,
				},
				{
					{
						shutdown,
						restart,
						logout,
						sleep,
						layout = wibox.layout.flex.horizontal,
					},
					widget = wibox.container.margin,
					top = 5,
				},
				layout = wibox.layout.fixed.vertical,
			},
			widget = wibox.container.background,
			clip = true,
			spacing = 25,
			layout = wibox.layout.fixed.vertical,
		},
		layout = wibox.layout.align.vertical,
	})
end

menu.visible = false

-- Sliding animation

local function slide_in()
	awful.placement.top_right(menu, { honor_workarea = true, margins = { right = theme.custom.default_margin, top = top } })
	top = top + slide_speed
	if top < 10 then
		awful.spawn.easy_async_with_shell("sleep 0.001", function()
			slide_in()
		end)
	elseif top > 10 then
		top = 10
		awful.placement.top_right(menu, { honor_workarea = true, margins = { right = theme.custom.default_margin, top = top } })
	end
end

local function slide_out()
	awful.placement.top_right(menu, { honor_workarea = true, margins = { right = theme.custom.default_margin, top = top } })
	top = top - slide_speed
	if top > -700 then
		awful.spawn.easy_async_with_shell("sleep 0.001", function()
			slide_out()
		end)
	elseif top < -700 then
		top = -700
		awful.placement.top_right(menu, { honor_workarea = true, margins = { right = theme.custom.default_margin, top = top } })
		menu.visible = false
	end
end

function menu:toggle()
	awful.placement.top_right(menu, { honor_workarea = true, margins = { right = theme.custom.default_margin, top = top } })
	if not self.visible then
		self.visible = true
		self:refresh_numbers()
		slide_in()
	else
		slide_out()
	end
end

public.widget = menu

return public

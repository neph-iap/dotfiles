local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local theme = require("../theme")
local preferences = require("preferences")

local sidebar = wibox({ visible = false, ontop = true, type = "dock", screen = screen.primary })
sidebar.width = 400
sidebar.height = awful.screen.focused().workarea.height - (2 * theme.custom.default_margin)
sidebar.visible = true
sidebar.bg = theme.custom.primary_background

awful.placement.top_left(sidebar, { honor_workarea = true, margins = { left = theme.custom.default_margin, top = theme.custom.default_margin } })

local name = wibox.widget.textbox()
name.markup = ("<b>%s</b>"):format(preferences.name)
name.align = "center"
name.font = "OpenSans 20"

local username = wibox.widget.textbox()
username.markup = ('<span color="#777777">%s</span>'):format(preferences.username)
username.align = "center"
username.font = "OpenSans 20"

local profile = wibox.widget.imagebox(preferences.profile_picture)
profile.clip_shape = function(cr, width, height)
	gears.shape.circle(cr, width, height, 150)
end

function sidebar:refresh_numbers()
	local wifi = wibox.widget.textbox()
	wifi.markup = ('<span color="#DDDDDD">%s</span>'):format("󰖩 " .. io.popen("iwgetid -r"):read("a"):gsub("\n$", ""))
	wifi.align = "center"
	wifi.font = "OpenSans 20"

	local today = os.date("*t")
	local first_of_month = (today.wday - today.day + 1) % 7

	local months = {
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"September",
		"October",
		"November",
		"December",
	}

	local days = {
		"Sunday",
		"Monday",
		"Tuesday",
		"Wednesday",
		"Thursday",
		"Friday",
		"Saturday",
	}

	local calendar_title = wibox.widget.textbox()
	local this_month = months[today.month]
	calendar_title.markup = ('<span color="%s">%s</span>'):format(theme.custom.primary_foreground, this_month)
	calendar_title.font = "OpenSans 20"
	calendar_title.align = "center"

	local function days_in_month(month_number, year)
		local day_counts = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
		local amount = day_counts[month_number]

		-- Leap year
		if month_number == 2 then
			if year % 400 == 0 or year % 100 ~= 0 and year % 4 == 0 then
				amount = 29
			end
		end

		return amount
	end

	local month = { layout = wibox.layout.fixed.vertical, spacing = 15 }

	local week_days = { layout = wibox.layout.flex.horizontal }
	for index, week_day in ipairs(days) do
		local color = theme.custom.primary_foreground
		if today.wday == index then
			color = "#FFFFFF"
		end

		local day_widget = wibox.widget.textbox()
		day_widget.markup = ('<span color="%s">%s</span>'):format(color, week_day:sub(1, 2))
		day_widget.font = "OpenSans 14"
		day_widget.align = "center"
		table.insert(week_days, day_widget)
	end
	table.insert(month, week_days)

	for week_number = 1, 5 do
		local week = { layout = wibox.layout.flex.horizontal }
		for day = 1, 7 do
			local day_number = (week_number - 1) * 7 + day - first_of_month + 1
			local color = theme.custom.primary_foreground

			if day_number < 1 then
				local last_month = { today.month - 1, today.year }
				if today.month == 1 then
					last_month = { 12, today.year - 1 }
				end
				day_number = days_in_month(last_month[1], last_month[2]) - math.abs(day_number)
				color = theme.custom.secondary_foreground
			elseif day_number > days_in_month(today.month, today.year) then
				day_number = day_number - days_in_month(today.month, today.year)
				color = theme.custom.secondary_foreground
			end

			local is_today = false
			if color == theme.custom.primary_foreground and day_number == today.day then
				color = theme.custom.primary_background
				is_today = true
			end

			local day_widget = wibox.widget.textbox()
			day_widget.markup = ('<span color="%s">%d</span>'):format(color, day_number)
			day_widget.font = "OpenSans 14"
			day_widget.align = "center"
			day_widget.bg = theme.custom.primary_background

			local bg = theme.custom.primary_background
			if is_today then
				bg = theme.custom.primary_foreground
			end

			day_widget = {
				{
					day_widget,
					widget = wibox.container.margin,
					left = 10,
					top = 10,
					bottom = 10,
					right = 10,
				},
				widget = wibox.container.background,
				bg = bg,
				shape = gears.shape.circle,
			}

			day_widget[1][1]:connect_signal("mouse::enter", function()
				day_widget[1][1].markup = ('<span color="%s">%d</span>'):format("#FFFFFF", day_number)
				day_widget.bg = "#FF0000"
				sidebar:refresh_numbers()
			end)
			day_widget[1][1]:connect_signal("mouse::leave", function()
				day_widget[1][1].markup = ('<span color="%s">%d</span>'):format(color, day_number)
				day_widget.bg = bg
			end)

			table.insert(week, day_widget)
		end
		table.insert(month, week)
	end

	local calendar = month

	local calendar_left = wibox.widget.textbox()
	calendar_left.markup = ('<span color="%s">    󰍞</span>'):format(theme.custom.primary_foreground)
	calendar_left.font = "OpenSans 20"

	local calendar_right = wibox.widget.textbox()
	calendar_right.markup = ('<span color="%s">󰍟   </span>'):format(theme.custom.primary_foreground)
	calendar_right.font = "OpenSans 20"
	calendar_right.align = "right"

	local battery_percentage = tonumber(io.open("/sys/class/power_supply/BAT0/capacity"):read("a"))
	local is_charging = io.open("/sys/class/power_supply/BAT0/status"):read("a"):match("%s*([^%s]+)%s*") == "Charging"

	local battery_icon = wibox.widget.textclock(is_charging and "  󰂉" or "  󰁽 ")
	battery_icon.font = "OpenSans 20"

	local battery = wibox.widget({
		max_value = 100,
		value = battery_percentage,
		forced_height = 20,
		forced_width = 300,
		color = theme.custom.primary_foreground,
		margins = { right = 25, left = 25 },
		shape = gears.shape.rounded_bar,
		background_color = theme.custom.secondary_foreground,
		widget = wibox.widget.progressbar,
		bar_shape = gears.shape.rounded_bar,
	})

	local battery_text = wibox.widget.textclock(tostring(battery_percentage .. "%%"))
	battery_text.font = "OpenSans 15"

	local disk_icon = wibox.widget.textclock("  󰏖")
	disk_icon.font = "OpenSans 20"

	local disk_usage = tonumber(io.popen("df -H"):read("a"):match("(%d+)%%%s+/home"))
	local disk_usage_widget = wibox.widget({
		max_value = 100,
		value = disk_usage,
		forced_height = 20,
		forced_width = 300,
		margins = { right = 25, left = 25 },
		color = theme.custom.primary_foreground,
		shape = gears.shape.rounded_bar,
		background_color = theme.custom.secondary_foreground,
		widget = wibox.widget.progressbar,
		bar_shape = gears.shape.rounded_bar,
	})

	local disk_text = wibox.widget.textclock(tostring(disk_usage) .. "%%")
	disk_text.font = "OpenSans 15"

	local cpu_temperature_icon = wibox.widget.textclock("  󰘚")
	cpu_temperature_icon.font = "OpenSans 20"

	local cpu_temperature = math.floor(9 / 5 * tonumber(io.popen("cat /sys/class/thermal/thermal_zone2/temp"):read("a")) / 1000 + 32)

	local cpu_temperature_widget = wibox.widget({
		max_value = 176,
		value = cpu_temperature - 72,
		forced_height = 20,
		forced_width = 300,
		margins = { right = 25, left = 25 },
		color = theme.custom.primary_foreground,
		shape = gears.shape.rounded_bar,
		background_color = theme.custom.secondary_foreground,
		widget = wibox.widget.progressbar,
		bar_shape = gears.shape.rounded_bar,
	})

	local cpu_temperature_text = wibox.widget.textclock(tostring(cpu_temperature) .. "°")
	cpu_temperature_text.font = "OpenSans 15"

	sidebar:setup({
		{
			{
				profile,
				name,
				username,
				layout = wibox.layout.fixed.vertical,
			},
			{
				{
					{
						calendar_left,
						calendar_title,
						calendar_right,
						layout = wibox.layout.flex.horizontal,
					},
					calendar,
					layout = wibox.layout.fixed.vertical,
					spacing = 25,
					{
						wifi,
						widget = wibox.container.margin,
						top = 10,
					},
				},
				{
					{
						battery_icon,
						battery,
						battery_text,
						layout = wibox.layout.fixed.horizontal,
					},
					{
						disk_icon,
						disk_usage_widget,
						disk_text,
						layout = wibox.layout.fixed.horizontal,
					},
					{
						cpu_temperature_icon,
						cpu_temperature_widget,
						cpu_temperature_text,
						layout = wibox.layout.fixed.horizontal,
					},
					layout = wibox.layout.fixed.vertical,
					spacing = 25,
				},
				layout = wibox.layout.fixed.vertical,
				spacing = 100,
			},
			widget = wibox.container.background,
			forced_width = 400,
			clip = true,
			spacing = 25,
			layout = wibox.layout.fixed.vertical,
		},
		layout = wibox.layout.align.vertical,
	})
end

function sidebar:toggle()
	self.visible = not self.visible
	if self.visible then
		sidebar:refresh_numbers()
	end
end

sidebar.visible = false

return {
	widget = sidebar,
}

local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local theme = require("misc.theme")

local brightness_bar = wibox({ visible = false, ontop = true, type = "dock", screen = screen.primary })
brightness_bar.width = 300
brightness_bar.height = 50
brightness_bar.bg = theme.custom.primary_background

awful.placement.top_right(brightness_bar, { honor_workarea = true, margins = { right = theme.custom.default_margin, top = theme.custom.default_margin } })

function brightness_bar:refresh_numbers()
	local brightness = tonumber(io.popen("brightnessctl get"):read("a"))
	local max_brightness = tonumber(io.popen("brightnessctl max"):read("a"))
	local brightness_percent = brightness / max_brightness

	local brightness_icon = wibox.widget.textclock("󰃠" .. "    ")
	brightness_icon.font = "OpenSans 20"

	local brightness_widget = wibox.widget.slider({
		maximum = max_brightness,
		value = brightness,
		minimum = 0,
		bar_height = 10,
		forced_height = 10,
		handle_color = theme.custom.primary_foreground,
		bar_color = gears.color({
			type = "linear",
			from = { 0, 0 },
			to = { 200, 0 },
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

	local brightness_text = wibox.widget.textclock("    " .. tostring(brightness) .. "%%")
	brightness_text.font = "OpenSans 20"
	brightness_text.align = "center"

	brightness_bar:setup({
		{
			{
				brightness_icon,
				brightness_widget,
				brightness_text,
				layout = wibox.layout.fixed.horizontal,
			},
			widget = wibox.container.margin,
			right = 25,
			left = 25,
		},
		layout = wibox.layout.flex.vertical,
	})
end

function brightness_bar:toggle()
	self.visible = not self.visible
	if self.visible then
		brightness_bar:refresh_numbers()
	end
end

function brightness_bar:show()
	brightness_bar.visible = true
	brightness_bar:refresh_numbers()
	if brightness_bar.timer then
		brightness_bar.timer:again()
	else
		brightness_bar.timer = gears.timer({
			timeout = 2,
			autostart = true,
			callback = function()
				brightness_bar:hide()
			end,
		})
	end
end

function brightness_bar:hide()
	brightness_bar.visible = false
end

return {
	widget = brightness_bar,
}

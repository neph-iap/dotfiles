local ruled = require("ruled")
local awful = require("awful")
local naughty = require("naughty")
local theme = require("misc.theme")

naughty.config.spacing = theme.custom.default_margin
naughty.config.padding = theme.custom.default_margin

-- Style notification
ruled.notification.connect_signal("request::rules", function()
	ruled.notification.append_rule({
		rule = {},
		properties = {
			screen = awful.screen.preferred,
			implicit_timeout = 5,
			position = "bottom_right",
			margin = 25,
			border_width = 0,
			border_radius = 6,
			bg = theme.custom.primary_background,
			font = "OpenSans 14",
			icon_size = 60,
		},
	})
end)

-- Go to the client when clicking the notification
naughty.connect_signal("destroyed", function(n, reason)
	if not n.clients then
		return
	end
	if reason == require("naughty.constants").notification_closed_reason.dismissed_by_user then
		local jumped = false
		for _, c in ipairs(n.clients) do
			c.urgent = true
			if jumped then
				c:activate({ context = "client.jumpto" })
			else
				c:jump_to()
				jumped = true
			end
		end
	end
end)

local status
awful.widget.watch("cat /sys/class/power_supply/BAT0/status", 1, function(_, stdout)
	if status ~= stdout then
		naughty.notify({
			title = "Battery",
			text = "Now " .. stdout:lower():gsub("\n", ""),
		})
		status = stdout
	end
end)

local gave_20_warning = false
local gave_10_warning = false
awful.widget.watch("cat /sys/class/power_supply/BAT0/capacity", 1, function(_, stdout)
	if not gave_20_warning and tonumber(stdout) <= 20 then
		naughty.notify({
			title = "Battery",
			text = "Warning: Battery is low (" .. stdout:gsub("\n$", "") .. "%)",
		})
		gave_20_warning = true
	end

	if not gave_10_warning and tonumber(stdout) <= 10 then
		naughty.notify({
			title = "Battery",
			text = "Warning: Battery is critical (" .. stdout:gsub("\n$", "") .. "%)",
		})
		gave_10_warning = true
	end

	if tonumber(stdout) > 10 then
		gave_10_warning = false
	end

	if tonumber(stdout) > 20 then
		gave_20_warning = false
	end
end)

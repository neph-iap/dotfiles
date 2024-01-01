local awful = require("awful")
local naughty = require("naughty") -- Notification library

-- Handle runtime errors after startup
if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical, title = "Oops, there were errors during startup!", text = awesome.startup_errors })
end
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		if in_error then
			return
		end -- Make sure we don't go into an endless error loop
		in_error = true

		naughty.notify({ preset = naughty.config.presets.critical, title = "Oops, an error happened!", text = tostring(err) })
		in_error = false
	end)
end

-- Startup programs
awful.spawn.with_shell("picom -b --config ~/.config/picom/picom.conf")
awful.spawn.with_shell("feh --no-fehbg --bg-fill '/home/neph/Pictures/Wallpapers/City2.jpg'")

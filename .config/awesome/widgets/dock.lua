local wibox = require("wibox")
local awful = require("awful")
local theme = require("misc.theme")
local gears = require("gears")
local preferences = require("misc.preferences")

local apps = {
	preferences.terminal:match("^(%S+)"),
	preferences.apps.browser:match("^(%S+)"),
	preferences.apps.chat:match("^(%S+)"),
	preferences.apps.file_explorer:match("^(%S+)"),
}

local function get_app_icon(app_name)
	local dirs_to_check = {
		"scalable",
		"512x512",
		"384x384",
		"256x256",
		"192x192",
		"128x128",
		"96x96",
		"72x72",
		"48x48",
		"36x36",
		"32x32",
		"24x24",
		"22x22",
		"16x16",
	}

	for _, dir in ipairs(dirs_to_check) do
		local path_to_directory = "/usr/share/icons/hicolor/" .. dir .. "/apps/"
		for file in io.popen("ls " .. path_to_directory):lines() do
			if file:match("%f[%a]" .. app_name .. "%f[%A]") then
				return path_to_directory .. file
			end
		end
	end
end

local space_between_icons = 40

local dock = wibox({ visible = true, ontop = true, type = "dock", screen = screen.primary })
dock.width = #apps * (75 + space_between_icons)
dock.height = 75
dock.bg = "#FF000000"

awful.placement.align(dock, { position = "bottom", honor_workarea = true, margins = { bottom = theme.custom.default_margin } })

function dock:refresh_numbers()
	local tag_widgets = { layout = wibox.layout.flex.horizontal }

	for _, app_name in ipairs(apps) do
		local individual_widget = wibox.widget.imagebox(get_app_icon(app_name))
		local old_cursor, old_wibox

		individual_widget:connect_signal("mouse::enter", function()
			local w = mouse.current_wibox
			old_cursor, old_wibox = w.cursor, w
			w.cursor = "hand2"
		end)
		individual_widget:connect_signal("mouse::leave", function()
			if old_wibox then
				old_wibox.cursor = old_cursor
				old_wibox = nil
			end
		end)

		individual_widget:connect_signal("button::press", function()
			awful.spawn(app_name)
		end)

		individual_widget = {
			{
				{
					individual_widget,
					widget = wibox.container.margin,
					top = 10,
					right = 10,
					bottom = 10,
					left = 10,
				},
				widget = wibox.container.background,
				bg = theme.custom.primary_background,
				shape = gears.shape.rounded_rect,
			},
			widget = wibox.container.margin,
			right = space_between_icons,
		}
		table.insert(tag_widgets, individual_widget)
	end
	dock:setup({
		tag_widgets,
		layout = wibox.layout.fixed.horizontal,
	})
end

dock:refresh_numbers()

function dock:toggle()
	self.visible = not self.visible
	if self.visible then
		dock:refresh_numbers()
	end
end

function dock:close()
	self.visible = false
end

function dock:open()
	self.visible = true
end

return {
	widget = dock,
}

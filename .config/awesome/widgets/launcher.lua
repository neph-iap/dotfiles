local wibox = require("wibox")
local awful = require("awful")
local theme = require("../theme")

local launcher = wibox({ visible = false, ontop = true, type = "dock", screen = screen.primary })
launcher.width = 300
launcher.height = 500
launcher.visible = true
launcher.bg = theme.custom.primary_background

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
		local dirs = assert(io.popen("ls " .. path_to_directory))
		for file in dirs:lines() do
			if file:match("%f[%a]" .. app_name .. "%f[%A]") then
				return path_to_directory .. file
			end
		end
		dirs:close()
	end

	return nil
end

awful.placement.top_right(launcher, { honor_workarea = true, margins = { right = theme.custom.default_margin + 500, top = theme.custom.default_margin } })

local apps = {}

for directory in io.popen("ls /usr/bin"):lines() do
	table.insert(apps, directory)
end

local app_widgets = { layout = wibox.layout.fixed.vertical }
for _, app in ipairs(apps) do
	if not app:match("[%w%s]+") then
		goto continue
	end

	local app_icon = get_app_icon(app)

	if not app_icon then
		goto continue
	end

	local icon_widget = wibox.widget.imagebox(app_icon)
	icon_widget.forced_width = 70
	icon_widget.forced_height = 70
	local name_widget = wibox.widget.textbox()
	name_widget.markup = ('<span color="%s">%s</span>'):format(theme.custom.primary_foreground, app:gsub("^%l", string.upper))
	name_widget.font = "OpenSans 20"
	local app_widget = {
		{
			icon_widget,
			widget = wibox.container.margin,
			top = 15,
			left = 15,
			right = 15,
			bottom = 15,
		},
		name_widget,
		layout = wibox.layout.fixed.horizontal,
	}
	table.insert(app_widgets, app_widget)

	::continue::
end

local function levenshtein(a, b)
	if a == b then
		return -2
	end
	if b:sub(1, #a) == a then
		return -1
	end

	local dummy
	local m = #a
	local n = #b

	local v0 = {}
	local v1 = {}

	for i = 0, #b do
		v0[i] = i
	end

	for i = 0, m - 1 do
		v1[0] = i + 1
		for j = 0, n - 1 do
			local deletion_cost = v0[j + 1]
			local insertion_cost = v1[j] + 1

			local substitution_cost = v0[j] + 1
			if a:sub(i + 1, i + 1) == b:sub(j + 1, j + 1) then
				substitution_cost = v0[j]
			end

			v1[j + 1] = math.min(deletion_cost, insertion_cost, substitution_cost)
		end

		dummy = v0
		v0 = v1
		v1 = dummy
	end

	return v0[n]
end

function launcher:refresh_numbers()
	launcher:setup({
		{
			app_widgets,
			widget = wibox.container.background,
			clip = true,
			spacing = 25,
			layout = wibox.layout.fixed.vertical,
		},
		layout = wibox.layout.align.vertical,
	})
end

function launcher:sort(search_text)
	local sorted_widgets = { layout = wibox.layout.fixed.vertical }
	for _, widget in ipairs(app_widgets) do
		table.insert(sorted_widgets, widget)
	end
	table.sort(sorted_widgets, function(a, b)
		local a_text = a[2].markup:match(">([^<]+)<"):lower()
		local b_text = b[2].markup:match(">([^<]+)<"):lower()
		local a_distance = levenshtein(a_text, search_text)
		local b_distance = levenshtein(b_text, search_text)
		return a_distance < b_distance
	end)

	sorted_widgets[1] = {
		sorted_widgets[1],
		widget = wibox.container.background,
		bg = "#333344",
	}
	launcher.apps = sorted_widgets

	launcher:setup({
		{
			sorted_widgets,
			widget = wibox.container.background,
			clip = true,
			spacing = 25,
			layout = wibox.layout.fixed.vertical,
		},
		layout = wibox.layout.align.vertical,
	})
end

function launcher:toggle()
	self.visible = not self.visible
	if self.visible then
		launcher:refresh_numbers()
	end
end

launcher.visible = false

return {
	widget = launcher,
}

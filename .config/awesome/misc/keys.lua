local awful = require("awful")
local gears = require("gears")
local preferences = require("misc.preferences")

local public = {}
public.modkey = "Mod4"

local other_key_was_pressed = false

-- Returns a function that notes that an action was done, and then calls the action given to it.
-- Used to make sure the start menu doesn't open when other actions are called.
--
---@param action function
--
---@return function
local function f(action)
	return function(...)
		other_key_was_pressed = true
		action(...)
	end
end

-- Called when the modkey is pressed
local function modkey_pressed(widgets)
	widgets.tags:open()
end

-- Called when the modkey is released
local function modkey_released(widgets)
	widgets.tags:close()
	if not other_key_was_pressed then
		widgets.menu:toggle()
		-- widgets.menu.search:run()
	else
		other_key_was_pressed = false
	end
end

function public.setup(widgets)
	local modkey = public.modkey
	local modkey_code = "#133"

	-- stylua: ignore start
	public.globalkeys = gears.table.join(

		-- Modkey (requires special press/release handling)
		awful.key({}, modkey_code, function() modkey_pressed(widgets) end, function() end),
		awful.key({ modkey }, modkey_code, function() end, function() modkey_released(widgets) end),

		-- Menus & Widgets
		awful.key({ modkey }, "`", f(function() widgets.sidebar:toggle() end)),
		awful.key({ modkey }, "b", f(function() widgets.dock:toggle() end)),

		-- Tags
		awful.key({ modkey }, "Left", f(awful.tag.viewprev)),
		awful.key({ modkey }, "Right", f(awful.tag.viewnext)),

		-- Launch Programs (These generally use mod + shift)
		awful.key({ modkey }, "r", f(function() awful.spawn(os.getenv("HOME") .. "/.config/rofi/launchers/type-3/launcher.sh") end)),
		awful.key({ modkey }, "Return", f(function() awful.spawn(preferences.terminal) end)),
		awful.key({ modkey, "Shift" }, "l", f(function() awful.spawn("librewolf") end)),
		awful.key({ modkey, "Shift" }, "d", f(function() awful.spawn("discord") end)),
		awful.key({ modkey, "Shift" }, "s", f(function() awful.spawn("flameshot gui") end)),
		awful.key({ modkey, "Shift" }, "c", f(function() awful.spawn(preferences.apps.calculator) end)),

		-- Awesome Core Functions
		awful.key({ modkey }, "r", f(awesome.restart)),
		awful.key({ modkey }, "q", f(awesome.quit)),
		awful.key({ modkey }, "f", f(function() awful.layout.inc(1); for _, some_client in ipairs(client.get()) do some_client:emit_signal("request::titlebars") end end)),

		-- Print screen key
		awful.key({}, "Print", f(function() awful.spawn.with_shell('flameshot full --path "' .. os.getenv("HOME") .. '/Pictures/Screenshots/' .. tostring(os.date("%x")):gsub("/", "_") .. " at " .. tostring(os.date("%X")):gsub(":|%s", "_") .. '"') end)),

		-- Brightness
		awful.key({}, "XF86MonBrightnessUp", function() os.execute("brightnessctl set +10%"); widgets.menu:refresh_numbers(); widgets.brightness:show() end, { description = "Increase brightness", group = "brightness" }),
		awful.key({}, "XF86MonBrightnessDown", function() os.execute("brightnessctl set 10%-"); widgets.menu:refresh_numbers(); widgets.brightness:show() end, { description = "Decrease brightness", group = "brightness" }),
		awful.key({ "Control" }, "XF86MonBrightnessUp", function() os.execute("brightnessctl set 100%"); widgets.menu:refresh_numbers(); widgets.brightness:show() end, { description = "Increase brightness", group = "brightness" }),
		awful.key({ "Control" }, "XF86MonBrightnessDown", function() os.execute("brightnessctl set 1%"); widgets.menu:refresh_numbers(); widgets.brightness:show() end, { description = "Decrease brightness", group = "brightness" }),
		awful.key({ "Shift" }, "XF86MonBrightnessUp", function() os.execute("brightnessctl set 3%+"); widgets.menu:refresh_numbers(); widgets.brightness:show() end, { description = "Increase brightness", group = "brightness" }),
		awful.key({ "Shift" }, "XF86MonBrightnessDown", function() os.execute("brightnessctl set 3%-"); widgets.menu:refresh_numbers(); widgets.brightness:show() end, { description = "Decrease brightness", group = "brightness" }),

		-- Volume
		awful.key({}, "XF86AudioLowerVolume", function() os.execute("pamixer --decrease 10"); widgets.menu:refresh_numbers(); widgets.volume:show() end, { description = "Lower Volume", group = "audio" }),
		awful.key({}, "XF86AudioRaiseVolume", function() os.execute("pamixer --increase 10"); widgets.menu:refresh_numbers(); widgets.volume:show() end, { description = "Raise Volume", group = "audio" }),
		awful.key({ "Shift" }, "XF86AudioLowerVolume", function() os.execute("pamixer --decrease 3"); widgets.menu:refresh_numbers(); widgets.volume:show() end, { description = "Lower Volume", group = "audio" }),
		awful.key({ "Shift" }, "XF86AudioRaiseVolume", function() os.execute("pamixer --increase 3"); widgets.menu:refresh_numbers(); widgets.volume:show() end, { description = "Raise Volume", group = "audio" }),
		awful.key({ "Control" }, "XF86AudioLowerVolume", function() os.execute("pamixer --set-volume 0"); widgets.menu:refresh_numbers(); widgets.volume:show() end, { description = "Mute volume", group = "audio" }),
		awful.key({ "Control" }, "XF86AudioRaiseVolume", function() os.execute("pamixer --set-volume 100"); widgets.menu:refresh_numbers(); widgets.volume:show() end, { description = "Mute volume", group = "audio" }),
		awful.key({}, "XF86AudioMute", function() os.execute("pamixer --set-volume 0"); widgets.menu:refresh_numbers(); widgets.volume:show() end, { description = "Mute volume", group = "audio" })
	)

	-- Client keys (These generally use mod + ctrl)
	public.clientkeys = gears.table.join(
		awful.key({ modkey, "Control" }, "f", f(function(c) c.fullscreen = not c.fullscreen end)),
		awful.key({ modkey, "Control" }, "q", function(c) c:kill() end),
		awful.key({ modkey, "Control" }, "m", function(c) c.maximized = not c.maximized c:raise() end)
	)

	-- Tags
	for tag_number = 1, 9 do
		public.globalkeys = gears.table.join(
			public.globalkeys,

			-- View tag only.
			awful.key(
				{ public.modkey },
				"#" .. tag_number + 9,
				f(function()
					local screen = awful.screen.focused()
					local tag = screen.tags[tag_number]
					if tag then
						tag:view_only()
						widgets.tags:refresh_numbers()
					end
				end),
				{ description = "view tag #" .. tag_number, group = "tag" }
			),

			-- Toggle tag display.
			awful.key({ public.modkey, "Control" }, "#" .. tag_number + 9, function()
				local screen = awful.screen.focused()
				local tag = screen.tags[tag_number]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end, { description = "toggle tag #" .. tag_number, group = "tag" }),

			-- Move client to tag.
			awful.key({ public.modkey, "Shift" }, "#" .. tag_number + 9, function()
				if client.focus then
					local tag = client.focus.screen.tags[tag_number]
					if tag then
						client.focus:move_to_tag(tag)
					end
				end
			end, { description = "move focused client to tag #" .. tag_number, group = "tag" }),

			-- Toggle tag on focused client.
			awful.key({ public.modkey, "Control", "Shift" }, "#" .. tag_number + 9, function()
				if client.focus then
					local tag = client.focus.screen.tags[tag_number]
					if tag then
						client.focus:toggle_tag(tag)
					end
				end
			end, { description = "toggle focused client on tag #" .. tag_number, group = "tag" })
		)
	end
end

-- stylua: ignore end

return public

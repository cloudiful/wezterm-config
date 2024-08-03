-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices
local os_name = ""
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	os_name = "windows"
elseif wezterm.target_triple == "aarch64-apple-darwin" then
	os_name = "macos"
end

-- if on Windows then use powershell
if os_name == "windows" then
	config.default_prog = { "pwsh.exe" }
end

-- theme
config.color_scheme = "Catppuccin Mocha"

-- font
-- need to install JetBrainsMono Nerd Font Mono first
config.font = wezterm.font_with_fallback({
	{ family = "JetBrainsMono Nerd Font Mono", weight = "Regular" },
	{ family = "霞鹜文楷等宽" },
})
config.font_size = 16

-- color
config.colors = {
	background = "black",
}

-- tab style
config.window_decorations = "INTEGRATED_BUTTONS"
config.use_fancy_tab_bar = true

-- padding
config.window_padding = {
	left = 10,
	right = 10,
	top = 0,
	bottom = 0,
}

-- add transparent blur to the window
if os_name == "windows" then
	-- available on Windows 11 build 22621 and later.
	config.window_background_opacity = 0.9
	config.win32_system_backdrop = "Auto"
elseif os_name == "macos" then
	local on_battery = false

	-- decide if using battery
	for _, b in ipairs(wezterm.battery_info()) do
		if b.state == "Discharging" then
			on_battery = true
		end
	end

	-- if not on battery then enable blur effect
	if not on_battery then
		config.window_background_opacity = 0.75
		config.macos_window_background_blur = 60
	else
		wezterm.log_info("Using battery, so no transparent blur effect for background.")
	end
end

-- startup wezterm in max size
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
	-- if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	-- 	local tab_wsl, pane_wsl, _ = window:spawn_tab({})
	--
	-- 	-- split tab into 3 panes
	-- 	local pane_wsl_r = pane_wsl:split({ direction = "Right" })
	-- 	local pane_wsl_rd = pane_wsl_r:split({ direction = "Bottom" })
	--
	-- 	-- set titles for the tabs
	-- 	tab:set_title("windows")
	-- 	tab_wsl:set_title("wsl")
	--
	-- 	-- connect to remote server
	-- 	pane_wsl:send_text("wsl\r\nclear\r\n")
	-- 	pane_wsl_r:send_text("wsl\r\nclear\r\n")
	-- 	pane_wsl_rd:send_text("wsl\r\nclear\r\n")
	--
	-- 	tab_wsl:activate()
	-- 	pane_wsl:activate()
	-- elseif wezterm.target_triple == "aarch64-apple-darwin" then
	-- 	local tab_nas, pane_nas, _ = window:spawn_tab({})
	--
	-- 	-- split tab into 3 panes
	-- 	local pane_r = pane:split({ direction = "Right" })
	-- 	local pane_rd = pane_r:split({ direction = "Bottom" })
	--
	-- 	-- set titles for the tabs
	-- 	tab:set_title("mac")
	-- 	tab_nas:set_title("nas")
	--
	-- 	-- connect to remote server
	-- 	pane_nas:send_text("ssh root@cloudiful.cn\nclear\n")
	--
	-- 	pane_nas:activate()
	-- end

	-- tab:activate()
	-- pane:activate()
end)

-- if on Windows uee ALT+wasd to switch pane
-- if on Mac use CTRL+wasd to switch pane
local switch_key_mods = ""
local clipboard_key_mods = ""
if os_name == "windows" then
	switch_key_mods = "ALT"
	clipboard_key_mods = "CTRL"
elseif os_name == "macos" then
	switch_key_mods = "CTRL"
	clipboard_key_mods = "CMD"
end

config.keys = {
	-- if in fullscreen terminal app
	-- then pass through clipboard_key_mods+c as CTRL+c
	-- which can be used in neovim to map keys
	{
		key = "c",
		mods = clipboard_key_mods,
		action = wezterm.action_callback(function(window, pane)
			if pane:is_alt_screen_active() then
				window:perform_action(wezterm.action.SendKey({ key = "c", mods = "CTRL" }), pane)
			else
				local has_selection = window:get_selection_text_for_pane(pane) ~= ""
				if has_selection then
					window:perform_action(wezterm.action.ClearSelection, pane)
				else
					window:perform_action(wezterm.action.SendKey({ key = "c", mods = clipboard_key_mods }), pane)
				end
			end
		end),
	},

	-- use clipboard_key_mods+v to paste from clipboard
	{
		key = "v",
		mods = clipboard_key_mods,
		action = wezterm.action_callback(function(window, pane)
			if pane:is_alt_screen_active() then
				window:perform_action(wezterm.action.SendKey({ key = "v", mods = "CTRL" }), pane)
			else
				window:perform_action(wezterm.action.PasteFrom("Clipboard"), pane)
			end
		end),
	},

	-- use clipboard_key_mods+s to save
	{
		key = "s",
		mods = clipboard_key_mods,
		action = wezterm.action_callback(function(window, pane)
			if pane:is_alt_screen_active() then
				window:perform_action(wezterm.action.SendKey({ key = "s", mods = "CTRL" }), pane)
			else
				pane:send_text("save")
			end
		end),
	},

	-- use clipboard_key_mods+z to undo
	{
		key = "z",
		mods = clipboard_key_mods,
		action = wezterm.action_callback(function(window, pane)
			if pane:is_alt_screen_active() then
				window:perform_action(wezterm.action.SendKey({ key = "z", mods = "CTRL" }), pane)
			end
		end),
	},

	-- use switch_key+wasd to switch pane
	{
		key = "w",
		mods = switch_key_mods,
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "a",
		mods = switch_key_mods,
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "s",
		mods = switch_key_mods,
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "d",
		mods = switch_key_mods,
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
}

-- and finally, return the configuration to wezterm
return config

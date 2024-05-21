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

-- if on Windows then use powershell
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_prog = { "powershell.exe" }
end

-- theme
config.color_scheme = "Catppuccin Mocha"

-- font
-- need to install JetBrainsMono Nerd Font Mono first
config.font = wezterm.font_with_fallback({
	{ family = "JetBrainsMono Nerd Font Mono", weight = "Regular" },
	{ family = "霞鹜文楷等宽" },
})
config.font_size = 15

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
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	-- available on Windows 11 build 22621 and later.
	config.window_background_opacity = 0
	config.win32_system_backdrop = "Mica"
elseif wezterm.target_triple == "aarch64-apple-darwin" then
	local on_battery = false

	for _, b in ipairs(wezterm.battery_info()) do
		if b.state == "Discharging" then
			on_battery = true
		end
	end

	if not on_battery then
		config.window_background_opacity = 0.75
		config.macos_window_background_blur = 60
	else
		wezterm.log_info("Using battery, so no transparent blur effect for background.")
	end
end

-- startup wezterm in max size
wezterm.on("gui-startup", function(cmd)
		if wezterm.target_triple == "x86_64-pc-windows-msvc" then
                local tab, pane, window = mux.spawn_window(cmd or {})
                local tab_wsl, pane_wsl, _ = window:spawn_tab({})
                window:gui_window():maximize()

                -- split tab into 3 panes
                local pane_wsl_r = pane_wsl:split({ direction = "Right" })
                local pane_wsl_rd = pane_wsl_r:split({ direction = "Bottom" })

                -- set titles for the tabs
                tab:set_title("windows")
                tab_wsl:set_title("wsl")

                -- connect to remote server
                pane_wsl:send_text("wsl\r\nclear\r\n")
                pane_wsl_r:send_text("wsl\r\nclear\r\n")
                pane_wsl_rd:send_text("wsl\r\nclear\r\n")

                pane_wsl.activate()
        elseif wezterm.target_triple == "aarch64-apple-darwin" then
			local tab_mac, pane_mac, window = mux.spawn_window(cmd or {})
	local tab_nas, pane_nas, _ = window:spawn_tab({})
	window:gui_window():maximize()

	-- split tab into 3 panes
	local pane_mac_r = pane_mac:split({ direction = "Right" })
	local pane_mac_rd = pane_mac_r:split({ direction = "Bottom" })
	local pane_nas_r = pane_nas:split({ direction = "Right" })
	local pane_nas_rd = pane_nas_r:split({ direction = "Bottom" })

	-- set titles for the tabs
	tab_mac:set_title("mac")
	tab_nas:set_title("nas")

	-- connect to remote server
	pane_nas:send_text("ssh root@cloudiful.cn\n")
	pane_nas:send_text("clear\n")
	pane_nas_r:send_text("ssh root@cloudiful.cn\n")
	pane_nas_r:send_text("clear\n")
	pane_nas_rd:send_text("ssh root@cloudiful.cn\n")
	pane_nas_rd:send_text("clear\n")
        end
	
end)

-- if on Windows uee ALT+wasd to switch pane
-- if on Mac use CTRL+wasd to switch pane
local switch_key_mods = ""
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	switch_key_mods = "ALT"
elseif wezterm.target_triple == "aarch64-apple-darwin" then
	switch_key_mods = "CTRL"
end

-- use switch_key+wasd to switch pane
config.keys = {
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

-- use switch_key+number to switch tabs
for i = 1, 8 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = switch_key_mods,
		action = wezterm.action.ActivateTab(i - 1),
	})
end

config.enable_kitty_keyboard = true

-- and finally, return the configuration to wezterm
return config

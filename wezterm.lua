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
config.font = wezterm.font_with_fallback({
	"JetBrains Mono",
	"霞鹜文楷等宽",
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
		config.window_background_opacity = 0.8
		config.macos_window_background_blur = 60
	else
		wezterm.log_info("Using battery, so no transparent blur effect for background.")
	end
end

-- startup wezterm in max size
wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

-- and finally, return the configuration to wezterm
return config

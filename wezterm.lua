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
config.font = wezterm.font("JetBrains Mono")
config.font_size = 15

-- tab style
config.window_decorations = "INTEGRATED_BUTTONS"
config.use_fancy_tab_bar = true

-- no padding
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- add transparent blur to the window
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	-- available on Windows 11 build 22621 and later.
	config.window_background_opacity = 0
	config.win32_system_backdrop = "Mica"
elseif wezterm.target_triple == "aarch64-apple-darwin" then
	-- config.window_background_opacity = 0.8
	-- config.macos_window_background_blur = 20
end

-- startup wezterm in max size
wezterm.on("gui-startup", function()
	local window = mux.spawn_window({})
	window:gui_window():maximize()
end)

-- and finally, return the configuration to wezterm
return config

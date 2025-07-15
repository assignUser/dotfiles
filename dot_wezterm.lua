local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.audible_bell = 'Disabled'

config.color_scheme = 'catppuccin-macchiato'
config.colors = {
	-- make text in cursor readable
	cursor_fg = '#1e1e2e',
	tab_bar = {
		inactive_tab_edge = '#1e2030',
		active_tab = {
			bg_color = '#24273a',
			fg_color = '#a5adcb',
		},
		inactive_tab = {
			bg_color = '#181926',
			fg_color = '#8087a2',
		},
		new_tab = {
			bg_color = '#181926',
			fg_color = '#8087a2',
		},
		inactive_tab_hover = {
			bg_color = '#494d64',
			fg_color = '#cad3f5',
		},
		new_tab_hover = {
			bg_color = '#494d64',
			fg_color = '#cad3f5',
		},
	},
}

config.window_frame = {
	active_titlebar_bg = '#1e2030',
}

-- config.font = wezterm.font 'FiraCode Nerd Font Mono'
-- config.font = wezterm.font 'Monaspace Argon'
config.font_size = 12

config.scrollback_lines = 50000
config.enable_scroll_bar = true

-- keybinds
local act = wezterm.action
config.leader = { key = ' ', mods = 'CTRL' }
config.keys = {
	{ key = 'f',          mods = 'LEADER',         action = act.Search { CaseInSensitiveString = '' } },
	{ key = '-',          mods = 'LEADER',         action = act.SplitVertical { domain = "CurrentPaneDomain" } },
	{ key = '|',          mods = 'LEADER|SHIFT',   action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
	{ key = 'z',          mods = 'LEADER',         action = act.TogglePaneZoomState },
	{ key = 'h',          mods = 'LEADER',         action = act.ActivatePaneDirection 'Left' },
	{ key = 'l',          mods = 'LEADER',         action = act.ActivatePaneDirection 'Right' },
	{ key = 'k',          mods = 'LEADER',         action = act.ActivatePaneDirection 'Up' },
	{ key = 'j',          mods = 'LEADER',         action = act.ActivatePaneDirection 'Down' },
	{ key = 'r',          mods = 'CTRL|SHIFT',     action = wezterm.action.ReloadConfiguration, },
	{ key = 'x',          mods = 'LEADER',         action = wezterm.action.CloseCurrentPane { confirm = true } },
	{ key = 'c',          mods = 'LEADER',         action = act.SpawnTab 'CurrentPaneDomain', },
	{ key = 'LeftArrow',  mods = 'ALT|CTRL|SHIFT', action = wezterm.action.AdjustPaneSize { "Left", 5 }, },
	{ key = 'RightArrow', mods = 'ALT|CTRL|SHIFT', action = wezterm.action.AdjustPaneSize { "Right", 5 }, },
	{ key = 'UpArrow',    mods = 'ALT|CTRL|SHIFT', action = wezterm.action.AdjustPaneSize { "Up", 5 }, },
	{ key = 'DownArrow',  mods = 'ALT|CTRL|SHIFT', action = wezterm.action.AdjustPaneSize { "Down", 5 }, },
}

-- copy and clear selection on mouse release
config.mouse_bindings = {
	{
		event = {
			Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.Multiple {
			act.CompleteSelectionOrOpenLinkAtMouseCursor 'ClipboardAndPrimarySelection',
			act.ClearSelection
		}
	}
}

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true

-- show icon when leader is active
wezterm.on('update-right-status', function(window, pane)
	local leader = ''
	if window:leader_is_active() then
		leader = '󰘀'
	end
	window:set_left_status(leader)
end)

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
local function basename(s)
	return string.gsub(s, '(.*[/\\])(.*)', '%2')
end


wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	-- Retrieve the title from the cache
	local pane = tab.active_pane
	if not pane then return '' end
	local cache = wezterm.GLOBAL.title_cache
	local cached = ''

	if cache then
		cached = cache[tostring(pane.pane_id)]
	end

	local title = cached ~= '' and cached or basename(pane.current_working_dir.file_path)

	-- Return the custom title or default to the default behavior
	return ' ' .. title .. ' '
end)

wezterm.on("update-right-status", function(window, pane)
	local cwd_url = pane:get_current_working_dir()

	if not cwd_url then return end

	local cwd = cwd_url.file_path

	-- Asynchronously determine if we are inside a git repository
	local success, stdout, stderr = wezterm.run_child_process { "git", "-C", cwd, "rev-parse", "--show-toplevel" }

	local title
	if success then
		-- Git command was successful; use the git root directory name
		title = basename(stdout)
	else
		title = ''
	end

	-- Update the cache for this pane
	local title_cache = wezterm.GLOBAL.title_cache
	if not title_cache then
		title_cache = {}
	end

	title_cache[tostring(pane:pane_id())] = title
	wezterm.GLOBAL.title_cache = title_cache
end)


return config

local wezterm = require('wezterm')
local act = wezterm.action

local terminal_panes = {}

return {
	font_size = 20.0,
	max_fps = 144,
	animation_fps = 1,
	cursor_blink_ease_in = 'Constant',
	cursor_blink_ease_out = 'Constant',
	cursor_blink_rate = 300,
	cursor_thickness = "1px",
	hide_tab_bar_if_only_one_tab = true,
	show_tab_index_in_tab_bar = false,
	tab_max_width = 100,
	default_prog = { "nu" },
	window_decorations = "INTEGRATED_BUTTONS",
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	window_background_gradient = {
		orientation = { Linear = { angle = -35.0 } },
		colors = {
			'#161316',
			'#221c25',
			'#1f2335',
			'#24283b',
		},
		blend = 'Hsv',
	},
	inactive_pane_hsb = {
		brightness = 0.3,
		saturation = 0.9,
	},
	colors = {

	},
	keys = {
		{
			key = '1',
			mods = 'ALT',
			action = wezterm.action_callback(function(_, pane)
				local tab = pane:tab()
				local tab_id = tab:tab_id()
				local terminal_pane = nil

				if terminal_panes[tab_id] ~= nil then
					local status, existing_pane = pcall(wezterm.mux.get_pane, terminal_panes[tab_id])
					if status then
						terminal_pane = existing_pane
					else
						terminal_pane = nil
					end
				end

				tab:set_zoomed(false)

				if terminal_pane == nil then
					terminal_pane = pane:split { direction = 'Bottom', top_level = true, size = 12 }
					terminal_panes[tab_id] = terminal_pane:pane_id()
				else
					if terminal_pane:pane_id() == tab:active_pane():pane_id() then
						for _, tab_pane in ipairs(tab:panes()) do
							if tab_pane:pane_id() ~= terminal_pane:pane_id() then
								tab_pane:activate()
								break
							end
						end
					else
						terminal_pane:activate()
					end
				end
			end),
		},

		{ key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
		{ key = 'Tab', mods = 'SHIFT|CTRL', action = act.ActivateTabRelative(-1) },
		{ key = 'Enter', mods = 'ALT', action = act.ToggleFullScreen },
		-- { key = '\"', mods = 'ALT|CTRL', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
		-- { key = '\"', mods = 'SHIFT|ALT|CTRL', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
		-- { key = '%', mods = 'ALT|CTRL', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
		-- { key = '%', mods = 'SHIFT|ALT|CTRL', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
		-- { key = '\'', mods = 'SHIFT|ALT|CTRL', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
		-- { key = '(', mods = 'CTRL', action = act.ActivateTab(-1) },
		-- { key = '(', mods = 'SHIFT|CTRL', action = act.ActivateTab(-1) },
		-- { key = ')', mods = 'CTRL', action = act.ResetFontSize },
		{ key = '+', mods = 'CTRL', action = act.IncreaseFontSize },
		{ key = '+', mods = 'SHIFT|CTRL', action = act.IncreaseFontSize },
		{ key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
		{ key = '-', mods = 'SHIFT|CTRL', action = act.DecreaseFontSize },
		{ key = '0', mods = 'CTRL', action = act.ResetFontSize },
		{ key = '0', mods = 'SHIFT|CTRL', action = act.ResetFontSize },
		{ key = '0', mods = 'SUPER', action = act.ResetFontSize },
		{ key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
		{ key = '=', mods = 'SHIFT|CTRL', action = act.IncreaseFontSize },
		{ key = '=', mods = 'SUPER', action = act.IncreaseFontSize },
		{ key = 'N', mods = 'SHIFT|CTRL', action = act.SpawnWindow },
		{ key = 'P', mods = 'SHIFT|CTRL', action = act.ActivateCommandPalette },
		{ key = 'T', mods = 'CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
		{ key = 'T', mods = 'SHIFT|CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
		{ key = '_', mods = 'CTRL', action = act.DecreaseFontSize },
		{ key = '_', mods = 'SHIFT|CTRL', action = act.DecreaseFontSize },
		{ key = 'l', mods = 'SHIFT|CTRL', action = act.ShowDebugOverlay },
		{ key = 't', mods = 'SHIFT|CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
		{ key = 'phys:Space', mods = 'SHIFT|CTRL', action = act.QuickSelect },
		{ key = 'PageUp', mods = 'SHIFT|CTRL', action = act.MoveTabRelative(-1) },
		{ key = 'PageDown', mods = 'SHIFT|CTRL', action = act.MoveTabRelative(1) },
		{ key = 'LeftArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Left' },
		{ key = 'LeftArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize { 'Left', 1 } },
		{ key = 'RightArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Right' },
		{ key = 'RightArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize { 'Right', 1 } },
		{ key = 'UpArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Up' },
		{ key = 'UpArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize { 'Up', 1 } },
		{ key = 'DownArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Down' },
		{ key = 'DownArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize { 'Down', 1 } },
		{ key = 'Insert', mods = 'SHIFT', action = act.PasteFrom 'PrimarySelection' },
		{ key = 'Insert', mods = 'CTRL', action = act.CopyTo 'PrimarySelection' },
		{ key = 'Copy', mods = 'NONE', action = act.CopyTo 'Clipboard' },
		{ key = 'Paste', mods = 'NONE', action = act.PasteFrom 'Clipboard' },
	},

	key_tables = {
		copy_mode = {
			{ key = 'Tab', mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
			{ key = 'Tab', mods = 'SHIFT', action = act.CopyMode 'MoveBackwardWord' },
			{ key = 'Enter', mods = 'NONE', action = act.CopyMode 'MoveToStartOfNextLine' },
			{ key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
			{ key = 'Space', mods = 'NONE', action = act.CopyMode { SetSelectionMode = 'Cell' } },
			{ key = '$', mods = 'NONE', action = act.CopyMode 'MoveToEndOfLineContent' },
			{ key = '$', mods = 'SHIFT', action = act.CopyMode 'MoveToEndOfLineContent' },
			{ key = ',', mods = 'NONE', action = act.CopyMode 'JumpReverse' },
			{ key = '0', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLine' },
			{ key = ';', mods = 'NONE', action = act.CopyMode 'JumpAgain' },
			{ key = 'F', mods = 'NONE', action = act.CopyMode { JumpBackward = { prev_char = false } } },
			{ key = 'F', mods = 'SHIFT', action = act.CopyMode { JumpBackward = { prev_char = false } } },
			{ key = 'G', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackBottom' },
			{ key = 'G', mods = 'SHIFT', action = act.CopyMode 'MoveToScrollbackBottom' },
			{ key = 'H', mods = 'NONE', action = act.CopyMode 'MoveToViewportTop' },
			{ key = 'H', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportTop' },
			{ key = 'L', mods = 'NONE', action = act.CopyMode 'MoveToViewportBottom' },
			{ key = 'L', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportBottom' },
			{ key = 'M', mods = 'NONE', action = act.CopyMode 'MoveToViewportMiddle' },
			{ key = 'M', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportMiddle' },
			{ key = 'O', mods = 'NONE', action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },
			{ key = 'O', mods = 'SHIFT', action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },
			{ key = 'T', mods = 'NONE', action = act.CopyMode { JumpBackward = { prev_char = true } } },
			{ key = 'T', mods = 'SHIFT', action = act.CopyMode { JumpBackward = { prev_char = true } } },
			{ key = 'V', mods = 'NONE', action = act.CopyMode { SetSelectionMode = 'Line' } },
			{ key = 'V', mods = 'SHIFT', action = act.CopyMode { SetSelectionMode = 'Line' } },
			{ key = '^', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLineContent' },
			{ key = '^', mods = 'SHIFT', action = act.CopyMode 'MoveToStartOfLineContent' },
			{ key = 'b', mods = 'NONE', action = act.CopyMode 'MoveBackwardWord' },
			{ key = 'b', mods = 'ALT', action = act.CopyMode 'MoveBackwardWord' },
			{ key = 'b', mods = 'CTRL', action = act.CopyMode 'PageUp' },
			{ key = 'c', mods = 'CTRL', action = act.CopyMode 'Close' },
			{ key = 'd', mods = 'CTRL', action = act.CopyMode { MoveByPage = (0.5) } },
			{ key = 'e', mods = 'NONE', action = act.CopyMode 'MoveForwardWordEnd' },
			{ key = 'f', mods = 'NONE', action = act.CopyMode { JumpForward = { prev_char = false } } },
			{ key = 'f', mods = 'ALT', action = act.CopyMode 'MoveForwardWord' },
			{ key = 'f', mods = 'CTRL', action = act.CopyMode 'PageDown' },
			{ key = 'g', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackTop' },
			{ key = 'g', mods = 'CTRL', action = act.CopyMode 'Close' },
			{ key = 'h', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
			{ key = 'j', mods = 'NONE', action = act.CopyMode 'MoveDown' },
			{ key = 'k', mods = 'NONE', action = act.CopyMode 'MoveUp' },
			{ key = 'l', mods = 'NONE', action = act.CopyMode 'MoveRight' },
			{ key = 'm', mods = 'ALT', action = act.CopyMode 'MoveToStartOfLineContent' },
			{ key = 'o', mods = 'NONE', action = act.CopyMode 'MoveToSelectionOtherEnd' },
			{ key = 'q', mods = 'NONE', action = act.CopyMode 'Close' },
			{ key = 't', mods = 'NONE', action = act.CopyMode { JumpForward = { prev_char = true } } },
			{ key = 'u', mods = 'CTRL', action = act.CopyMode { MoveByPage = (-0.5) } },
			{ key = 'v', mods = 'NONE', action = act.CopyMode { SetSelectionMode = 'Cell' } },
			{ key = 'v', mods = 'CTRL', action = act.CopyMode { SetSelectionMode = 'Block' } },
			{ key = 'w', mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
			{ key = 'y', mods = 'NONE',
				action = act.Multiple { { CopyTo = 'ClipboardAndPrimarySelection' }, { CopyMode = 'Close' } } },
			{ key = 'PageUp', mods = 'NONE', action = act.CopyMode 'PageUp' },
			{ key = 'PageDown', mods = 'NONE', action = act.CopyMode 'PageDown' },
			{ key = 'End', mods = 'NONE', action = act.CopyMode 'MoveToEndOfLineContent' },
			{ key = 'Home', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLine' },
			{ key = 'LeftArrow', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
			{ key = 'LeftArrow', mods = 'ALT', action = act.CopyMode 'MoveBackwardWord' },
			{ key = 'RightArrow', mods = 'NONE', action = act.CopyMode 'MoveRight' },
			{ key = 'RightArrow', mods = 'ALT', action = act.CopyMode 'MoveForwardWord' },
			{ key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'MoveUp' },
			{ key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'MoveDown' },
		},

		search_mode = {
			{ key = 'Enter', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
			{ key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
			{ key = 'n', mods = 'CTRL', action = act.CopyMode 'NextMatch' },
			{ key = 'p', mods = 'CTRL', action = act.CopyMode 'PriorMatch' },
			{ key = 'r', mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
			{ key = 'u', mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
			{ key = 'PageUp', mods = 'NONE', action = act.CopyMode 'PriorMatchPage' },
			{ key = 'PageDown', mods = 'NONE', action = act.CopyMode 'NextMatchPage' },
			{ key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
			{ key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'NextMatch' },
		},

	}
}

local wezterm = require 'wezterm'
local act = wezterm.action

local function cwd_from_uri(uri)
  if not uri then
    return ''
  end

  local path = uri.file_path or uri.path or tostring(uri)
  if path:sub(1, 7) == 'file://' then
    path = path:gsub('^file://[^/]*', '')
  end

  local home = wezterm.home_dir
  if home and path:sub(1, #home) == home then
    path = '~' .. path:sub(#home + 1)
  end

  return path
end

local function basename(path)
  return path:match('([^/]+)$') or path
end

wezterm.on('format-tab-title', function(tab)
  local cwd = cwd_from_uri(tab.active_pane.current_working_dir)
  local label = cwd ~= '' and (' ' .. basename(cwd) .. ' ') or ' shell '
  local bg = tab.is_active and '#2a2f45' or '#161821'
  local fg = tab.is_active and '#c0caf5' or '#6b7089'

  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = label },
  }
end)

wezterm.on('update-right-status', function(window, pane)
  local cwd = cwd_from_uri(pane:get_current_working_dir())
  window:set_right_status(wezterm.format({
    { Foreground = { Color = '#7aa2f7' } },
    { Text = cwd ~= '' and (' ' .. cwd .. ' ') or '' },
  }))
end)

return {
  default_prog = { '/opt/homebrew/bin/bash', '-l' },
  font = wezterm.font('CaskaydiaCove Nerd Font'),
  font_size = 13.0,
  colors = {
    foreground = '#c0caf5',
    background = '#0b1020',
    cursor_bg = '#c0caf5',
    cursor_fg = '#0b1020',
    cursor_border = '#c0caf5',
    selection_bg = '#2a325a',
    selection_fg = '#c0caf5',
    scrollbar_thumb = '#2a2f45',
    split = '#2a2f45',
    ansi = {
      '#151a2d',
      '#f7768e',
      '#9ece6a',
      '#e0af68',
      '#7aa2f7',
      '#bb9af7',
      '#7dcfff',
      '#a9b1d6',
    },
    brights = {
      '#414868',
      '#ff7a93',
      '#b9f27c',
      '#ffcf70',
      '#7fb8ff',
      '#c7a9ff',
      '#a4daff',
      '#cbd5ff',
    },
    tab_bar = {
      background = '#0b1020',
      active_tab = {
        bg_color = '#2a2f45',
        fg_color = '#c0caf5',
      },
      inactive_tab = {
        bg_color = '#161821',
        fg_color = '#6b7089',
      },
      inactive_tab_hover = {
        bg_color = '#1d2238',
        fg_color = '#a9b1d6',
      },
      new_tab = {
        bg_color = '#0b1020',
        fg_color = '#7aa2f7',
      },
      new_tab_hover = {
        bg_color = '#161821',
        fg_color = '#c0caf5',
      },
    },
  },
  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = false,
  tab_max_width = 32,
  scrollback_lines = 20000,
  adjust_window_size_when_changing_font_size = false,
  native_macos_fullscreen_mode = false,
  window_background_opacity = 0.96,
  text_background_opacity = 1.0,
  use_resize_increments = true,
  window_padding = {
    left = 10,
    right = 10,
    top = 8,
    bottom = 8,
  },
  inactive_pane_hsb = {
    saturation = 0.85,
    brightness = 0.7,
  },
  keys = {
    { key = 'Enter', mods = 'CMD', action = act.ToggleFullScreen },
    { key = 'd', mods = 'CMD|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'D', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'k', mods = 'CMD', action = act.ClearScrollback 'ScrollbackAndViewport' },
  },
}

local reload_buf = nil
local reload_win = nil

--[[
    Spinning Donut by Andrew Li
    Ported from donut.c - https://www.a1k0n.net/2011/07/20/donut-math.html
]]

local theta_spacing = 0.07
local phi_spacing = 0.02

local a = 0
local ba = 0
local donut_chars = { ".", ",", "-", "~", ":", ";", "=", "!", "*", "#", "$", "@" }
local z = {}
local b = {}

local function donut_to_nvim_buf(buf)
  local i, j
  j = 0
  -- zeros arrays
  for l = 1, 1760 do
    z[l] = 0
  end
  for t = 1, 1760 do
    b[t] = " "
  end
  -- calculate donut
  while j < 6.28 do
    j = j + theta_spacing
    i = 0
    while i < 6.28 do
      i = i + phi_spacing

      local c, d, e, f, g, h, D, l, m, n, t, x, y, o, N
      c = math.sin(i)
      l = math.cos(i)
      d = math.cos(j)
      f = math.sin(j)

      e = math.sin(a)
      g = math.cos(a)
      h = d + 2
      D = 1 / (c * h * e + f * g + 5)

      m = math.cos(ba)
      n = math.sin(ba)
      t = c * h * g - f * e

      x = math.floor(40 + 30 * D * (l * h * m - t * n))
      y = math.floor(12 + 15 * D * (l * h * n + t * m))
      o = math.floor(x + (80 * y))
      N = math.floor(8 * ((f * e - c * d * g) * m - c * d * e - f * g - l * d * n))

      if 22 > y and y > 0 and 80 > x and x > 0 and D > z[o + 1] then
        z[o + 1] = D
        if N > 0 then
          b[o + 1] = donut_chars[N + 1]
        else
          b[o + 1] = "."
        end
      end
    end
  end

  -- print
  local buf_lines = { "" }
  local buf_lines_idx = 1
  for l = 1, 1760 do
    if l % 80 ~= 0 then
      -- io.write(tostring(b[l]))
      buf_lines[buf_lines_idx] = buf_lines[buf_lines_idx] .. tostring(b[l])
    else
      -- print()
      table.insert(buf_lines, "")
      buf_lines_idx = buf_lines_idx + 1
    end
  end

  vim.api.nvim_buf_set_lines(buf, 0, buf_lines_idx, false, buf_lines)

  -- increments
  a = a + 0.04
  ba = ba + 0.02
end

local function update_reloading_dialog(_)
  donut_to_nvim_buf(reload_buf)
end

local reloading_timer = nil
local function close_reloading_dialog()
  if reload_win ~= nil then
    vim.api.nvim_win_close(reload_win, true)
  end
  if reloading_timer ~= nil then
    reloading_timer:stop()
  end

  reloading_timer = nil
  reload_win = nil
  reload_buf = nil
end

local function open_reloading_dialog()
  reload_buf = vim.api.nvim_create_buf(false, true)
  local ui = vim.api.nvim_list_uis()[1]

  -- local width = math.max(math.floor(ui.width * 0.5), 120)
  -- local height = math.max(math.floor(ui.height * 0.5), 20)
  local width = 80
  local height = 24

  update_reloading_dialog()

  reload_win = vim.api.nvim_open_win(reload_buf, true, {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    width = width,
    height = height,
    row = (ui.height / 2) - (height / 2),
    col = (ui.width / 2) - (width / 2),
    noautocmd = true,
  })

  if reloading_timer ~= nil then
    reloading_timer:stop()
  end

  reloading_timer = vim.loop.new_timer()
  reloading_timer:start(10, 10, vim.schedule_wrap(update_reloading_dialog))
end

local function run_init_ps1(callback)
  local init_dir = vim.fn.environ().USERPROFILE .. "\\projects\\zaucy\\init"

  vim.loop.spawn("pwsh", {
    cwd = init_dir,
    args = { "init.ps1" },
    hide = true,
  }, function()
    vim.schedule(function()
      callback()
    end)
  end)
end

local function reopen_neovide_detached()
  local current_file = vim.fn.expand("%:p")
  local args = { "--", "+ReloadDone" .. tostring(vim.uv.os_getppid()) }

  if current_file then
    table.insert(args, "--")
    table.insert(args, current_file)
  end

  local handle = vim.uv.spawn("neovide", {
    cwd = vim.fn.getcwd(),
    args = args,
    detached = true,
    hide = true,
  })

  ---@diagnostic disable-next-line: need-check-nil
  handle:unref()
end

local function reload_command()
  local sysname = vim.loop.os_uname().sysname

  if sysname == "Windows_NT" then
    open_reloading_dialog()
    run_init_ps1(function()
      if vim.g.neovide then
        reopen_neovide_detached()
      end
      vim.cmd(":qa!")
    end)
  end
end

local function reload_done_command(opts)
  if vim.g.neovide then
    vim.cmd(":NeovideFocus")
  end

  local reload_pid = tonumber(opts.fargs[1])

  ---@diagnostic disable-next-line: param-type-mismatch
  vim.uv.kill(reload_pid, "sigkill")
end

if not vim.g.vscode then
  vim.api.nvim_create_user_command("Reload", reload_command, {})
  vim.api.nvim_create_user_command("ReloadDone", reload_done_command, { nargs = 1 })
end

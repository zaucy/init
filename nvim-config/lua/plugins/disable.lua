local function map(tbl, f)
  local t = {}
  for k, v in pairs(tbl) do
    t[k] = f(v)
  end
  return t
end

return map({
  "akinsho/bufferline.nvim",
  "RRethy/vim-illuminate",
  "nvimdev/dashboard-nvim",
  "folke/flash.nvim",
  "folke/trouble.nvim",
}, function(m)
  return { m, enabled = false }
end)

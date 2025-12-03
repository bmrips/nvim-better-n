local M = {}

local function setup_default_mappings()
  local better_n = require("better-n")

  local f = better_n.create({ initiate = "f", next = ";", previous = "," })
  vim.keymap.set({ "n", "x" }, "f", f.initiate, { expr = true, silent = true })

  local F = better_n.create({ initiate = "F", next = ";", previous = "," })
  vim.keymap.set({ "n", "x" }, "F", F.initiate, { expr = true, silent = true })

  local t = better_n.create({ initiate = "t", next = ";", previous = "," })
  vim.keymap.set({ "n", "x" }, "t", t.initiate, { expr = true, silent = true })

  local T = better_n.create({ initiate = "T", next = ";", previous = "," })
  vim.keymap.set({ "n", "x" }, "T", T.initiate, { expr = true, silent = true })

  local asterisk = better_n.create({ initiate = "*", next = "n", previous = "<s-n>" })
  vim.keymap.set({ "n", "x" }, "*", asterisk.initiate, { expr = true, silent = true })

  local hash = better_n.create({ initiate = "#", next = "n", previous = "<s-n>" })
  vim.keymap.set({ "n", "x" }, "#", hash.initiate, { expr = true, silent = true })
end

local function setup_cmdline_mappings()
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    pattern = { "/", "\\?" },
    desc = "Restore n/N after searching",
    callback = function()
      if vim.v.event.abort then
        return
      end

      -- vim.keymap.del throws an error if n/N are not mapped
      pcall(vim.keymap.del, { "n", "x" }, "n")
      pcall(vim.keymap.del, { "n", "x" }, "<S-n>")
    end,
  })
end

local defaults = {
  disable_default_mappings = false,
  disable_cmdline_mappings = false,
}

function M.apply(opts)
  local config = vim.tbl_deep_extend("keep", opts, defaults)

  if not config.disable_cmdline_mappings then
    setup_cmdline_mappings()
  end

  if not config.disable_default_mappings then
    setup_default_mappings()
  end
end

return M

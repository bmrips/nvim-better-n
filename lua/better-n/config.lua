local motion = require("better-n.motion")

local M = {}

local function preserve_builtins()
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    pattern = { "/", "\\?" },
    desc = "Restore n/N after searching",
    callback = function()
      if vim.v.event.abort then
        return
      end
      motion.reset_nN()
    end,
  })

  for _, key in ipairs { "*", "g*", "#", "g#" } do
    vim.keymap.set({ "n", "x" }, key, function()
      motion.reset_nN()
      return key
    end, { expr = true })
  end
end

local function integrate_fFtT()
  local f = motion.create({ initiate = "f", next = ";", previous = "," })
  vim.keymap.set(f.modes, "f", f.initiate, f.map_args)

  local F = motion.create({ initiate = "F", next = ";", previous = "," })
  vim.keymap.set(F.modes, "F", F.initiate, F.map_args)

  local t = motion.create({ initiate = "t", next = ";", previous = "," })
  vim.keymap.set(t.modes, "t", t.initiate, t.map_args)

  local T = motion.create({ initiate = "T", next = ";", previous = "," })
  vim.keymap.set(T.modes, "T", T.initiate, T.map_args)
end

local defaults = {
  preserve_builtins = true,
  integrations = {
    fFtT = true,
  },
}

function M.apply(opts)
  local config = vim.tbl_deep_extend("keep", opts, defaults)

  if config.preserve_builtins then
    preserve_builtins()
  end

  if config.integrations.fFtT then
    integrate_fFtT()
  end
end

return M

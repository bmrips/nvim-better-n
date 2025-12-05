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

  local builtins = {
    ["*"] = "Search word forward",
    ["g*"] = "Search string forward",
    ["#"] = "Search word backward",
    ["g#"] = "Search string backward",
  }

  for key, desc in pairs(builtins) do
    vim.keymap.set({ "n", "x" }, key, function()
      motion.reset_nN()
      return key
    end, { expr = true, desc = desc })
  end
end

local function integrate_fFtT()
  local f = motion.create {
    initiate = "f",
    next = ";",
    previous = ",",
    map_args = { desc = "Move to next char" },
  }
  vim.keymap.set(f.modes, "f", f.initiate, f.map_args)

  local F = motion.create {
    initiate = "F",
    next = ";",
    previous = ",",
    map_args = { desc = "Move to prev char" },
  }
  vim.keymap.set(F.modes, "F", F.initiate, F.map_args)

  local t = motion.create {
    initiate = "t",
    next = ";",
    previous = ",",
    map_args = { desc = "Move before next char" },
  }
  vim.keymap.set(t.modes, "t", t.initiate, t.map_args)

  local T = motion.create {
    initiate = "T",
    next = ";",
    previous = ",",
    map_args = { desc = "Move before prev char" },
  }
  vim.keymap.set(T.modes, "T", T.initiate, T.map_args)
end

---@class better-n.opts
---@field integrations? table<string,boolean> Which integrations to enable
---@field preserve_builtins? boolean Whether to preserve n/N behaviour for /,?,*,g*,#,g#
local defaults = {
  preserve_builtins = true,
  integrations = {
    fFtT = true,
  },
}

local function is_dict_of_toggles(table)
  if #table > 0 then
    return false
  end
  for k, v in pairs(table) do
    if type(k) ~= "string" then
      return false
    end
    if type(v) ~= "boolean" then
      return false
    end
  end
  return true
end

local function validate(opts)
  vim.validate("integrations", opts.integrations, "table", true)
  vim.validate("integrations", opts.integrations, is_dict_of_toggles, true, "table<string,boolean>")
  vim.validate("preserve_builtins", opts.preserve_builtins, "boolean", true)
end

---@param opts better-n.opts
function M.apply(opts)
  validate(opts)
  local config = vim.tbl_deep_extend("keep", opts, defaults)

  if config.preserve_builtins then
    preserve_builtins()
  end

  if config.integrations.fFtT then
    integrate_fFtT()
  end
end

return M

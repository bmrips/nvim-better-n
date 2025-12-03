local Keymap = require("better-n.lib.keymap")

local M = {}

function M.create(opts)
  local initiate = opts.initiate or opts.next or error("opts.next or opts.initiate is required" .. vim.inspect(opts))
  local next = opts.next or error("opts.next is required" .. vim.inspect(opts))
  local previous = opts.previous or error("opts.previous is required" .. vim.inspect(opts))
  local bufnr = opts.bufnr or 0
  local remap = opts.remap or false
  local mode = opts.mode or "n"

  -- If `remap` is set and the action is a key (i.e. a string), extract its
  -- right-hand side.
  if remap then
    local keymap = Keymap:new(mode, bufnr)
    next = type(next) == "string" and keymap:rhs_of(next) or next
    previous = type(previous) == "string" and keymap:rhs_of(previous) or previous
  end

  local function go(action)
    return function()
      vim.keymap.set({ "n", "x" }, "n", next, { silent = true, nowait = true })
      vim.keymap.set({ "n", "x" }, "<S-n>", previous, { silent = true, nowait = true })
      return type(action) == "function" and vim.schedule(action) or action
    end
  end

  return {
    initiate = go(initiate),
    next = go(next),
    previous = go(previous),
  }
end

return M

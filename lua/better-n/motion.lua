local Keymap = require("better-n.lib.keymap")

local M = {}

function M.create(opts)
  local initiate = opts.initiate or opts.next or error("opts.next or opts.initiate is required" .. vim.inspect(opts))
  local next = opts.next or error("opts.next is required" .. vim.inspect(opts))
  local previous = opts.previous or error("opts.previous is required" .. vim.inspect(opts))
  local mode = opts.mode or "n"
  local map_args = opts.map_args or {}

  map_args.silent = true

  if type(map_args.buffer) == "boolean" then
    map_args.buffer = map_args.buffer and 0 or nil
  end

  -- If `map_args.remap` is set, unset it since we handle it here: for every
  -- action that is a key (i.e. a string), extract its right-hand side.
  if map_args.remap then
    map_args.remap = nil
    local keymap = Keymap:new(mode, map_args.buffer)
    next = type(next) == "string" and keymap:rhs_of(next) or next
    previous = type(previous) == "string" and keymap:rhs_of(previous) or previous
  end

  local function go(action)
    return function()
      vim.keymap.set({ "n", "x" }, "n", next, map_args)
      vim.keymap.set({ "n", "x" }, "<S-n>", previous, map_args)
      return type(action) == "function" and vim.schedule(action) or action
    end
  end

  -- set <expr> since the callback returned by `go()` may return a key
  local go_map_args = vim.deepcopy(map_args)
  go_map_args.expr = true

  return {
    initiate = go(initiate),
    next = go(next),
    previous = go(previous),
    map_args = go_map_args,
  }
end

return M

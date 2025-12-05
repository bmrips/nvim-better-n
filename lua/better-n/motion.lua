local Keymap = require("better-n.lib.keymap")

local M = {}

local scope = {
  buffer = nil,
  modes = {},
}

function M.reset_nN()
  -- vim.keymap.del throws an error if n/N are not mapped
  pcall(vim.keymap.del, scope.modes, "n", { buffer = scope.buffer })
  pcall(vim.keymap.del, scope.modes, "<S-n>", { buffer = scope.buffer })
end

local function is_key(value)
  return type(value) == "string"
end

function M.create(opts)
  local initiate = opts.initiate or opts.next or error("opts.next or opts.initiate is required" .. vim.inspect(opts))
  local next = opts.next or error("opts.next is required" .. vim.inspect(opts))
  local previous = opts.previous or error("opts.previous is required" .. vim.inspect(opts))
  local modes = opts.modes or { "n", "o", "x" }
  local map_args = opts.map_args or {}

  if type(map_args.buffer) == "boolean" then
    map_args.buffer = map_args.buffer and vim.api.nvim_get_current_buf() or nil
  elseif map_args.buffer == 0 then
    map_args.buffer = vim.api.nvim_get_current_buf()
  end

  -- If `map_args.remap` is set, unset it since we handle it here: for every
  -- action that is a key (i.e. a string), extract its right-hand side.
  if map_args.remap then
    map_args.remap = nil
    local keymap = Keymap:new("n", map_args.buffer)
    next = is_key(next) and keymap:rhs_of(next) or next
    previous = is_key(previous) and keymap:rhs_of(previous) or previous
  end

  local function go(action)
    return function()
      M.reset_nN()

      local n_map_args = vim.tbl_extend("force", map_args, { desc = "Repeat motion" })
      vim.keymap.set(modes, "n", next, n_map_args)

      local N_map_args = vim.tbl_extend("force", map_args, { desc = "Repeat opposite motion" })
      vim.keymap.set(modes, "<S-n>", previous, N_map_args)

      scope = {
        buffer = map_args.buffer,
        modes = modes,
      }

      return type(action) == "function" and action() or action
    end
  end

  -- If one of the actions is a key, set <expr> since the callback returned by
  -- `go()` returns that key.
  local go_map_args = vim.deepcopy(map_args)
  go_map_args.expr = map_args.expr or is_key(initiate) or is_key(next) or is_key(previous)

  return {
    initiate = go(initiate),
    next = go(next),
    previous = go(previous),
    modes = modes,
    map_args = go_map_args,
  }
end

return M

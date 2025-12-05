local Keymap = require("better-n.lib.keymap")

local M = {}

local scope = {
  buffer = nil,
  modes = {},
}

---@return nil
function M.reset_nN()
  -- vim.keymap.del throws an error if n/N are not mapped
  pcall(vim.keymap.del, scope.modes, "n", { buffer = scope.buffer })
  pcall(vim.keymap.del, scope.modes, "<S-n>", { buffer = scope.buffer })
end

local function is_key(value)
  return type(value) == "string"
end

---@class better-n.motion.opts
---@field initiate? string|fun():string? Action that initiates the motion
---@field next string|fun():string? Action that moves to the next occurrence
---@field previous string|fun():string? Action that moves to the previous occurrence
---@field modes? string|string[] The modes in which the motion is available
---@field map_args? vim.keymap.set.Opts Mapping arguments

local function validate(opts)
  vim.validate("initiate", opts.initiate, { "string", "function" }, true)
  vim.validate("next", opts.next, { "string", "function" })
  vim.validate("previous", opts.previous, { "string", "function" })
  vim.validate("modes", opts.modes, { "string", "table" }, true)
  vim.validate("map_args", opts.map_args, "table", true)
end

local function defaults(opts)
  return {
    initiate = opts.next,
    modes = { "n", "o", "x" },
    map_args = {},
  }
end

---@class better-n.motion.config
---@field initiate string|fun():string? Action that initiates the motion
---@field next string|fun():string? Action that moves to the next occurrence
---@field previous string|fun():string? Action that moves to the previous occurrence
---@field modes string|string[] The modes in which the motion is available
---@field map_args vim.keymap.set.Opts Mapping arguments

---@param opts better-n.motion.opts
---@return better-n.motion.config
function M.create(opts)
  validate(opts)
  local cfg = vim.tbl_extend("keep", opts, defaults(opts))

  if type(cfg.map_args.buffer) == "boolean" then
    cfg.map_args.buffer = cfg.map_args.buffer and vim.api.nvim_get_current_buf() or nil
  elseif cfg.map_args.buffer == 0 then
    cfg.map_args.buffer = vim.api.nvim_get_current_buf()
  end

  -- If `map_args.remap` is set, unset it since we handle it here: for every
  -- action that is a key (i.e. a string), extract its right-hand side.
  if cfg.map_args.remap then
    cfg.map_args.remap = nil
    local keymap = Keymap:new("n", cfg.map_args.buffer)
    cfg.next = is_key(cfg.next) and keymap:rhs_of(cfg.next) or cfg.next
    cfg.previous = is_key(cfg.previous) and keymap:rhs_of(cfg.previous) or cfg.previous
  end

  local function go(action)
    return function()
      M.reset_nN()

      local n_map_args = vim.tbl_extend("force", cfg.map_args, { desc = "Repeat motion" })
      vim.keymap.set(cfg.modes, "n", cfg.next, n_map_args)

      local N_map_args = vim.tbl_extend("force", cfg.map_args, { desc = "Repeat opposite motion" })
      vim.keymap.set(cfg.modes, "<S-n>", cfg.previous, N_map_args)

      scope = {
        buffer = cfg.map_args.buffer,
        modes = cfg.modes,
      }

      return type(action) == "function" and action() or action
    end
  end

  -- If one of the actions is a key, set <expr> since the callback returned by
  -- `go()` returns that key.
  local go_map_args = vim.deepcopy(cfg.map_args)
  go_map_args.expr = cfg.map_args.expr or is_key(cfg.initiate) or is_key(cfg.next) or is_key(cfg.previous)

  return {
    initiate = go(cfg.initiate),
    next = go(cfg.next),
    previous = go(cfg.previous),
    modes = cfg.modes,
    map_args = go_map_args,
  }
end

return M

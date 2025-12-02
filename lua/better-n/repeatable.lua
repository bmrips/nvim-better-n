local Keymap = require("better-n.lib.keymap")

local Repeatable = {}

function Repeatable:new(opts)
  local instance = vim.tbl_extend("error", opts, {
    initiate_action = opts.initiate,
    next_action = opts.next,
    previous_action = opts.previous,
  })

  -- If `opts.remap` is set and the action is a key (i.e. a string), extract its
  -- right-hand side.
  if opts.remap then
    local keymap = Keymap:new(opts.mode, opts.bufnr)
    instance.next_action = type(opts.next) == "string" and keymap:rhs_of(opts.next) or opts.next
    instance.previous_action = type(opts.previous) == "string" and keymap:rhs_of(opts.previous) or opts.previous
  end

  setmetatable(instance, Repeatable)

  instance.next = function()
    return instance:_run_action(instance.next_action)
  end
  instance.previous = function()
    return instance:_run_action(instance.previous_action)
  end
  instance.initiate = function()
    return instance:_run_action(instance.initiate_action)
  end

  return instance
end

Repeatable.__index = Repeatable

function Repeatable:_run_action(action)
  vim.api.nvim_exec_autocmds("User", {
    pattern = { "BetterNNext", "BetterNMappingExecuted" },
    data = { repeatable_id = self.id, key = self.id, mode = vim.fn.mode() },
  })

  if type(action) == "function" then
    return vim.schedule(action)
  else
    return action
  end
end

return Repeatable

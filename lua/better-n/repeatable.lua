local Keymap = require("better-n.lib.keymap")

local Repeatable = {}

function Repeatable:new(opts)
  local instance = vim.tbl_extend('error', opts, {
    initiate_action = opts.initiate,
  })

  setmetatable(instance, Repeatable)

  local keymap = Keymap:new({bufnr = opts.bufnr, mode = instance.mode})
  local next_action = opts.next
  local previous_action = opts.previous

  -- Extract the actual action from the keymap if it's a string.
  if type(next_action) == "string" then
    next_action = (keymap[next_action] or {}).rhs or next_action
  end

  if type(previous_action) == "string" then
    previous_action = (keymap[previous_action] or {}).rhs or previous_action
  end

  instance.next_action = next_action
  instance.previous_action = previous_action

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

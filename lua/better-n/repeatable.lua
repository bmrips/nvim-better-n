local Keymap = require("better-n.lib.keymap")

local Repeatable = {}

function Repeatable:new(opts)
  local instance = {
    register = opts.register or error("opts.register is required" .. vim.inspect(opts)),
    passthrough_action = opts.passthrough or error("opts.passthrough is required" .. vim.inspect(opts)),
    id = opts.id or opts.register:_num_repeatables(),
    mode = opts.mode,
    bufnr = opts.bufnr
  }

  setmetatable(instance, Repeatable)

  local keymap = Keymap:new({bufnr = opts.bufnr, mode = instance.mode})
  local next_action = opts.next or error("opts.next is required" .. vim.inspect(opts))
  local previous_action = opts.previous or error("opts.previous or opts.prev is required" .. vim.inspect(opts))

  -- Extract the actual action from the keymap if it's a string.
  -- This is more robust, and solves some remap issues that can otherwise occur.
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
  instance.passthrough = function()
    return instance:_run_action(instance.passthrough_action)
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

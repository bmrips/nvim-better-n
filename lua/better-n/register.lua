local Repeatable = require("better-n.repeatable")

local augroup = vim.api.nvim_create_augroup("BetterN", {})

local Register = {}

function Register:new()
  local instance = {
    last_repeatable_id = nil,
    repeatables = {},
  }

  setmetatable(instance, self)
  self.__index = self

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = augroup,
    callback = function(args)
      local abort = vim.v.event.abort
      local cmdline_char = args.match

      if not abort and instance.repeatables[cmdline_char] ~= nil then
        instance.last_repeatable_id = cmdline_char
      end
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = augroup,
    pattern = { "BetterNMappingExecuted" },
    callback = function(args)
      instance.last_repeatable_id = args.data.repeatable_id
    end,
  })

  return instance
end

function Register:create(opts)
  local repeatable = Repeatable:new({
    register = self,
    bufnr = opts.bufnr or 0,
    next = opts.next,
    previous = opts.previous,
    passthrough = opts.initiate or opts.next,
    mode = opts.mode or "n",
    id = opts.id,
  })

  self.repeatables[repeatable.id] = repeatable

  return repeatable
end

function Register:next()
  if self.last_repeatable_id == nil then
    return
  end

  return self.repeatables[self.last_repeatable_id]:next()
end

function Register:previous()
  if self.last_repeatable_id == nil then
    return
  end

  return self.repeatables[self.last_repeatable_id]:previous()
end

-- Workaround for # only working for array-based tables
function Register:_num_repeatables()
  local count = 0
  for _ in pairs(self.repeatables) do
    count = count + 1
  end

  return count
end

return Register

local Repeatable = require("better-n.repeatable")

local M = {}

local augroup = vim.api.nvim_create_augroup("BetterN", {})

local last_repeatable_id = nil
local repeatables = {}

vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = augroup,
  callback = function(args)
    local abort = vim.v.event.abort
    local cmdline_char = args.match

    if not abort and repeatables[cmdline_char] ~= nil then
      last_repeatable_id = cmdline_char
    end
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = augroup,
  pattern = { "BetterNMappingExecuted" },
  callback = function(args)
    last_repeatable_id = args.data.repeatable_id
  end,
})

function M.create(opts)
  local repeatable = Repeatable:new({
    bufnr = opts.bufnr or 0,
    next = opts.next,
    previous = opts.previous,
    passthrough = opts.initiate or opts.next,
    mode = opts.mode or "n",
    id = opts.id,
  })

  repeatables[repeatable.id] = repeatable

  return repeatable
end

function M.next()
  if last_repeatable_id == nil then
    return
  end

  return repeatables[last_repeatable_id]:next()
end

function M.previous()
  if last_repeatable_id == nil then
    return
  end

  return repeatables[last_repeatable_id]:previous()
end

-- Workaround for # only working for array-based tables
function M._num_repeatables()
  local count = 0
  for _ in pairs(repeatables) do
    count = count + 1
  end

  return count
end

return M

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
    next = opts.next or error("opts.next is required" .. vim.inspect(opts)),
    previous = opts.previous or error("opts.previous is required" .. vim.inspect(opts)),
    initiate = opts.initiate or opts.next or error("opts.next or opts.initiate is required" .. vim.inspect(opts)),
    mode = opts.mode or "n",
    id = opts.id or M.gen_id(),
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

function M.gen_id()
  -- Workaround for # only working for array-based tables
  local count = 0
  for _ in pairs(repeatables) do
    count = count + 1
  end

  return count
end

return M

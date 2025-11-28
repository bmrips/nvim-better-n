local Register = require("better-n.register")

local M = {
  setup = require("better-n.config").apply,
}

function M.instance()
  if _G.better_n_register == nil then
    _G.better_n_register = Register:new()
  end

  return _G.better_n_register
end

function M.next()
  return M.instance():next()
end

function M.previous()
  return M.instance():previous()
end

function M.create(...)
  return M.instance():create(...)
end

return M

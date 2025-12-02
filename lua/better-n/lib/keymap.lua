local Keymap = {}

function Keymap:new(mode, buffer)
  buffer = buffer or 0

  local instance = {
    buffer_mappings = vim.api.nvim_buf_get_keymap(buffer, mode),
    global_mappings = vim.api.nvim_get_keymap(mode),
  }

  setmetatable(instance, Keymap)

  return instance
end

Keymap.__index = Keymap

function Keymap:lookup(key)
  -- Compare using keycodes to avoid casing issues
  local keycode = vim.keycode(key)
  local keycodes_match = function(mapping)
    return vim.keycode(mapping.lhs) == keycode
  end
  local lookup_in = function(list)
    return vim.tbl_filter(keycodes_match, list)[1]
  end

  return lookup_in(self.buffer_mappings) or lookup_in(self.global_mappings)
end

function Keymap:rhs_of(key)
  return (self:lookup(key) or {}).rhs
end

return Keymap

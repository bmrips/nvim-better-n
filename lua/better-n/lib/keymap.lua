local Keymap = {}

---@param mode string In which mode to lookup keymaps
---@param buffer integer? If given, search the keymaps of the given buffer first
function Keymap:new(mode, buffer)
  buffer = buffer or 0

  local instance = {
    global_mappings = vim.api.nvim_get_keymap(mode),
  }

  if buffer ~= nil then
    instance.buffer_mappings = vim.api.nvim_buf_get_keymap(buffer, mode)
  end

  setmetatable(instance, Keymap)

  return instance
end

Keymap.__index = Keymap

---@param key string The key to lookup
---@return vim.api.keyset.get_keymap?
function Keymap:lookup(key)
  -- Compare using keycodes to avoid casing issues
  local keycode = vim.keycode(key)
  local keycodes_match = function(mapping)
    return vim.keycode(mapping.lhs) == keycode
  end
  local lookup_in = function(list)
    return vim.tbl_filter(keycodes_match, list or {})[1]
  end

  return lookup_in(self.buffer_mappings) or lookup_in(self.global_mappings)
end

---@param key string The key to lookup
---@return nil|string|fun():string? rhs The RHS to which the key is mapped, if it is mapped
function Keymap:rhs_of(key)
  return (self:lookup(key) or {}).rhs
end

return Keymap

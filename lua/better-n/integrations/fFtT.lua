local motion = require("better-n.motion")

local f = motion.create({
  initiate = "f",
  next = ";",
  previous = ",",
  map_args = { desc = "Move to next char" },
})
vim.keymap.set(f.modes, "f", f.initiate, f.map_args)

local F = motion.create({
  initiate = "F",
  next = ";",
  previous = ",",
  map_args = { desc = "Move to prev char" },
})
vim.keymap.set(F.modes, "F", F.initiate, F.map_args)

local t = motion.create({
  initiate = "t",
  next = ";",
  previous = ",",
  map_args = { desc = "Move before next char" },
})
vim.keymap.set(t.modes, "t", t.initiate, t.map_args)

local T = motion.create({
  initiate = "T",
  next = ";",
  previous = ",",
  map_args = { desc = "Move before prev char" },
})
vim.keymap.set(T.modes, "T", T.initiate, T.map_args)

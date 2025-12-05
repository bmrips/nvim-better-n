# nvim-better-n

Repeat movement commands using `n` in the same vein that `.` repeats action commands.

<div align="center">
	<img src="https://user-images.githubusercontent.com/985954/171856362-3e5feda1-8869-4512-bc78-7bdff2b4b3dd.gif" width=900>
</div>

## About

`nvim-better-n` attempts address a problem with Vim, which is that almost every
single binding is used by default, for (often) very niche actions. I want to be
able to reuse convenient bindings for similar things, reducing both mental
overhead as well as opening up more bindings, allowing Vim to be more
ergonomic.

It does this by rebinding `n` (which is a rather convenient binding), so that
it used for multiple different movement commands, in the same vein `.` repeats
action commands.

For example, if we jump to the next hunk, using `]h`, we can repeat
that command using `n`, allowing for far easier "scrolling" using that motion
without coming up with a bind that is easier to repeat.

Using this binding for that motion would, without this plugin, be rather
cumbersome in the cases were you wanted to press it multiple times.

It should also be noted that this frees up both `;`, and `,` for other actions,
as `n` will instead handle their current task.

## Install

Install as usual, using your favourite plugin manager.

```lua
use "jonatan-branting/nvim-better-n"
```

## Setup

This is the default configuration:
```lua
require("better-n").setup {
  -- Preserves n/N to work with /,?,*,g*,#,g#
  preserve_builtins = true,

  -- Which integrations to enable
  integrations = {
    fFtT = true, -- binds n/N to ;/, after f,F,t,T was used
  },
}
```

You create repeatable mappings like this:
```lua
local hunk = require("better-n").create {
  next = require("gitsigns").next_hunk,
  prev = require("gitsigns").prev_hunk,
}


vim.keymap.set(hunk.modes, "]h", hunk.next, hunk.map_args)
vim.keymap.set(hunk.modes, "[h", hunk.previous, hunk.map_args)
```

## Repeatable buffer-local mappings

To make buffer-local mappings repeatable, you can wrap the mappings in a `FileType` autocommand.

```lua
 vim.api.nvim_create_autocmd(
  "FileType",
  {
    callback = function(args)
      local square_brackets = require("better_n").create({
        next = "]]",
        prev = "[[",
        modes = "n",
        map_args = {
          buffer = args.buf,
          remap = true,
        },
      })

      vim.keymap.set(square_backets.modes, "]]", square_brackets.next, square_brackets.map_args)
      vim.keymap.set(square_backets.modes, "[[", square_brackets.previous, square_brackets.map_args)
     end,
  }
)
```

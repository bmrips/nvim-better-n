return {
  create = function(opts)
    return require("better-n.motion").create(opts)
  end,
  setup = function(opts)
    return require("better-n.config").apply(opts)
  end,
}

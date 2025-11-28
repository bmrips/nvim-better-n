local register = require("better-n.register")

return {
  next = register.next,
  previous = register.previous,
  create = register.create,
  setup = require("better-n.config").apply,
}

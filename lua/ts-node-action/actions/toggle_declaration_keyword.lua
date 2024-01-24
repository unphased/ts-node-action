local helpers = require("ts-node-action.helpers")

return function(pairs)

  local function action(node)
    local keyword = helpers.node_text(node:child(0))
    local new_keyword = pairs[keyword];
    local rest = helpers.node_text(node:child(1))
    return new_keyword .. ' ' .. rest -- TODO preserve the space instead of replace it with one space.
  end

  return { { action, name = "Cycle declaration keyword" } }
end

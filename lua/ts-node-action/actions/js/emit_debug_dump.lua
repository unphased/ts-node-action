local helpers = require("ts-node-action.helpers")

return function()

  local function action(node)
    local txt = helpers.node_text(node)
    log('txt!', txt)
  end

  return { { action, name = "Emit debug dump" } }
end

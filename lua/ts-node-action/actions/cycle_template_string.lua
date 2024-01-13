local helpers = require("ts-node-action.helpers")

return function()

  local function action(node)
    local text = helpers.node_text(node)
    local _, _, startIdx, _, _, endIdx = node:range(true)
    log("text", text, "from " .. tostring(startIdx) .. " to " .. tostring(endIdx))
    for child in node:iter_children() do
      log("child", child, helpers.node_text(child), child:range(true))
    end
    return text
  end
  return { { action, name = "Cycle Template String" } }
end

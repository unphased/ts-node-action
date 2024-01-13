local helpers = require("ts-node-action.helpers")

return function()

  local function action(node)
    local text = helpers.node_text(node)
    local _, _, start, _, _, end_ = node:range(true)
    log("text", text, "from " .. tostring(start) .. " to " .. tostring(end_))
    local i = 0
    local last_cend
    for child in node:iter_children() do
      i = i + 1
      local _, _, cstart, _, _, cend = child:range(true)
      if i > 1 then
        -- for 2nd and subsequent children, show template string content from prev sibling to self
        local a = last_cend - start
        local z = cstart - start
        local intercalated = text:sub(a + 1, z)
        log("intercalated", intercalated)
      end
      log("child", i, child:type(), helpers.node_text(child))
      last_cend = cend
    end
    return text
  end
  return { { action, name = "Cycle Template String" } }
end

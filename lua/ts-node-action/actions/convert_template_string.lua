local helpers = require("ts-node-action.helpers")

return function()

  local function action(node)
    local text = helpers.node_text(node)
    local _, _, start, _, _, end_ = node:range(true)
    log("text", text, "from " .. tostring(start) .. " to " .. tostring(end_))
    local i = 0
    local last_cend
    local assembly = {}
    for child in node:iter_children() do
      i = i + 1
      local _, _, cstart, _, _, cend = child:range(true)
      local tex
      if i > 1 then
        -- for 2nd and subsequent children, show template string content from prev sibling to self
        local a = last_cend - start
        local z = cstart - start
        tex = text:sub(a + 1, z)
        -- log("intercalated", tex)
        table.insert(assembly, { v = tex, ty = "text node" })
      end
      -- log("child", i, child:type(), helpers.node_text(child))
      table.insert(assembly, { v = helpers.node_text(child), ty = child:type() })
      last_cend = cend
    end
    log("assembly", assembly)
    return text
  end
  return { { action, name = "Cycle Template String" } }
end

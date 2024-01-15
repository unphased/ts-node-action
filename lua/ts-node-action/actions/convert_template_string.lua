local helpers = require("ts-node-action.helpers")

-- implements practical choice of single or double quotes to assemble string literals out of
function transformJsStringFragment(fragment)
    local hasSingleQuote = fragment:find("'", 1, true) ~= nil
    local hasDoubleQuote = fragment:find('"', 1, true) ~= nil

    if hasDoubleQuote and not hasSingleQuote then
        -- Contain double quotes, has no single quotes: use single quotes for the string.
        return "'" .. fragment .. "'"
    else -- has both types of quotes, only single quotes, or no quotes.
        -- Use double quotes for the string, escaping any double quotes inside it.
        fragment = fragment:gsub('"', '\\"')
        return '"' .. fragment .. '"'
    end
end

-- list of operators having higher precedence than `+`, this list is smaller than the list of those having lower.
local highPrecedenceBinaryExprOptrs = {
  '*', '/', '%', '**'
}

-- other than binary expressions, list of other type of nodes at root level of substitution to wrap in parens.
-- these all have lower precedence than `+`
local exprs = {
  'assignment_expression', -- as far as i can tell only `=`
  'augmented_assignment_expression',
  'ternary_expression',
  'arrow_function', -- however unlikely one would dump bare arrow function into template string, you can
  'sequence_expression', -- this is just any string of commas, bad form to shove side effects into template string, but you can
}

function stripTemplateSubstitution(node)
  local text = helpers.node_text(node)
  if text:sub(1, 2) == "${" and text:sub(-1) == "}" then -- a simple sanity check that node is template substitution
    -- do ad hoc parse (to check children of template_substitution), and only if any low precedence operator found wrap whole expr in parens to preserve operator precedence sanity.
    if node:child_count() > 0 then
      -- seems like we can be fairly sure a template_substitution always has 3 children: `${`, some kind of expr, and `}`
      local child = node:child(1)
      if child:type() == "binary_expression" then
        local operator = child:child(1):type()
        if vim.tbl_contains(highPrecedenceBinaryExprOptrs, operator) then
          return text:sub(3, -2)
        else -- lower precedence top level binary operator must be parenthesized
          return "(" .. text:sub(3, -2) .. ")"
        end
      elseif vim.tbl_contains(exprs, child:type()) then
        return "(" .. text:sub(3, -2) .. ")"
      end
    end
    return text:sub(3, -2)
  end
  return text
end

return function()
  -- convert js template string into expression appending strings
  local function action(node)
    local text = helpers.node_text(node)
    local _, _, start, _, _, end_ = node:range(true)
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
        if #tex > 0 then
          table.insert(assembly, transformJsStringFragment(tex))
        end
      end
      if child:type() == "template_substitution" then
        table.insert(assembly, stripTemplateSubstitution(child))
      end
      last_cend = cend
    end
    return table.concat(assembly, ' + ')
  end
  return { { action, name = "Cycle Template String" } }
end

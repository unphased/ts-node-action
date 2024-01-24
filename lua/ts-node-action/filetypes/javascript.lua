local actions = require("ts-node-action.actions")

local operators = {
  ["!="] = "==",
  ["!=="] = "===",
  ["=="] = "!=",
  ["==="] = "!==",
  [">"] = "<",
  ["<"] = ">",
  [">="] = "<=",
  ["<="] = ">=",
}

local padding = {
  [","] = "%s ",
  [":"] = "%s ",
  ["{"] = "%s ",
  ["}"] = " %s",
}

function merge_nested_tables(...)
    local merged = {}
    for _, tbl in ipairs({...}) do
        for _, nested_tbl in ipairs(tbl) do
            table.insert(merged, nested_tbl)
        end
    end
    return merged
end

local ret = {
  ["property_identifier"] = actions.cycle_case(),
  ["string_fragment"] = actions.conceal_string(),
  ["statement_block"] = merge_nested_tables(
    actions.toggle_multiline(padding),
    { ask = true }
  ),
  ["template_string"] = actions.convert_template_string(),
  ["binary_expression"] = actions.toggle_operator(operators),
  ["object"] = actions.toggle_multiline(padding),
  ["array"] = actions.toggle_multiline(padding),
  ["object_pattern"] = actions.toggle_multiline(padding),
  ["object_type"] = actions.toggle_multiline(padding),
  ["formal_parameters"] = actions.toggle_multiline(padding),
  ["arguments"] = actions.toggle_multiline(padding),
  ["number"] = actions.toggle_int_readability(),
  ["lexical_declaration"] = actions.toggle_declaration_keyword({['var'] = 'const', ['let'] = 'const',  ['const'] = 'let'})
}

-- local log = function(...)
--   local args = {...}
--   local log_file_path = "/tmp/lua-nvim.log"
--   local log_file = io.open(log_file_path, "a")
--   if log_file == nil then
--     print("Could not open log file: " .. log_file_path)
--     return
--   end
--   io.output(log_file)
--   io.write(string.format("%s:%03d", os.date("%H:%M:%S"), vim.loop.now() % 1000) .. " >>> ")
--   for i, payload in ipairs(args) do
--     local ty = type(payload)
--     if ty == "table" then
--       io.write(string.format("%d -> %s\n", i, vim.inspect(payload)))
--     elseif ty == "function" then
--       io.write(string.format("%d -> [function]\n", i))
--     else
--       io.write(string.format("%d -> %s\n", i, payload))
--     end
--   end
--   io.close(log_file)
-- end
--
-- local t1 = { {a = 1, b = 2} }
-- local t2 = { {c = 3, d = 4} }
-- local t3 = { {e = 5, f = 6} }
-- log('test', merge_nested_tables(t1, t2, t3))
-- log("ts-n-a: javascript.lua def:", ret)

return ret

local actions = require("ts-node-action.actions")
local js_actions = require("ts-node-action.actions.js")

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
  ["property_identifier"] = {
    { actions.cycle_case(), name = 'cycle case' },
    { js_actions.emit_debug_dump(), name = 'Debug dump' }
  },
  ["variable_name"] = {
    { actions.cycle_case(), name = 'Cycle case' },
    { js_actions.emit_debug_dump(), name = 'Debug dump' }
  },
  ["variable"] = {
    { actions.cycle_case(), name = 'Cycle case' },
    { js_actions.emit_debug_dump(), name = 'Debug dump' }
  },
  ["identifier"] = {
    { actions.cycle_case(), name = 'Cycle case' },
    { js_actions.emit_debug_dump(), name = 'Debug dump' }
  },
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

return ret

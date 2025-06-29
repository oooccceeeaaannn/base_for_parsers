broad_nouns = {"text"}
parsingfuncs = {}
parser_extra_data = {}
writelikes_to_parsers = {write = "text"}
metalikes_to_parsers = {meta = "text"}
unmetalikes_to_parsers = {unmeta = "text"}
function register_parser(name, parsing_func, write_equ, meta_equ, unmeta_equ, unittype, tiling, layer)
    table.insert(broad_nouns, name)
    parsingfuncs[name] = parsing_func
    if meta_equ ~= nil then
        metalikes_to_parsers[meta_equ] = name
    end
    if unmeta_equ ~= nil then
        unmetalikes_to_parsers[unmeta_equ] = name
    end
    parser_extra_data[name] = {unittype = unittype, tiling = tiling, layer = layer}
    if write_equ ~= nil then
        writelikes_to_parsers[write_equ] = name
    end
end

function add_parser(type, name, col, colactive)
    local fullname = type .. "_" .. name
    table.insert(editor_objlist_order, fullname)
    editor_objlist[fullname] = {
        name = fullname,
        sprite_in_root = false,
        unittype = parser_extra_data[type].unittype,
        tags = {type},
        tiling = parser_extra_data[type].tiling,
        type = 0,
        layer = 20,
        colour = col,
        colour_active = colactive,
    }
end
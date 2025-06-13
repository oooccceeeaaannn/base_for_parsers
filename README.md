# Base for Parsers mod in [Baba Is You](https://hempuli.com/baba/)
## Important Message
This repo is based on [Baba Is You - Better Metatext](https://github.com/EmilyEmmi/Baba-Is-You---Metatext-Mod) by [Emily](https://github.com/EmilyEmmi).
## What does this repo do?
As the name suggests, this repo provides a base for tyou to create new unique parsers.
This base automatically deals with these things:
- The Broad Noun behaviour \(e.g. TEXT noun refers to all text, IS & HAS & MAKE TEXT, etc\)
- The meta\[parser\] behaviour \(e.g. TEXT_BABA refers to pieces of text that refers to BABA\)
- The Mixed Broad Noun behaviour \(e.g. TEXT HAS GLYPH makes pieces of TEXT drop GLYPH_TEXT upon destruction\)
- \[non-text parser] IS WORD behaviour \(e.g. GLYPH IS WORD makes GLYPHs mean "GLYPH" instead of the individual glyph names\)
- Reparse when the parser gets updated
## How do I use this repo?
To add a new parser, create a file named add_parser.lua in Lua/ and type the following code:
```lua
register_parser("broad name of your parser in all lowercase, e.g. node",
function()
--do your parsing here
end,
"the verb that functions like 'write' for your parser in all lowercase, left nil to not set",
"the prop that functions like 'meta' for your parser in all lowercase, left nil to not set",
"the prop that functions like 'unmeta' for your parser in all lowercase, left nil to not set",
"the UNITTYPE for all the parser objects of this parser in all lowercase",
-1, --the TILING TYPE for all the parser objects of this parser
20 --the LAYER for all the parser objects of this parser
)
```
To add words to a parser, type the following code in the file you created:
```lua
add_parser("the name of the parser the word is in, in FULL LOWERCASE",
"the word itself in FULL LOWERCASE AND WITHOUT THE PARSER PREFIX, like 'baba' to refer to baba and 'text_baba' to refer to text_baba",
{0,0}, --inactive colour
{0,0}, --active colour
)
```

An example below adds a non-parsing parser named "plan".
```lua
register_parser("plan", function()
--[[
PLAN WORD TYPES:
nil: blueprint
[Lua error: attempt to index a nil value]: blueprint
0: blueprint
]]
end, "sketch", "layout", "form", "object", -1, 20)

local plans = {"baba","keke","me","jiji","fofo","it","badbad","flag","wall","rock","arrow","belt","bog",
"cliff","cursor","door","dot","fruit","fungus","hedge","jelly","key","monitor","pillar","tile","tree","triangle","water","what",
"all","text","level","empty","plan","start",
"you","win","stop","push","pull","swap","sad","crash","shut","open",
"text_baba","text_is","text_you","text_plan","text_near",
"plan_baba","plan_plan_baba","plan_plan_plan_baba","plan_plan_plan_plan_baba",}

table.insert(editor_objlist_order,"text_plan")
editor_objlist["text_plan"] = {
  name = "text_plan",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_special","abstract"},
  tiling = -1,
  type = 0,
  layer = 20,
  colour = {4, 3},
  colour_active = {3, 3},
}

table.insert(editor_objlist_order,"text_form")
editor_objlist["text_form"] = {
  name = "text_form",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_special","abstract"},
  tiling = -1,
  type = 2,
  layer = 20,
  colour = {4, 3},
  colour_active = {3, 3},
}

table.insert(editor_objlist_order,"text_sketch")
editor_objlist["text_sketch"] = {
  name = "text_sketch",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_special","abstract"},
  tiling = -1,
  type = 1,
  layer = 20,
  colour = {0, 1},
  colour_active = {0, 3},
  argtype = {0, 2},
}

for _, plan in ipairs(plans) do
  add_parser("plan", plan, {0,3}, {0,3})
end

formatobjlist()-- don't forget this!
```
## Further plans:
- [ ] Add full support word-like props
The above list may update at random.

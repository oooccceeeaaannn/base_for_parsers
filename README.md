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


## Further plans:
- [ ] Add full support word-like props

The above list may update at random.

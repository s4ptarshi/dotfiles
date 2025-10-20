local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    s("bb", fmt("\\mathbb{{{}}}", { i(1) })),
    s("cc", fmt("\\mathcal{{{}}}", { i(1) })),
    -- Add more: s("fr", fmt("\\mathfrak{{{}}}", { i(1) })),
}

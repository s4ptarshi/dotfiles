require('Comment').setup({
    toggler = {
        line = '<leader>/',
    }
})

local wk = require('which-key')

-- basic
wk.register({
  gb = 'Togggle block comment',
  gbc = 'Toggle block comment',
  gc = 'Toggle line comment',
  gcc = 'Toggle line comment',
}, { mode = "n" })

wk.register({
  gb = 'Togggle block comment',
  gc = 'Toggle line comment',
}, { mode = "x" })

-- extra
wk.register({
  gco = 'Comment next line',
  gcO = 'Comment prev line',
  gcA = 'Comment end of line',
}, { mode = "n" })

-- extended
wk.register({
  ["g>"] = 'Comment region',
  ["g>c"] = 'Add line comment',
  ["g>b"] = 'Add block comment',
  ["g<lt>"] = 'Uncomment region',
  ["g<lt>c"] = 'Remove line comment',
  ["g<lt>b"] = 'Remove block comment',
}, { mode = "n" })

wk.register({
  ["g>"] = 'Comment region',
  ["g<lt>"] = 'Uncomment region',
}, { mode = "x" })

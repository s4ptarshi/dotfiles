" turns on numbers on sidebar
:set number
" turns on pasting from clipboard
:set clipboard=unnamedplus
"colourmode!!!
colorscheme molokai
" molokai mode to match dark gui version
let g:rehash256 = 1
" enables syntax and indentation and plugins based on filetype (need to look
" into it though)
syntax enable
filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab
"case insensitive search when all smol but case sensitive when there are
"capital letters
:set ignorecase
:set smartcase
"sudo writing shortcut
cnoremap sudow w !sudo tee %
"C template
:autocmd BufNewFile  *.c 0r ~/.config/nvim/templates/skeleton.c 

" switch higlight no matter the previous state
nmap <F4> :set hls! <cr>
" hit '/' highlights then enter search mode
nnoremap / :set hlsearch<cr>/

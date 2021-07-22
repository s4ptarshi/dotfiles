" plugin manager(vim plug)
call plug#begin('~/.config/nvim/plugged')

    Plug 'jiangmiao/auto-pairs' "does autopairing of brackets
    Plug 'tanvirtin/monokai.nvim'
    Plug 'itchyny/lightline.vim'
    Plug 'frazrepo/vim-rainbow'
"    Plug 'scrooloose/nerdtree'                         " Nerdtree
"    Plug 'tiagofumo/vim-nerdtree-syntax-highlight'     " Highlighting Nerdtree
"    Plug 'ryanoasis/vim-devicons'                      " Icons for Nerdtree

call plug#end()
let g:rainbow_active = 1

"nerd tree settings

map <C-n> :NERDTreeToggle<CR>
let g:NERDTreeDirArrowExpandable = '►'
let g:NERDTreeDirArrowCollapsible = '▼'
let NERDTreeShowLineNumbers=1
let NERDTreeShowHidden=1
let NERDTreeMinimalUI = 1
let g:NERDTreeWinSize=38 

" turns on numbers on sidebar
:set number
" turns on pasting from clipboard
:set clipboard=unnamedplus

set termguicolors
colorscheme monokai

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


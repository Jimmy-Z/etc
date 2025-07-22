" this file contains vim/neovim common settings
" source this in vimrc/init.vim

" K on them to get help, or https://vimhelp.org/

set title
set titlestring=%f\ \(%{getcwd()}\)
set statusline=%h%w%m%r\ %f\ \(%{getcwd()}\)\ %=\ %{&filetype}\ %{&fenc}\ %{&fileformat}\ \(%l,%c\)\ %P

" most time I don't need this, so to save some space
" set number
set cursorline
set scrolloff=12
" there's no option like vscode/zed disable scroll beyond eof
" well, use C-d instead of C-f

" my capricious
set noexpandtab
set tabstop=3
set shiftwidth=3

" encoding list to try when reading files
" to reload a file using a specific encoding :e ++enc=cp437
set fileencodings=ucs-bom,utf-8,latin1
" encoding on new files
setglobal fenc=utf-8
" nobody wants crlf
set fileformats=unix,dos

set mouse=a
set confirm
set clipboard=unnamedplus

set ignorecase
set smartcase

set list " show whitespaces
set listchars=tab:»\ ,trail:·,nbsp:␣ " pretty unicode chars

" n mode, non-recursive map
nnoremap <ESC> :noh<CR>
nnoremap <Tab> <C-w>w
nnoremap <S-Tab> <C-w>W
nnoremap <C-Tab> :bnext<CR>
nnoremap <C-S-Tab> :bprev<CR>

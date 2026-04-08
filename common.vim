" vim/neovim common settings

" K on them to get help, or https://vimhelp.org/

set title
set titlestring=%f\ \(%{getcwd()}\)
set statusline=%h%w%m%r\ %f\ \(%{getcwd()}\)\ %=\ %{&filetype}\ %{&fenc}\ %{&fileformat}\ \(%l,%c\)\ %P

" most of the time I don't need this, so to save some space
" set number
set cursorline
set scrolloff=12
" there's no option like vscode/zed disable scroll beyond eof
" well, use C-d instead of C-f
" btw, also use C-u instead of C-b to prevent confliction with tmux

set noexpandtab
set tabstop=3
set shiftwidth=3
" my capricious, yaml sucks
autocmd FileType * if index(['yaml'], &ft) == -1 | setlocal noet ts=3 sw=3

" encoding list to try when reading files
" to reload a file using a specific encoding :e ++enc=cp437
set fileencodings=ucs-bom,utf-8,latin1
autocmd BufReadPre *.nfo setlocal fileencodings=cp437
" encoding on new files
setglobal fenc=utf-8
" nobody wants crlf
set fileformats=unix,dos

" use newer standards for shell scripts syntax highlighting
let g:is_posix=1

set mouse=a
set confirm
set clipboard=unnamedplus

set ignorecase
set smartcase

set list " show whitespaces
set listchars=tab:»\ ,trail:·,nbsp:␣ " pretty unicode chars

" reset cursor shape on exit, doesn't seem to be working
autocmd VimLeave * silent !echo -ne "\\e[0 q"

" n mode, non-recursive map
nnoremap <ESC> :noh<CR>
nnoremap <Tab> <C-w>w
nnoremap <S-Tab> <C-w>W
nnoremap <C-Tab> :bnext<CR>
nnoremap <C-S-Tab> :bprev<CR>


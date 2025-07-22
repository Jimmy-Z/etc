" this file contains vim only (not neovim) settings
" source this in vimrc(/etc/vim/vimrc.local for root)

set laststatus=2

colorscheme slate

" these only works for mintty
nnoremap <Esc>[1;5I :bnext<CR>
nnoremap <Esc>[1;6I :bprev<CR>

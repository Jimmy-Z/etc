" neovim specific settings

" since it still detects my languge settings wrong on windows
lang en
lang mes en " and for what ever reason, this is not covered

set inccommand=split

" https://neovim.io/doc/user/lua.html#_vim.hl
autocmd TextYankPost * silent! lua vim.hl.on_yank()

" https://neovide.dev/configuration.html
let g:neovide_cursor_vfx_mode = "pixiedust"
let g:neovide_pixel_geometry = "RGBH"

augroup ime_input " ime only in ins/cmd mode
	autocmd!
	autocmd InsertLeave * execute "let g:neovide_input_ime=v:false"
	autocmd InsertEnter * execute "let g:neovide_input_ime=v:true"
	autocmd CmdlineLeave [/\?] execute "let g:neovide_input_ime=v:false"
	autocmd CmdlineEnter [/\?] execute "let g:neovide_input_ime=v:true"
augroup END

colorscheme sorbet

highlight StatusLine gui=NONE cterm=NONE
highlight StatusLineNC gui=NONE cterm=NONE

" hl


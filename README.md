### ideally, keep local clone shallow
```
git clone --depth 1 <this repo>
```

### mkshrc/bashrc
source `shrc` in `~/.mkshrc` or `~/.bashrc`
or `/etc/bash.bashrc`
```sh
if test -f ~/etc/shrc; then
	. ~/etc/shrc
fi
```

### vim
```vim
source ~/etc/common.vim
source ~/etc/vim.vim
```
* per user: `~/.vimrc`
* system-wide: `/etc/vim/vimrc.local`
* be aware, no quotes allowed

### neovim
* source `common.vim` and `neovim.vim`
* I only use neovim on windows, conf location:
`%LOCALAPPDATA%\nvim\init.vim`


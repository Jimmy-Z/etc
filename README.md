### ideally, keep local clone shallow
* initial clone
	```
	git clone --depth 1 <this repo>
	```
* update
	```
	./update
	```

### profile
source `profile.sh` in `~/.mkshrc` (or `~/.bashrc`)
```sh
if test -f ~/etc/profile.sh; then
	. ~/etc/profile.sh
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

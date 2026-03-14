### ideally, keep local clone shallow
```
git clone --depth 1 ...
git fetch --depth 1 origin main && git reset --hard origin/main && git gc --prune=now
```

### profile
source `profile.sh` in `~/.bashrc`
```sh
if test -f ~/etc/profile.sh; then
	source ~/etc/profile.sh
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

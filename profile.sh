# trying to be posix compliant, but not tested

# quit if not interactive
case "$-" in *i*) ;; *) return;; esac

# different color/prompt for root
if test $EUID -ne 0; then
	COLOR_0=32
	COLOR_1=36
	PROMPT_CHAR='$'
else
	COLOR_0=31
	COLOR_1=33
	PROMPT_CHAR='#'
fi
# title
if test "$MSYSTEM"; then
	PS1="\[\e]0;MSYS2 \w\a\]"
elif test "$TERMUX_VERSION"; then
	PS1="\[\e]0;\w\a\]"
else
	PS1="\[\e]0;\u@\h:\w\a\]"
fi
# special prefix
if test "$debian_chroot"; then
	PS1="$PS1"'\[\e[01;35m\]($debian_chroot)\[\e[00m\]'
elif test "$MSYSTEM"; then
	PS1="$PS1"'\[\e[01;35m\]($MSYSTEM)\[\e[00m\]'
fi
# the usual user@host:pwd
if test -z "$MSYSTEM" -a -z "$TERMUX_VERSION"; then
	PS1="$PS1"'\[\e[01;'$COLOR_0'm\]\u\[\e[00m\]'
	PS1="$PS1"'\[\e[01;'$COLOR_1'm\]@\[\e[00m\]'
	PS1="$PS1"'\[\e[01;'$COLOR_0'm\]\h\[\e[00m\]'
fi
PS1="$PS1"'\[\e[01;'$COLOR_1'm\]:\w\[\e[00m\]'
# git
if type __git_ps1 >/dev/null 2>&1; then
	PS1="$PS1"'\[\e[01;35m\]$(__git_ps1)\[\e[00m\]'
fi
# prompt
PS1="$PS1"'\[\e[01;'$COLOR_0'm\]'$PROMPT_CHAR'\[\e[00m\] '

# more msys2 specific things
if test "$MSYSTEM"; then
	export MSYS=winsymlinks:nativestrict
	export SSH_AUTH_SOCK=$(cygpath -u $LOCALAPPDATA)/ssh-auth-sock
	# add scoop shims to PATH, since reasons
	SCOOP=/d/scoop/shims
	if test -d "$SCOOP"; then
		export PATH=$PATH:$SCOOP
	fi
fi

# aliases

alias ls='ls --color=auto'
alias l='ls -CF'
alias ll='ls -lh'
alias la='ls -Alh'

avail(){
	# https://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script
	command -v "$1" >/dev/null 2>&1
}

try_location(){
	# https://stackoverflow.com/questions/255898/how-to-iterate-over-arguments-in-a-bash-script
	for f; do
		if test -f "$f"; then
			echo "$f"
			break
		fi
	done
}

if avail apt;then
	alias pi='apt install --no-install-recommends'
	alias pu='apt update&&apt autoclean&&apt upgrade'
	alias pr='apt purge'
	alias pq='apt search -n'
elif avail apt-get;then
	alias pi='apt-get install --no-install-recommends'
	alias pu='apt-get update&&apt-get autoclean&&apt-get upgrade'
	alias pr='apt-get purge'
	alias pq='apt-cache search -n'
elif avail pacman;then
	alias pi='pacman -S'
	alias pu='pacman -Syu;pacman -Sc'
	alias pr='pacman -R'
	alias pq='pacman -Ss'
fi

if avail nvim; then
	if avail neovide; then
		alias vim=neovide
		alias vi=neovide
	else
		alias vim=nvim
		alias vi=nvim
	fi
elif avail vim; then
	alias vi=vim
fi

avail tmux && alias ta='tmux a||tmux'

# trying to be portable
# tested with mksh and bash in debian, arch, msys2, git-bash(windows) and termux
# (not all combinations)

# quit if not interactive
case "$-" in *i*) ;; *) return;; esac

# (m)ksh uses a different scheme to mark invisible parts in PS1
if test "$KSH_VERSION"; then 
	__color_seq(){
		printf '\001\033[01;%sm\001' "$1"
	}
	CE=$'\001\033[00m\001' # end of a color sequence
	TESC=$'\001\r\001\033]0;' # title escape
	TEND=$'\007\001'
else
	__color_seq(){
		printf '\001\033[01;%sm\002' "$1"
	}
	CE=$'\001\033[00m\002'
	TESC=$'\001\033]0;'
	TEND=$'\007\002'
fi
# different color/prompt for root
if test -z "$EUID" -o "$EUID" -ne 0; then
	C0=$(__color_seq 32)
	C1=$(__color_seq 36)
	PROMPT_CHAR='$'
else
	C0=$(__color_seq 31)
	C1=$(__color_seq 33)
	PROMPT_CHAR='#'
fi
C2=$(__color_seq 35)
unset -f __color_seq

__pwd() { # \w and ${#//} doesn't work in mksh
	case "$PWD" in
		"$HOME"*) printf '~%s' "${PWD#$HOME}";;
		*) printf '%s' "$PWD";;
	esac
}
# title
if test "$MSYSTEM"; then
	# not a good detection, but it works
	if test "$HOME" == "$(cygpath -u "$USERPROFILE")"; then
		MTITLE="git bash"
	else
		MTITLE="$MSYSTEM"
	fi
	PS1="$TESC$MTITLE \$(__pwd)$TEND"
elif test "$TERMUX_VERSION"; then
	PS1="${TESC}termux \$(__pwd)$TEND"
else
	PS1="$TESC$USER@$(hostname):\$(__pwd)$TEND"
fi
# special prefix
if test "$debian_chroot"; then
	PS1="$PS1$C2($debian_chroot)$CE"
elif test "$MSYSTEM"; then
	PS1="$PS1$C2($MTITLE)$CE"
fi
# the usual user@host, not for msys and termux
if test -z "$MSYSTEM" -a -z "$TERMUX_VERSION"; then
	PS1="$PS1$C0$USER$C1@$C0$(hostname)$CE"
fi
# the usual :pwd
PS1="$PS1$C1:\$(__pwd)$CE"
# git
# to do: a better impl
if type __git_ps1 >/dev/null 2>&1; then
	PS1="$PS1$C2$(__git_ps1)$CE"
fi
# prompt
PS1="$PS1$C0$PROMPT_CHAR$CE "
unset PROMPT_CHAR C0 C1 C2 CE TESC TEND MTITLE

# more msys2 specific things
if test "$MSYSTEM"; then
	export MSYS=winsymlinks:nativestrict
	# do not set this for git bash
	# since using windows native ssh is a better approach
	# and setting SSH_AUTH_SOCK will break it
	if test "$HOME" != "$(cygpath -u $USERPROFILE)"; then
		export SSH_AUTH_SOCK="$(cygpath -u $LOCALAPPDATA)/ssh-auth-sock"
	fi
	# add scoop shims to PATH, basically for neovide
	# to do: detect scoop location
	SCOOP=/d/scoop/shims
	if test -d "$SCOOP"; then
		export PATH=$PATH:$SCOOP
	fi
	unset SCOOP
fi

# aliases

alias ls='ls --color=auto'
alias l='ls -CF'
if test -z "$MSYSTEM" -a -z "$TERMUX_VERSION"; then
	alias ll='ls -lh'
	alias la='ls -Alh' # A is a minus . and ..
else
	alias ll='ls -gGh' # g is l minus owner, G hides group
	alias la='ls -AgGh'
fi

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
	alias p='apt update&&apt autoclean&&apt list --upgradable'
	alias pu='apt upgrade'
	alias pi='apt install --no-install-recommends'
	alias pr='apt purge'
	alias pq='apt search -n'
	alias po='dpkg -S' # which package provides/owns a file
	# apt doesn't have a good "list explicitly installed" like `pacman -Qe`
	# this is probably the best approach: list all "top-level" packages
	# i.e. doesn't have any other packages depending on them
	# https://askubuntu.com/questions/1114733/how-do-i-list-all-packages-that-no-package-depends-on
	pe(){
		dpkg-query --show --showformat='${Package}\t${Status}\n' |\
			tac |\
			awk '/installed$/ {print $1}' |\
			xargs apt-cache rdepends --installed |\
			tac |\
			awk '{ if (/^ /) ++deps; else if (!/:$/) { if (!deps) print; deps = 0 } }'
	}
elif avail pacman;then
	alias p='pacman -Sy&&pacman -Sc --noconfirm&&pacman -Qu'
	alias pu='pacman -Su'
	alias pi='pacman -S'
	alias pr='pacman -R'
	alias pq='pacman -Ss'
	alias pe='pacman -Qe'
	alias po='pacman -Qo'
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

# this thing is really nasty though, dbus and stuff
avail udisksctl && alias eject='udisksctl power-off --block-device'

avail tabs && tabs 3
export LESS="--tabs=3 -R"


# trying to be portable
# tested with mksh and bash in debian, arch, msys2, git-bash(windows) and termux
# (not all combinations)

# quit if not interactive
case "$-" in *i*) ;; *) return;; esac

avail(){
	# https://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script
	command -v "$1" >/dev/null 2>&1
}

# (m)ksh uses a different scheme to mark invisible parts in PS1
if test "$KSH_VERSION"; then 
	__color_seq(){
		# using echo is not posix compliant
		# but printf is not a builtin in mksh
		echo -n "\001\033[01;$1m\001"
	}
	C_END=$'\001\033[00m\001' # end of a color sequence
	TESC=$'\001\r\001\033]0;' # title escape
	TEND=$'\007\001'
else
	__color_seq(){
		echo -n "\001\033[01;$1m\002"
	}
	C_END=$'\001\033[00m\002'
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

# better git ps1
if avail git;then
	C_RED="$(__color_seq 31)"
	C_GREEN="$(__color_seq 32)"
	__GIT_PS1_FMT=" $C2(\$B$C_END \$S$C2)$C_END"

	__head_n_count() {
		# prints 1st line, returns line count, only counts to 2
		local cnt=0
		local l
		while read l; do
			cnt=$((cnt + 1))
			if test $cnt -gt 1; then
				return $cnt
			fi
			echo -n "$l"
		done
		return $cnt
	}

	__git_ps1(){
		local B="$(git branch --show-current 2>/dev/null)"
		if test -z "$B"; then
			return
		fi
		local S="$(git status --short)"
		if test -z "$S"; then
			S="${C_GREEN}clean$C_END"
		else
			# do NOT combine these two lines
			# since local is a command, it has return value
			local S1
			S1="$(echo -n "$S"|__head_n_count)"
			if test "$?" -gt 1; then
				S="$C_RED$S1$C_END ..."
			else
				S="$CRED$S1$C_END"
			fi
		fi
		# maybe also squeeze a "$(git rev-parse --short=7 HEAD)" in there?
		eval "echo -n \"$__GIT_PS1_FMT\""
	}

	alias gl='git log --oneline'
fi

unset -f __color_seq

__pwd() { # \w and ${#//} doesn't work in mksh
	case "$PWD" in
		"$HOME"*) echo -n "~${PWD#$HOME}";;
		*) echo -n "$PWD";;
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
	PS1="$PS1$C2($debian_chroot)$C_END"
elif test "$MSYSTEM"; then
	PS1="$PS1$C2($MTITLE)$C_END"
fi
# the usual user@host, not for msys and termux
if test -z "$MSYSTEM" -a -z "$TERMUX_VERSION"; then
	PS1="$PS1$C0$USER$C1@$C0$(hostname)$C_END"
fi
# the usual :pwd
PS1="$PS1$C1:\$(__pwd)$C_END"
# git
# to do: a better impl
if type __git_ps1 >/dev/null 2>&1; then
	PS1="$PS1\$(__git_ps1)"
fi
# prompt
PS1="$PS1$C0$PROMPT_CHAR$C_END "
unset PROMPT_CHAR C0 C1 C2 TESC TEND MTITLE

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

try_location(){
	# https://stackoverflow.com/questions/255898/how-to-iterate-over-arguments-in-a-bash-script
	for f; do
		if test -f "$f"; then
			echo -n "$f"
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


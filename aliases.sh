# my aliases collection

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
	for f;do
		if [ -f "$f" ];then
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

avail vim && alias vi='vim'
avail tmux && alias ta='tmux a||tmux'
avail mc && alias mc='TERM=xterm-256color mc'

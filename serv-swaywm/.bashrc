# ~/.bashrc: executed by bash(1) for non-login shells.

export WAYLAND_DISPLAY='wayland-1'

export EDITOR="vim"
export GIT_EDITOR="${EDITOR}"
export SYSTEMD_EDITOR="${EDITOR}"

export PAGER=""
export GIT_PAGER="${PAGER}"
export MAN_PAGER="${PAGER}"
export SYSTEMD_PAGER="${PAGER}"

export XZ_OPT='--threads=0'

#export HISTSIZE="500000"
#export HISTTIMEFORMAT="%F %T %z -> "
#export HISTCONTROL="ignoreboth:erasedups"
#export PROMPT_COMMAND="history -a; history -c; history -r;"
#FZF_CTRL_T_COMMAND= FZF_ALT_C_COMMAND= eval "$(fzf --bash)"

export PS1='\[\033[01;34;01m\][\u@\h $(uname -m) \D{%F %T %z} \W]%\[\033[01;00;00m\] '

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias ls='ls --color=auto'
alias ll='ls -Alh -v --group-directories-first --time-style="+%F %T %z"'
alias grep='grep --color'

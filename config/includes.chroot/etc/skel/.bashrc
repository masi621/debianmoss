case $- in
    *i*) ;;
      *) return;;
esac
HISTCONTROL=ignoreboth
shopt -s histappend checkwinsize
if [ -f /etc/bash_completion ]; then . /etc/bash_completion; fi
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export PATH="$HOME/.local/bin:$PATH"
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias moss='moss-welcome'
alias cls='clear'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias v='nvim'
if [ -f /etc/profile.d/debianmoss.sh ]; then . /etc/profile.d/debianmoss.sh; fi
cat() {
  if command -v batcat >/dev/null 2>&1; then
    batcat --paging=never "$@"
  else
    command cat "$@"
  fi
}
PROMPT_DIRTRIM=3
moss_reset='\[\e[0m\]'
moss_dim='\[\e[38;5;65m\]'
moss_bright='\[\e[38;5;84m\]'
moss_path='\[\e[38;5;151m\]'
moss_warn='\[\e[38;5;179m\]'
PS1="${moss_dim}moss ${moss_bright}\u${moss_dim}@${moss_bright}\h ${moss_dim}in ${moss_path}\w ${moss_warn}\\$ ${moss_reset}"

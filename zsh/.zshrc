#export OLLAMA_HOST=0.0.0.0:8000
export OLLAMA_FLASH_ATTENTION=1
export OLLAMA_KV_CACHE_TYPE=q8_0
export OLLAMA_CONTEXT_LENGTH=256000 Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# FZF, fuzzy find
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_OPTS="
  --height 40%
  --layout=reverse
  --info=inline
"

stty -ixon

# Aliases
alias ll="ls -la"
alias gs="git status"
alias v="nvim"
alias gaa="git add ."
alias gc="git commit -m"
alias gca="git commit -m -a":w

# Backlog.md setup
fpath=(/Users/thomas.w.rorbech/.zsh/completions $fpath)
autoload -Uz compinit && compinit

# Created by `pipx` on 2026-02-23 15:24:13
export PATH="$PATH:/Users/thomas.w.rorbech/.local/bin"

export OLLAMA_HOST=0.0.0.0:8000
export OLLAMA_FLASH_ATTENTION=1
export OLLAMA_KV_CACHE_TYPE=q8_0
export OLLAMA_CONTEXT_LENGTH=256000

# For Local Agentic work
# export ANTHROPIC_BASE_URL="http://localhost:8000"
# export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# Docker: allow both old (docker-compose) and new (docker compose) notation
alias docker compose="docker-compose"

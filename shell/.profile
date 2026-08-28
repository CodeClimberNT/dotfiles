# ~/.profile

# Cargo (Rust toolchain)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Go general environment setup
[ -f "$HOME/.go/env" ] && . "$HOME/.go/env"

# use this when zed will allow secrets from env files
# [ -f "$HOME/.config/zed/secrets.env" ] && . "$HOME/.config/zed/secrets.env"

# follow XDG base dir specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Core environment
export EDITOR=nvim
export SUDO_EDITOR=nvim

export TERMINAL=kitty
export TERM=xterm-256color

export FZF_DEFAULT_OPTS="--style minimal --color 16 --layout=reverse --height 30% --preview='bat -p --color=always {}'"
export FZF_CTRL_R_OPTS="--style minimal --color 16 --info inline --no-sort --no-preview" # separate opts for history widget

# starship config path
export STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship/starship.toml

# colored less + termcap vars
export MANPAGER="less"

# colored less + termcap vars
export LESS="R --use-color -Dd+r -Du+b"
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;44;33m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'
export LESS_TERMCAP_ue=$'\e[0m'

# dev paths
export DOTNET_ROOT=/usr/share/dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
export PATH="$HOME/.lmstudio/bin:$PATH"

# Keep this LAST (as explicitly said in the texlive installation guide)
PATH=/usr/local/texlive/2026/bin/x86_64-linux:$PATH


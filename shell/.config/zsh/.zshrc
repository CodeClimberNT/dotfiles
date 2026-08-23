# .zshrc file mainly copied from https://github.com/BreadOnPenguins/dots/blob/master/.config/zsh/.zshrc

# =========================
# Load .profile if it exists (for non-login shells)
# =========================
[[ -z ${EDITOR-} && -f "$HOME/.profile" ]] && source "$HOME/.profile"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# =========================
# Powerlevel10k instant prompt (MUST BE FIRST)
# =========================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =========================
# System / distro config
# =========================
config_file="/usr/share/cachyos-zsh-config/cachyos-config.zsh"
[[ -r "$config_file" ]] && source "$config_file"
unset config_file

# =========================
# Completion system
# =========================
zmodload zsh/complist

autoload -Uz compinit
compinit

autoload -U colors && colors
# autoload -U tetris # main attraction of zsh, obviously

# =========================
# Completion UI config
# =========================
zstyle ':completion:*' menu select # tab opens cmp menu
zstyle ':completion:*' special-dirs true # force . and .. to show in cmp menu
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=0\;33 # colorize cmp menu
# zstyle ':completion:*' file-list true # more detailed list
zstyle ':completion:*' squeeze-slashes false # explicit disable to allow /*/ expansion

# =========================
# Shell behavior options
# =========================
setopt append_history inc_append_history share_history # better history
# on exit, history appends rather than overwrites; history is appended as soon as cmds executed; history shared across sessions
setopt auto_menu menu_complete # autocmp first menu match
setopt autocd # type a dir to cd
setopt auto_param_slash # when a dir is completed, add a / instead of a trailing space
setopt no_case_glob no_case_match # make cmp case insensitive
setopt globdots # include dotfiles
setopt extended_glob # match ~ # ^
setopt interactive_comments # allow comments in shell
unsetopt prompt_sp # don't autoclean blanklines

# =========================
# History
# =========================
HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE="$XDG_CACHE_HOME/zsh_history" # move histfile to cache
# HISTCONTROL=ignoreboth # consecutive duplicates & commands starting with space are not saved
setopt hist_ignore_dups hist_ignore_space

# =========================
# Theme (Powerlevel10k)
# =========================
[[ -f "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"

# =========================
# Plugins (must come AFTER p10k)
# =========================
# autosuggestions
# requires zsh-autosuggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# syntax highlighting
# requires zsh-syntax-highlighting package
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# =========================
# Tools (interactive shell features)
# =========================

# fzf
command -v fzf >/dev/null && source <(fzf --zsh)

# zoxide
eval "$(zoxide init zsh)" 

# Shared aliases
[[ -r "$HOME/.aliases" ]] && source "$HOME/.aliases"

# =========================
# Terminal safety tweaks (MUST BE LAST)
# =========================
if [[ -t 0 ]]; then
  # disable accidental ctrl s
  stty stop undef 
fi
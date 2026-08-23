# ~/.bashrc

# Non-interactive check
[[ $- != *i* ]] && return

# Source .profile if it exists
if [ -f "$HOME/.profile" ]; then
  source "$HOME/.profile"
fi

# Source shared aliases if the file exists
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# --- Shell Settings ---
shopt -s autocd cdspell checkwinsize histappend globstar

bind "set completion-ignore-case on"
bind "set colored-stats on"

# --- Tools Initialization ---
eval "$(zoxide init bash)"
eval "$(starship init bash)"

# --- ble.sh ---
# Setup
# shellcheck source=/dev/null
[[ -f "$HOME/.local/share/blesh/ble.sh" ]] && source "$HOME/.local/share/blesh/ble.sh"

# Ble.sh Configuration
if [[ ${BLE_VERSION-} ]]; then
  # Options
  bleopt accept_line_threshold=5

  # Integrations
  ble-import -f integration/bash-completion
  ble-import -f integration/zoxide
  ble-import -f integration/fzf-initialize
  ble-import -d integration/fzf-completion
  ble-import -d integration/fzf-key-bindings
fi

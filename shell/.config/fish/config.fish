source /usr/share/cachyos-fish-config/cachyos-config.fish

# Remove Greeting Message at startup
set fish_greeting

starship init fish | source
zoxide init --cmd cd fish | source

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

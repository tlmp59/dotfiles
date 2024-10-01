if status is-interactive 
    # Commands to run in interactive sessions can go here
end

# setting
set -g fish_greeting #-- disable fish greating
set -gx EDITOR nvim

# Enable packages (should be place before any alias or abbr)
zoxide init fish | source

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

# Adding abbreviations
abbr --add wo wsl-open
abbr --add wezterm --position command nvim ~/.dotfiles/wezterm/.wezterm.lua
abbr --add env_dbt source ~/codespace/python/package/dbt-env/bin/activate.fish

# Adding alias
# uses dircolors template
alias ls='eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions'
alias cd="z"
alias vi="nvim"



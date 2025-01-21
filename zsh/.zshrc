# ~~~~~~~~~~~~~~~~~~~ History ~~~~~~~~~~~~~~~~~~~~~~~~
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt HIST_IGNORE_SPACE  # don't save when prefixed with space
setopt HIST_IGNORE_DUPS   # don't save duplicate lines
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY      # share history between sessions
setopt APPEND_HISTORY

# ~~~~~~~~~~~~ Environment Variables ~~~~~~~~~~~~~~~~~
set -o vi

export VISUAL='nvim'
export EDITOR='nvim'

export BROWSER="brave"
export SPACESHIP_CONFIG="$HOME/.config/zsh/plugins/spaceship.zsh"

# ~~~~~~~~~~~~~~~ Path configuration ~~~~~~~~~~~~~~~~~~~~~~~~
setopt extended_glob null_glob

path=(
    $path                           # Keep existing PATH entries
    $HOME/bin
    $HOME/.local/bin
    $HOME/.cargo/bin
    $HOME/.fzf/bin/
)

# Remove duplicate entries and non-existent directories
typeset -U path
path=($^path(N-/))

export PATH

# ~~~~~~~~~~~~~~~~~~~ Plugins ~~~~~~~~~~~~~~~~~~~~~~~~
# source: https://github.com/mattmc3/zsh_unplugged
    # plugins manager script location
ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}
source $ZPLUGINDIR/manager.zsh

    # list plugins repo
repos=(
    spaceship-prompt/spaceship-prompt
    zsh-users/zsh-completions
    zsh-users/zsh-syntax-highlighting
    zsh-users/zsh-history-substring-search
    zsh-users/zsh-autosuggestions
)

    # load plugins
plugin-load $repos

# ~~~~~~~~~~~~~~~~~~~ Keymaps ~~~~~~~~~~~~~~~~~~~~~~
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# ~~~~~~~~~~~~~~~ Sourcing ~~~~~~~~~~~~~~~~~~~~~~~~~
source <(fzf --zsh)
eval "$(zoxide init zsh)"

# ~~~~~~~~~~~~~~~~~~~ Aliases ~~~~~~~~~~~~~~~~~~~~~~~~
alias cd=z
alias wo=wsl-open
alias ls='eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions'
alias ll='ls -alF'
alias la='ls -A'
alias wezterm='nvim ~/.dotfiles/wezterm/.wezterm.lua'
alias c=clear
alias t=tmux
alias vi=nvim
alias weka='~/packages/app/weka-3-9-6/weka.sh'

    # recommened function from yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

    # recommened function from lazygit
function lg()
{
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

    lazygit "$@"

    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
            cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
            rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
    fi
}

# ~~~~~~~~~~~~~~~~~~~ Misc ~~~~~~~~~~~~~~~~~~~~~~~~~
    # disable notification sound
unsetopt BEEP
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'
zstyle ':completion:*' menu select
setopt auto_cd

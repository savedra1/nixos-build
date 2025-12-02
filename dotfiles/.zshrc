# =====================
# Initial Configuration
# =====================

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =================
# Theme Configuration
# =================

# Set name of the theme to load.
ZSH_THEME="powerlevel10k/powerlevel10k"
source ~/powerlevel10k/powerlevel10k.zsh-theme

HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
source /nix/store/9vjgzqbj1i9qqznrqvh4g6k5kvd89y4v-zsh-autosuggestions-0.7.1/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =================
# Plugin Configuration
# =================

# Plugins
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git)

# ===============
# Aliases
# ===============

# Flake build alias
alias flake-build='sudo nixos-rebuild switch --flake "$(pwd)#mySystem" && home-manager switch --flake "$(pwd)#myUser" --extra-experimental-features nix-command --extra-experimental-features flakes'
# Flake update
alias flake-update='sudo nix flake update --extra-experimental-features nix-command --extra-experimental-features flakes && flake-build'
# NixOS clean
alias nixos-clean='sudo nix-env --delete-generations old -p /nix/var/nix/profiles/system && sudo nix-collect-garbage -d && flake-build'
# Enter shell with go-based draw CLI app. Creds to https://github.com/maaslalani/draw
alias draw='cd /home/michael/nix-shells && nix-shell draw-shell.nix --run "draw"'

# Custom CLI I built, need to get this set up as part of the OS config
# Installable with command: go install github.com/MichaelSavedra1/weather/weather@latest
alias weather='/home/michael/go/bin/weather'

# Detailed ls
alias ls='lsd'

# git
alias gs='git status'
alias ga='git add'
alias gc="git commit"
alias gcm="git commit -m"
alias gp="git pull"
alias gf="git fetch"
alias gupdate="git add -A && git commit --amend --no-edit"

# terraform
alias tfi='terraform init'
alias tfp='terraform plan -out terraform.plan'
alias tfa='terraform apply "terraform.plan"'
alias tfsl='terraform state list'

# ===============
# Miscellaneous Configurations
# ===============

# Auto-launch Hyprland
if [ "$(tty)" = "/dev/tty1" ]; then
    exec nixGLIntel Hyprland
fi

eval "$(direnv hook zsh)"

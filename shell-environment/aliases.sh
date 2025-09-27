# -----------------------------------------------------
# ALIASES
# -----------------------------------------------------

# -----------------------------------------------------
# General
# -----------------------------------------------------
alias c='clear'
alias nf='fastfetch'
alias pf='fastfetch'
alias ff='fastfetch'
alias ls='eza -a --icons=always'
alias ll='eza -al --icons=always'
alias lt='eza -a --tree --level=1 --icons=always'
alias shutdown='systemctl poweroff'
alias v='$EDITOR'
alias vim='$EDITOR'
alias ts='~/.config/ml4w/scripts/arch/snapshot.sh'
alias wifi='nmtui'
alias cleanup='~/.config/ml4w/scripts/cleanup.sh'
alias cdh='cd ~/'
alias shell?='echo $SHELL'
alias cdml4w='cd ~/.config/ml4w/settings'
alias bashp='cd ~/.config/bashrc'
alias keyb='cd ~/.config/hypr/conf/keybindings'

alias ls='eza -a --icons=always --group-directories-first'
alias ll='eza -al --icons=always --group-directories-first --header --git'
alias lt='eza -aT --icons=always --group-directories-first --level=2'
alias la='eza -la --icons=always --group-directories-first --git --header'

if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
    alias ccat='bat --plain --paging=never'  # Original cat behavior
    alias batl='bat --paging=always'         # Long files
fi

# Grep with colors and context
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

if command -v trash >/dev/null 2>&1; then
    alias rm='trash'
    alias rmf='/bin/rm -f'     # Force delete when you really mean it
    alias rmrf='/bin/rm -rf'   # Nuke from orbit
fi

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# Quick edits
alias bashrc='$EDITOR ~/.bashrc'
alias vimrc='$EDITOR ~/.vimrc'
alias nvimrc='$EDITOR ~/.config/nvim/init.vim'

# System shortcuts
alias reboot='sudo systemctl reboot'
alias poweroff='sudo systemctl poweroff'
alias suspend='sudo systemctl suspend'
# -----------------------------------------------------
# ML4W Apps
# -----------------------------------------------------
alias ml4w='flatpak run com.ml4w.welcome'
alias ml4w-settings='flatpak run com.ml4w.settings'
alias ml4w-calendar='flatpak run com.ml4w.calendar'
alias ml4w-hyprland='flatpak run com.ml4w.hyprlandsettings'
alias ml4w-sidebar='flatpak run com.ml4w.sidebar'
alias ml4w-options='ml4w-hyprland-setup -m options'
alias ml4w-diagnosis='~/.config/hypr/scripts/diagnosis.sh'
alias ml4w-hyprland-diagnosis='~/.config/hypr/scripts/diagnosis.sh'
alias ml4w-qtile-diagnosis='~/.config/ml4w/qtile/scripts/diagnosis.sh'
alias ml4w-update='~/.config/ml4w/scripts/installupdates.sh'

# -----------------------------------------------------
# Window Managers
# -----------------------------------------------------

alias Qtile='startx'
# Hyprland with Hyprland

# -----------------------------------------------------
# Git
# -----------------------------------------------------
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gst="git stash"
alias gsp="git stash; git pull"
alias gfo="git fetch origin"
alias gcheck="git checkout"
alias gcredential="git config credential.helper store"

# -----------------------------------------------------
# Scripts
# -----------------------------------------------------
alias ascii='~/.config/ml4w/scripts/figlet.sh'

# -----------------------------------------------------
# System
# -----------------------------------------------------
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'

# -----------------------------------------------------
# Qtile
# -----------------------------------------------------
alias res1='xrandr --output DisplayPort-0 --mode 2560x1440 --rate 120'
alias res2='xrandr --output DisplayPort-0 --mode 1920x1080 --rate 120'
alias setkb='setxkbmap de;echo "Keyboard set back to de."'

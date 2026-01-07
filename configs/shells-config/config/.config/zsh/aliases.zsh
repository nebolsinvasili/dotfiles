alias grub-update="sudo grub-mkconfig -o /boot/grub/grub.cfg"

# pacman related
alias pcs="sudo pacman -S"
alias pcr="sudo pacman -R"
alias pcrs="sudo pacman -Rs"

alias ls='exa -lah --color --icons'

alias r='ranger'

alias vi='nvim'

alias c='clear'
alias q='exit'

alias mkdircd='mkdircd() { mkdir -p "$1" && cd "$1"; } && mkdircd'

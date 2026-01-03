#!/bin/sh

yay -S pyenv poetry tk --noconfirm

poetry config virtualenvs.create false --local # Local configuration

cat << 'EOF' >> ~/.zshrc
# ------ PYENV ------
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
EOF

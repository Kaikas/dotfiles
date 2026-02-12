#!/usr/bin/env bash
set -euo pipefail

PLUG_PATH="$HOME/.vim/autoload/plug.vim"

if [ ! -f "$PLUG_PATH" ]; then
    echo "Installing vim-plug..."

    curl -fLo "$PLUG_PATH" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

else
    echo "vim-plug already installed."
fi

echo "Running PlugInstall..."
vim +PlugInstall +qall

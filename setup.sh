#!/bin/bash

set -e

echo "🚀 Setting up development environment..."

# --------------------------------------------------
# Install Homebrew if not installed
# --------------------------------------------------
if ! command -v brew &>/dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# --------------------------------------------------
# Install packages
# --------------------------------------------------
echo "📦 Installing packages..."
brew install git
brew install neovim
brew install fzf
brew install tmux
brew install --cask ghostty

# 
brew install python
brew install node

# Code formatters and linters
brew install shfmt
brew install node

pip3 install black isort flake8
npm install -g prettier

# --------------------------------------------------
# Setup fzf keybindings
# --------------------------------------------------
if [ -f "$(brew --prefix)/opt/fzf/install" ]; then
    echo "🔍 Setting up fzf..."
    $(brew --prefix)/opt/fzf/install --all
fi

# --------------------------------------------------
# Copy dotfiles
# --------------------------------------------------
echo "📁 Copying config files..."

mkdir -p ~/.config/nvim

cp .config/nvim/init.lua ~/.config/nvim/init.lua
cp .tmux.conf ~/.tmux.conf

# --------------------------------------------------
# Install Neovim plugins automatically
# --------------------------------------------------
echo "⚙️ Installing Neovim plugins..."
nvim --headless "+Lazy! sync" +qa

echo "✅ Setup complete!"

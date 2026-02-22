#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Bootstrapping macOS development environment..."

#############################################
# Install Homebrew if missing
#############################################
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)" || true
else
  echo "✅ Homebrew already installed"
fi

#############################################
# Install packages from Brewfile
#############################################
echo "📦 Installing packages from Brewfile..."
brew bundle --file=./Brewfile

#############################################
# Create config directories
#############################################
mkdir -p ~/.config/nvim

#############################################
# Symlink configs (safe + idempotent)
#############################################
link_file () {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ]; then
    echo "🔗 $dest already symlinked"
  elif [ -e "$dest" ]; then
    echo "⚠️  Backing up existing $dest"
    mv "$dest" "$dest.backup.$(date +%s)"
    ln -s "$src" "$dest"
  else
    ln -s "$src" "$dest"
    echo "🔗 Linked $dest"
  fi
}

echo "🔗 Linking config files..."

link_file "$(pwd)/nvim/init.lua" "$HOME/.config/nvim/init.lua"
link_file "$(pwd)/tmux/.tmux.conf" "$HOME/.tmux.conf"
link_file "$(pwd)/zsh/.zshrc" "$HOME/.zshrc"

#############################################
# Install fzf keybindings (if not present)
#############################################
if [ ! -f ~/.fzf.zsh ]; then
  $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-bash --no-fish
fi

#############################################
# Install Neovim plugins
#############################################
echo "⚙️ Installing Neovim plugins..."
nvim --headless "+Lazy! sync" +qa || true

#############################################
# Launch GUI apps once
#############################################
open -g -a Rectangle || true
open -g -a "Scroll Reverser" || true

echo "🎉 Bootstrap complete."

#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Dotfiles installation starting..."
echo "    Dotfiles directory: $DOTFILES_DIR"

UNAME_S="$(uname -s)"
case "$UNAME_S" in
  Darwin)
    PLATFORM="macos"
    ;;
  Linux)
    PLATFORM="linux"
    ;;
  *)
    echo "Error: Unsupported platform: $UNAME_S"
    exit 1
    ;;
esac

echo "==> Detected platform: $PLATFORM"

# ------------------------------------------------------------------------------
# 1. Run platform bootstrap
# ------------------------------------------------------------------------------
if [[ "$PLATFORM" == "macos" ]]; then
  "$DOTFILES_DIR/install/macos.sh" "$DOTFILES_DIR"
else
  "$DOTFILES_DIR/install/linux.sh" "$DOTFILES_DIR"
fi

# ------------------------------------------------------------------------------
# 2. Install fzf-tab (not available via package managers)
# ------------------------------------------------------------------------------
FZF_TAB_DIR="$HOME/.local/share/fzf-tab"
if [[ ! -d "$FZF_TAB_DIR" ]]; then
  echo "==> Installing fzf-tab..."
  git clone https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
else
  echo "==> fzf-tab already installed"
fi

# ------------------------------------------------------------------------------
# 3. Setup LazyVim (clone starter if nvim dir is empty)
# ------------------------------------------------------------------------------
NVIM_DIR="$DOTFILES_DIR/nvim"
if [[ ! -f "$NVIM_DIR/init.lua" ]]; then
  echo "==> Setting up LazyVim starter..."
  if [[ -d "$HOME/.config/nvim" ]] && [[ ! -L "$HOME/.config/nvim" ]]; then
    echo "    Backing up existing nvim config..."
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"
  fi

  rm -rf "$NVIM_DIR"
  git clone https://github.com/LazyVim/starter "$NVIM_DIR"
  rm -rf "$NVIM_DIR/.git"
else
  echo "==> LazyVim already configured"
fi

# ------------------------------------------------------------------------------
# 4. Create symbolic links
# ------------------------------------------------------------------------------
echo "==> Creating symbolic links..."

create_symlink() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"
  if [[ -L "$target" ]] || [[ -f "$target" ]]; then
    rm -f "$target"
  fi

  ln -sf "$source" "$target"
  echo "    $target -> $source"
}

# zsh
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# git
create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# ghostty
create_symlink "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"

# starship
create_symlink "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# tmux
create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# neovim
if [[ -d "$HOME/.config/nvim" ]] && [[ ! -L "$HOME/.config/nvim" ]]; then
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"
fi
rm -rf "$HOME/.config/nvim"
ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
echo "    $HOME/.config/nvim -> $DOTFILES_DIR/nvim"

# opencode
create_symlink "$DOTFILES_DIR/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
create_symlink "$DOTFILES_DIR/opencode/themes/my-theme.json" "$HOME/.config/opencode/themes/my-theme.json"

# ------------------------------------------------------------------------------
# 5. Setup fzf key bindings and completion
# ------------------------------------------------------------------------------
echo "==> Setting up fzf..."
if command -v brew >/dev/null 2>&1 && [[ -f "$(brew --prefix)/opt/fzf/install" ]]; then
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
fi

# ------------------------------------------------------------------------------
# 6. Setup mise (version manager)
# ------------------------------------------------------------------------------
echo "==> Setting up mise..."
create_symlink "$DOTFILES_DIR/mise/.mise.toml" "$HOME/.mise.toml"

if command -v mise >/dev/null 2>&1; then
  echo "==> Installing mise tools (node, bun)..."
  mise install
  mise trust "$HOME/.mise.toml"
  mise settings set trusted_config_paths "~/workspaces"
fi

# ------------------------------------------------------------------------------
# 7. Install bun global packages
# ------------------------------------------------------------------------------
echo "==> Installing bun global packages..."
if command -v bun >/dev/null 2>&1; then
  while IFS= read -r package || [[ -n "$package" ]]; do
    [[ "$package" =~ ^#.*$ ]] && continue
    [[ -z "$package" ]] && continue
    echo "    Installing $package..."
    bun add -g "$package" 2>/dev/null || true
  done < "$DOTFILES_DIR/bun/global-packages.txt"
fi

# ------------------------------------------------------------------------------
# 8. Install custom scripts
# ------------------------------------------------------------------------------
echo "==> Installing custom scripts..."
mkdir -p "$HOME/.local/bin"
create_symlink "$DOTFILES_DIR/scripts/dev" "$HOME/.local/bin/dev"

echo ""
echo "==> Installation complete!"
echo ""
echo "    Please restart your terminal or run:"
echo "      source ~/.zshrc"
echo ""
echo "    On first launch, Neovim will automatically install plugins."
echo ""
echo "    Installed development tools (via mise):"
echo "      - Node.js (LTS)"
echo "      - Bun (latest)"
echo ""
echo "    Quick commands:"
echo "      dev                    # Start dev session in current dir"
echo "      dev s1                 # Create worktree + session"
echo "      dev -l                 # List sessions"
echo "      dev -c s1              # Clean up session"

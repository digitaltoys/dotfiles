#!/bin/bash

set -euo pipefail

DOTFILES_DIR="${1:?dotfiles directory is required}"

# 1) Install Homebrew (if needed)
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is available in this shell
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 2) Install packages from macOS Brewfile
local_brewfile="$DOTFILES_DIR/Brewfile.macos"
if [[ ! -f "$local_brewfile" ]]; then
  local_brewfile="$DOTFILES_DIR/Brewfile"
fi

echo "==> Installing macOS packages from: $local_brewfile"
BREW_BUNDLE_FAILED=0
if ! brew bundle --file="$local_brewfile"; then
  BREW_BUNDLE_FAILED=1
  echo "WARN: brew bundle failed, but continuing..."
fi

# 3) macOS-only symlink (karabiner)
mkdir -p "$HOME/.config/karabiner"
ln -sf "$DOTFILES_DIR/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

# 4) macOS defaults
if [[ -x "$DOTFILES_DIR/macos.sh" ]]; then
  echo "==> Applying macOS settings..."
  "$DOTFILES_DIR/macos.sh"
fi

if [[ "$BREW_BUNDLE_FAILED" -eq 1 ]]; then
  echo ""
  echo "    Note: Some macOS Brewfile dependencies failed to install."
  echo "    Retry with: brew bundle --file=\"$local_brewfile\""
fi

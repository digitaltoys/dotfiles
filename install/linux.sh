#!/bin/bash

set -euo pipefail

DOTFILES_DIR="${1:?dotfiles directory is required}"

install_apt_packages() {
  local apt_file="$DOTFILES_DIR/linux-packages.txt"

  if [[ ! -f "$apt_file" ]]; then
    return
  fi

  if ! command -v apt-get >/dev/null 2>&1; then
    echo "WARN: apt-get not found; skipping linux-packages.txt installation"
    return
  fi

  if ! command -v sudo >/dev/null 2>&1; then
    echo "WARN: sudo not found; skipping apt package installation"
    return
  fi

  # Some containerized environments set "no new privileges", making sudo unusable.
  if ! sudo -n true >/dev/null 2>&1; then
    echo "WARN: sudo is not usable in this environment; skipping apt package installation"
    return
  fi

  mapfile -t pkgs < <(grep -Ev '^\s*(#|$)' "$apt_file")
  if [[ "${#pkgs[@]}" -eq 0 ]]; then
    return
  fi

  echo "==> Installing Linux packages via apt..."
  sudo apt-get update
  sudo apt-get install -y "${pkgs[@]}"
}

install_brew_packages_if_available() {
  local brewfile="$DOTFILES_DIR/Brewfile.linux"

  if ! command -v brew >/dev/null 2>&1; then
    return
  fi

  if [[ ! -f "$brewfile" ]]; then
    return
  fi

  echo "==> Installing Linux Homebrew packages from: $brewfile"
  if ! brew bundle --file="$brewfile"; then
    echo "WARN: Linux brew bundle failed; continuing..."
  fi
}

install_apt_packages
install_brew_packages_if_available

# ==============================================================================
# Zsh entrypoint
# - Loads common settings
# - Loads platform specific settings
# ==============================================================================

ZSH_DOTFILES_DIR="${HOME}/dotfiles/zsh"
if [[ ! -d "$ZSH_DOTFILES_DIR" ]]; then
  ZSH_DOTFILES_DIR="${0:A:h}"
fi

if [[ -f "$ZSH_DOTFILES_DIR/.zshrc.common" ]]; then
  source "$ZSH_DOTFILES_DIR/.zshrc.common"
fi

case "$(uname -s)" in
  Darwin)
    [[ -f "$ZSH_DOTFILES_DIR/.zshrc.macos" ]] && source "$ZSH_DOTFILES_DIR/.zshrc.macos"
    ;;
  Linux)
    [[ -f "$ZSH_DOTFILES_DIR/.zshrc.linux" ]] && source "$ZSH_DOTFILES_DIR/.zshrc.linux"
    ;;
esac

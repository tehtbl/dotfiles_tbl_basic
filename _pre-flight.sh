#!/bin/bash

set -e

git -C "${HOME}/.oh-my-zsh" pull || \
  git clone https://github.com/robbyrussell/oh-my-zsh.git ${HOME}/.oh-my-zsh

git -C "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" pull || \
  git clone https://github.com/romkatv/powerlevel10k.git "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k"

git -C "${HOME}/.oh-my-zsh/custom/themes/spaceship-prompt" pull || \
  git clone https://github.com/denysdovhan/spaceship-prompt.git "${HOME}/.oh-my-zsh/custom/themes/spaceship-prompt"

ln -sf "${HOME}/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "${HOME}/.oh-my-zsh/custom/themes/spaceship.zsh-theme"

git -C "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" pull || \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

git -C "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" pull || \
  git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

which tmux &> /dev/null || (echo "do: sudo apt install tmux" && exit 1)
which fc-cache &> /dev/null || (echo "do: sudo apt install fontconfig" && exit 1)

exit 0

#!/bin/bash

set -e

git -C "${HOME}/.oh-my-zsh" pull || \
  git clone https://github.com/robbyrussell/oh-my-zsh.git "${HOME}/.oh-my-zsh"

git -C "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" pull || \
  git clone https://github.com/romkatv/powerlevel10k.git "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k"

git -C "${HOME}/.oh-my-zsh/custom/themes/spaceship-prompt" pull || \
  git clone https://github.com/denysdovhan/spaceship-prompt.git "${HOME}/.oh-my-zsh/custom/themes/spaceship-prompt"

ln -sf "${HOME}/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "${HOME}/.oh-my-zsh/custom/themes/spaceship.zsh-theme"

git -C "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" pull || \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

git -C "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" pull || \
  git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

# which tmux &> /dev/null || (echo "do: sudo apt install tmux" && exit 1)
# which fc-cache &> /dev/null || (echo "do: sudo apt install fontconfig" && exit 1)

if [[ $OSTYPE =~ ^linux ]];
then
  echo "[*] checking for installed packages"
  FONT_PACKAGES="fonts-powerline powerline python3-powerline fontconfig tmux"
  for f in ${FONT_PACKAGES};
  do
    dpkg -l "${f}" &> /dev/null || (echo ">>> do: sudo apt install ${FONT_PACKAGES}" && exit 1)
  done
fi

exit 0

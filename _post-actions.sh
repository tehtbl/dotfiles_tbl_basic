#!/bin/bash

set -e

if [[ -d "${HOME}/.tmux/plugins/tpm" ]];
then
  echo "TMUX TPM already installed"
else
  git -C "${HOME}/.tmux/plugins/tpm" pull || \
    git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
fi

if [[ -f "${HOME}/.fonts/PowerlineSymbols.otf" ]];
then
  echo "Fonts already installed"
else
  mkdir -p "${HOME}/.fonts ${HOME}/.config/fontconfig/conf.d"
  wget -P "${HOME}/.fonts" https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf &> /dev/null
  wget -P "${HOME}/.config/fontconfig/conf.d/" https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf &> /dev/null

  fc-cache -vf "${HOME}/.fonts/" &> /dev/null
fi

if [[ -d "${HOME}/.tmux/plugins/tmux-plugin-sysstat" ]];
then
  echo "TMUX plugins already installed"
else
  tmux new -d -s __noop >/dev/null 2>&1 || true
  tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "${HOME}/.tmux/plugins"
  ./"${HOME}"/.tmux/plugins/tpm/bin/install_plugins
  tmux kill-session -t __noop >/dev/null 2>&1
fi

echo ">>> Don't forget to reboot if you have installed new fonts packages!"

exit 0

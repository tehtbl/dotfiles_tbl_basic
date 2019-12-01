#!/bin/bash

set -e

git -C "${HOME}/.tmux/plugins/tpm" pull || \
  git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"

mkdir -p ${HOME}/.fonts ${HOME}/.config/fontconfig/conf.d

wget -P ${HOME}/.fonts https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf &> /dev/null
wget -P ${HOME}/.config/fontconfig/conf.d/ https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf &> /dev/null

fc-cache -vf ${HOME}/.fonts/ &> /dev/null

tmux new -d -s __noop >/dev/null 2>&1 || true
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "${HOME}/.tmux/plugins"

exec "${HOME}/.tmux/plugins/tpm/bin/install_plugins"

tmux kill-session -t __noop >/dev/null 2>&1

exit 0

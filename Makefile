# Shell to use
SHELL := /bin/bash

# The directory of this file
MY_DIR := $(shell echo $(shell cd "$(shell  dirname "${BASH_SOURCE[0]}" )" && pwd ))

# Set date for later use
MY_DATE := $(shell date +'%Y%m%d')

# Dotfiles
DOTFILES_DIR := $(MY_DIR)/dotfiles
MY_FILES := $(shell ls -A $(DOTFILES_DIR))
DOTFILES := $(addprefix $(HOME)/,$(MY_FILES))

# Prints a help for the Makefile.
.PHONY: help
help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# make targets PHONY
.PHONY: preflightcheck all link postinsttmux
all: preflightcheck link postinsttmux ## make all targets

link: | $(DOTFILES) ## interactively add symbolic dotfile links // actually copy not linking

# Actually update/copy the dotfiles
$(DOTFILES):
	@echo "Linking dotfiles"
	@mv -v "$(dir $@).$(notdir $@)" "$(dir $@).$(notdir $@).bck-$(MY_DATE)" &>/dev/null || continue
	@cp -av "$(DOTFILES_DIR)/$(notdir $@)" "$(dir $@).$(notdir $@)"

preflightcheck: ## check if all dotfiles can be installed and used as expected
	@echo "updating ZSH git repos"

	@git -C $(HOME)/.oh-my-zsh pull || \
		git clone https://github.com/robbyrussell/oh-my-zsh.git $(HOME)/.oh-my-zsh &> /dev/null
	@git -C $(HOME)/.oh-my-zsh/custom/themes/powerlevel10k pull || \
		git clone https://github.com/romkatv/powerlevel10k.git $(HOME)/.oh-my-zsh/custom/themes/powerlevel10k
	@git -C $(HOME)/.oh-my-zsh/custom/themes/spaceship-prompt pull || \
		git clone https://github.com/denysdovhan/spaceship-prompt.git $(HOME)/.oh-my-zsh/custom/themes/spaceship-prompt

	@git -C $(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting pull || \
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	@git -C $(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions pull || \
		git clone https://github.com/zsh-users/zsh-autosuggestions $(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions

	@echo "checking for tmux related requirements"

	@bash -c "which tmux &> /dev/null || (echo 'do: sudo apt install tmux' && exit 1)"
	@bash -c "which fc-cache &> /dev/null || (echo 'do: sudo apt install fontconfig' && exit 1)"

postinsttmux: ## install tmux tpm etc after config is linked
	@git -C $(HOME)/.tmux/plugins/tpm pull || \
		git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm
	mkdir -p $(HOME)/.fonts $(HOME)/.config/fontconfig/conf.d
	wget -P $(HOME)/.fonts https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf &> /dev/null
	wget -P $(HOME)/.config/fontconfig/conf.d/ https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf &> /dev/null
	fc-cache -vf $(HOME)/.fonts/ &> /dev/null
	printf "Install TPM plugins\n"
	tmux new -d -s __noop >/dev/null 2>&1 || true
	tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins"
	"$HOME/.tmux/plugins/tpm/bin/install_plugins" || true
	tmux kill-session -t __noop >/dev/null 2>&1 || true


# Testing
.PHONY: shellcheck

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

shellcheck: ## Runs the shellcheck tests on the scripts.
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v $(DOTFILES_DIR):/usr/src:ro \
		--workdir /usr/src \
		r.j3ss.co/shellcheck ./.test.sh

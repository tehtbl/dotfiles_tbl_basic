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

MY_BASHFILES := $(shell ls -A $(DOTFILES_DIR)/bash* $(DOTFILES_DIR)/my_* $(DOTFILES_DIR)/vimrc)
BASHDOTFILES := $(addprefix $(HOME)/,$(MY_BASHFILES))

# Prints a help for the Makefile
.PHONY: help
help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Make targets PHONY
.PHONY: all link preflight postactions
all: preflight link postactions ## make all targets

link: | $(DOTFILES) ## add dotfiles // actually copy not linking

# Actually update/copy the dotfiles
$(DOTFILES):
	@echo "[*] Linking $(notdir $@)"
	@rm -rf "$(dir $@).$(notdir $@).bck-*"
	@mv "$(dir $@).$(notdir $@)" "$(dir $@).$(notdir $@).bck-$(MY_DATE)" &>/dev/null || continue
	@cp -a "$(DOTFILES_DIR)/$(notdir $@)" "$(dir $@).$(notdir $@)"

bash: | $(BASHDOTFILES) ## add bash dotfiles // actually copy not linking

$(BASHDOTFILES):
	@echo "[*] Linking $(notdir $@)"
	@rm -rf "$(HOME)/.$(notdir $@).bck-*"
	@cp -a "$(DOTFILES_DIR)/$(notdir $@)" "$(HOME)/.$(notdir $@)"

preflight: ## check if all dotfiles can be installed and used as expected
	@echo "[*] preparing to fly"
	@bash "$(MY_DIR)/_pre-flight.sh"

postactions: ## install tmux tpm etc after config is linked
	@echo "[*] doing post actions"
	@bash "$(MY_DIR)/_post-actions.sh"

# Testing
.PHONY: test shellcheck
test: shellcheck

# If this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

shellcheck: ## runs the shellcheck tests
	@docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v $(MY_DIR):/usr/src:ro \
		--workdir /usr/src \
		r.j3ss.co/shellcheck /bin/bash .test.sh

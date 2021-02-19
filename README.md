

# REMARK

*ATTENTION:* DO NOT use this repo at the moment! I am currently re-organizing.





<a href="https://travis-ci.org/tehtbl/dotfiles_tbl_basic"><img src="https://travis-ci.org/tehtbl/dotfiles_tbl_basic.svg?branch=master" alt="Build status"/></a>

Description
===========

This repo houses my essential dotfiles, e.g. Bash, Zsh, vimrc, ...

Requirements
============

The system these dotfiles needs support for working with:

* Makefile
* git

How To Use
==========

Simply type: `make help`

# TODO
- install fonts and iterm2 integration
-

```
zsh
rm -rf .zlogin .zlogout .zpreztorc .zprofile .zshenv .zshrc
```

```
git clone --recursive https://github.com/tehtbl/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
```

```
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
```

```
cp gitconfig
cp vimrc vim/
```
```
brew tap homebrew/cask-fonts
brew install font-hack-nerd-font
```

License
=======

GNU General Public License v3.0

Author Information
==================

<a href="https://github.com/tehtbl"><img src="https://img.shields.io/badge/GitHub-tehtbl-blue/?style=flat&logo=github" /></a> <a href="https://twitter.com/tehtbl"><img src="https://img.shields.io/badge/Twitter-tehtbl-blue/?style=flat&logo=twitter" /></a>

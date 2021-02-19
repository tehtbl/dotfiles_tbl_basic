#!/usr/bin/env zsh

local -r font_base_url='https://github.com/romkatv/powerlevel10k-media/raw/master'
local iterm2_old_font=0 can_install_font=0

function iterm_get() {
  /usr/libexec/PlistBuddy -c "Print :$1" ~/Library/Preferences/com.googlecode.iterm2.plist
}

# print "$(iterm_get '"Default Bookmark Guid"' 2>/dev/null)"

if [[ "$(uname)" == Darwin && $TERM_PROGRAM == iTerm.app ]]; then
  print "checking binaries and dirs"

  (( $+commands[curl] )) || return

  [[ $TERM_PROGRAM_VERSION == [2-9]* ]] || return
  if [[ -f ~/Library/Fonts ]]; then
    [[ -d ~/Library/Fonts && -w ~/Library/Fonts ]] || return
  else
    [[ -d ~/Library && -w ~/Library ]] || return
  fi
  [[ -x /usr/libexec/PlistBuddy ]] || return
  [[ -x /usr/bin/plutil ]] || return
  [[ -x /usr/bin/defaults ]] || return
  [[ -f ~/Library/Preferences/com.googlecode.iterm2.plist ]] || return
  [[ -r ~/Library/Preferences/com.googlecode.iterm2.plist ]] || return
  [[ -w ~/Library/Preferences/com.googlecode.iterm2.plist ]] || return

  local guid1 && guid1="$(iterm_get '"Default Bookmark Guid"' 2>/dev/null)" || return
  local guid2 && guid2="$(iterm_get '"New Bookmarks":0:"Guid"' 2>/dev/null)" || return
  local font && font="$(iterm_get '"New Bookmarks":0:"Normal Font"' 2>/dev/null)" || return

  [[ $guid1 == $guid2 ]] || return

  print "checking fonts"

  [[ $font != 'MesloLGS-NF-Regular '<-> ]] || return
  [[ $font == (#b)*' '(<->) ]] || return
  [[ $font == 'MesloLGSNer-Regular '<-> ]] && iterm2_old_font=1

  iterm2_font_size=24
  terminal=iTerm2
  return 0
fi

print "download font"
# command mkdir -p -- ~/Library/Fonts || quit -c

local style
for style in Regular Bold Italic 'Bold Italic'; do
  local file="MesloLGS NF ${style}.ttf"
  run_command "Downloading %B$file%b" \
    curl -fsSL -o ~/Library/Fonts/$file.tmp "$font_base_url/${file// /%20}"
  command mv -f -- ~/Library/Fonts/$file{.tmp,} || quit -c
done

print -nP -- "Changing %BiTerm2%b settings ..."
local k t v settings=(
  '"Normal Font"'                                 string '"MesloLGS-NF-Regular '24'"'
  '"Terminal Type"'                               string '"xterm-256color"'
  '"Horizontal Spacing"'                          real   1
  '"Vertical Spacing"'                            real   1
  '"Minimum Contrast"'                            real   0
  '"Use Bold Font"'                               bool   1
  '"Use Bright Bold"'                             bool   1
  '"Use Italic Font"'                             bool   1
  '"ASCII Anti Aliased"'                          bool   1
  '"Non-ASCII Anti Aliased"'                      bool   1
  '"Use Non-ASCII Font"'                          bool   0
  '"Ambiguous Double Width"'                      bool   0
  '"Draw Powerline Glyphs"'                       bool   1
  '"Only The Default BG Color Uses Transparency"' bool   1
)

for k t v in $settings; do
  /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:$k $v" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null && continue
  run_command "" /usr/libexec/PlistBuddy -c "Add :\"New Bookmarks\":0:$k $t $v" ~/Library/Preferences/com.googlecode.iterm2.plist
done

print -P " %2FOK%f"
print -nP "Updating %BiTerm2%b settings cache ..."
run_command "" /usr/bin/defaults read com.googlecode.iterm2
sleep 3
print -P "%2FMeslo Nerd Font%f successfully installed."

() {
  local out
  out=$(/usr/bin/defaults read 'Apple Global Domain' NSQuitAlwaysKeepsWindows 2>/dev/null) || return

  [[ $out == 1 ]] || return
  out="$(iterm_get OpenNoWindowsAtStartup 2>/dev/null)" || return

  [[ $out == false ]]
}

if (( $? )); then
  print -P "Please %Brestart iTerm2%b for the changes to take effect."
else
  print -P "Please %Brestart your computer%b for the changes to take effect."
fi

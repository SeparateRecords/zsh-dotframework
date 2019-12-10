#!/usr/bin/env zsh
: << 'FinishSetupInstructions'
---===≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡===---
There's no "easy install", running arbitrary code is insecure.
You should read of this file and make sure you're okay with what it does.
Sections are titled and commented to make it easier.
Once you've done that, you can run the commands below, which will download the
script and run it. No wizardry.

$ curl -sSL \
    https://raw.githubusercontent.com/SeparateRecords/zsh-dotframework/master/setup.zsh \
    -o ~/Downloads/df-setup
$ . ~/Downloads/df-setup
$ rm ~/Downloads/df-setup

The script will install to ~/.config/zsh (or $XDG_CONFIG_DIR/zsh if set), but
this can be overridden by setting ZSH_CONFIG_DIR. Intermediate directories
will be created as needed.

$ ZSH_CONFIG_DIR=~/zsh . ~/Downloads/df-setup

FinishSetupInstructions


# --- Setup prerequisites ---


# Display a bold and green title in the terminal, then reset colors
title() {
    printf "[$(tput bold)$(tput setaf 2)${1}$(tput sgr0)]\n"
}

# On macOS, `mkdir -p` breaks `mkdir -v`, despite it working in GNU
# extensions. Thanks, Apple. If GNU Coreutils mkdir is available,
# use it instead.
if [[ $(uname) == Darwin ]] && (( ${+commands[gmkdir]} ))
then mkdir="gmkdir"
else mkdir="mkdir"
fi


# --- Begin setup ---


title "Determining ZSH configuration location"
# Set the installation directory using parameter substitution.
# See setup instructions for information on variable preference order.
echo ${ZSH_CONFIG_DIR:=${XDG_CONFIG_DIR:-"$HOME/.config"}/zsh}


title "Creating config structure in $ZSH_CONFIG_DIR"
# Create the directories and push the new config dir to the stack.
# All sections below can assume the CWD is the config dir.
$mkdir -pv "$ZSH_CONFIG_DIR"
pushd "$ZSH_CONFIG_DIR" >/dev/null
$mkdir -pv init.d
touch init_{setup,teardown}.zsh


title "Cloning framework to $ZSH_CONFIG_DIR/.framework"
# The repo contains the orchestrate script and function library.
# These will need to be in place so that things actually function.
git clone https://github.com/SeparateRecords/zsh-dotframework .framework


title "Moving old ZSH init"
# The files that would normally run will need to be moved.
# If the file exists, move it to its new home.
pushd init.d >/dev/null
[[ -f "$HOME/.zshrc" ]] && mv -v "$HOME/.zshrc" "rc.zsh"
[[ -f "$HOME/.zshenv" ]] && mv -v "$HOME/.zshenv" "env.zsh"
[[ -f "$HOME/.zlogin" ]] && mv -v "$HOME/.zlogin" "login.zsh"
[[ -f "$HOME/.zprofile" ]] && mv -v "$HOME/.zprofile" "profile.zsh"
popd


title "Creating new shim at $HOME/.zshrc"
# Somehow need to call the orchestration script on shell startup.
# Create a shim at ~/.zshrc that will set ZSH_CONFIG_DIR and
# start the process.
# This also means that any commands added to that file will still be
# run, and will always be run last.
cat << EOF > $HOME/.zshrc
# This file has been created automatically by the dotframework setup script.
export ZSH_CONFIG_DIR="$ZSH_CONFIG_DIR"

if [[ -f "\$ZSH_CONFIG_DIR/.framework/orchestrate.zsh" ]]; then
    source "\$ZSH_CONFIG_DIR/.framework/orchestrate.zsh"
else
    printf "\$(tput setaf 1)Error:\$(tput sgr0) "
    printf "dotframework: Can't find the orchestration script.\n\n"
fi

# Anything below this should be moved to a script in the init directory.
# $ZSH_CONFIG_DIR/init.d

EOF


title "Creating gitignore"
# Add a gitignore with some sensible defaults.
cat << EOF > .gitignore
# User configuration
init.d/*secret*.zsh

# Don't track the framework
.framework/

# System files
**/.DS_Store
._*
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.Trash-*
*~

EOF


title "Finishing dotframework setup"
# Return to last directory
popd >/dev/null

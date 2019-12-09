#!/usr/bin/env zsh
: << 'FinishSetupInstructions'
---===≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡===---
Hello reader,
    As you're undoubtedly well aware, running arbitrary code is not a secure
practice.  I made you open this file to read the instructions so that
there's more of an incentive to *actually* read what you'll be executing, to
see what it does, and make sure you're alright with it.
    Additionally, there is no "easy install" - you download this script and
execute it.  Running the commands below will work.  Alternatively, copy and
paste this script's contents into your shell session.

    $ curl -sSL \
        https://raw.githubusercontent.com/SeparateRecords/zsh-dotframework/master/setup.zsh \
        -o ~/Downloads/df-setup
    $ . ~/Downloads/df-setup
    $ rm ~/Downloads/df-setup

The installation directory respects your XDG_CONFIG_DIR.  The default can
be overridden by setting ZSH_CONFIG_DIR before running the script, althrough
in most cases you won't need to.

    $ ZSH_CONFIG_DIR=~/.zsh_init . ./Downloads/df-setup

Also note:
o   If neither ZSH_CONFIG_DIR or XDG_CONFIG_DIR are set, the default path is
    ~/.config/zsh
FinishSetupInstructions


# --- Setup prerequisites ---


# Display a bold and green title in the terminal, then reset colors
title() {
    tput bold && tput setaf 2
    echo "[$1]"
    tput sgr0
}

# On macOS, `mkdir -p` breaks `mkdir -v`, despite it working in GNU
# extensions. Thanks, Apple. If GNU Coreutils mkdir is available,
# use it instead.
mkdir="mkdir"
if [[ $(uname) == Darwin ]] && (( ${+commands[gmkdir]} )); then
    mkdir="gmkdir"
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
$mkdir -pv bin init.d
touch init_{setup,teardown}.zsh


title "Cloning framework to $ZSH_CONFIG_DIR/.framework"
# The repo contains the orchestrate script and function library.
# These will need to be in place so that things actually function.
git clone https://github.com/SeparateRecords/zsh-dotframework .framework


title "Moving old ZSH init"
# The files that would normally run will need to be moved.
# If the file exists, move it to its new home.
pushd init.d >/dev/null
[[ -f "$HOME/.zshrc" ]] && mv -v "$HOME/.zshrc" rc.zsh
[[ -f "$HOME/.zshenv" ]] && mv -v "$HOME/.zshenv" env.zsh
[[ -f "$HOME/.zlogin" ]] && mv -v "$HOME/.zlogin" login.zsh
[[ -f "$HOME/.zprofile" ]] && mv -v "$HOME/.zprofile" profile.zsh
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
    printf "dotframework: Can't to find the orchestration script.\n"
    printf "\n"
fi

# Anything below this should be moved to a script in the init directory.
# $ZSH_CONFIG_DIR/init.d

EOF


title "Creating gitignore"
# Add a gitignore with some logical defaults.
cat << EOF > .gitignore
# Don't track the framework
.framework/

# System files
**/.DS_Store

# User configuration
**/*secrets.zsh

EOF


title "Finishing dotframework setup"
# Return to last directory
popd >/dev/null

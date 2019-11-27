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

    $ ZSH_CONFIG_DIR=~/.zsh_init ./Downloads/df-setup

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
# Set the installation directory using parameter substitution
zshconfig=${ZSH_CONFIG_DIR:-${XDG_CONFIG_DIR:-"$HOME/.config"}/zsh}
echo "$zshconfig"


title "Creating config structure in $zshconfig"
# Create the directories and push the new config dir to the stack.
# All sections below can assume the CWD is the config dir.
$mkdir -pv "$zshconfig"
pushd "$zshconfig" >/dev/null
$mkdir -pv bin init.d
touch init_{setup,teardown}.zsh


title "Cloning framework to $zshconfig/.framework"
# The repo contains the orchestrate script and function library.
# These will need to be in place so that things actually function.
git clone -v https://github.com/SeparateRecords/zsh-dotframework .framework


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
export ZSH_CONFIG_DIR="$zshconfig"

if [[ -f "\$ZSH_CONFIG_DIR/.framework/orchestrate.zsh" ]]; then
    source "\$ZSH_CONFIG_DIR/.framework/orchestrate.zsh"
else
    printf "\$(tput setaf 1)Error:\$(tput sgr0) "
    printf "dotframework: Unable to find orchestration script.\n"
    printf "\n"
fi

# Anything below this should be moved to a script in the init directory.
# $zshconfig/init.d

EOF


title "Creating dotfiles repository"
# To back up the init scripts, automatically create a repo in the
# directory, and add a gitignore with some logical defaults.
git init
cat << EOF > .gitignore
.framework/
.DS_Store
EOF


title "Finishing dotframework setup"
# Return to last directory
popd >/dev/null

# Add the following to an init script to use these functions:
# source $ZSH_CONFIG_DIR/.framework/lib_user.zsh

dotframework::update() {
    git -C $ZSH_CONFIG_DIR/.framework pull
}

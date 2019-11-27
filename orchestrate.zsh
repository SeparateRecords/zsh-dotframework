# Touching this file risks messing up your shell.
# Play with it at your own risk!

# Add user binaries to path
# These can be used during setup, because PATH is guaranteed
# to contain the bin directory already.
export PATH="$ZSH_CONFIG_DIR/bin:$PATH"

# Add the functions
source "$ZSH_CONFIG_DIR/.framework/lib.zsh"

# Source init_setup if it exists
if file_at "$ZSH_CONFIG_DIR/init_setup.zsh"; then
    source "$ZSH_CONFIG_DIR/init_setup.zsh"
fi

# Source init scripts
for script in "$ZSH_CONFIG_DIR/init.d/"*.zsh(N); do
    source "$script"
done

# Source init_teardown if it exists
if file_at "$ZSH_CONFIG_DIR/init_teardown.zsh"; then
    source "$ZSH_CONFIG_DIR/init_teardown.zsh"
fi

# Remove all functions defined in lib.zsh
unfunction $(\
    grep ".*() {" "$ZSH_CONFIG_DIR/.framework/lib.zsh" \
    | sed "s/^function[[:space:]]//g" \
    | tr -d "() {" \
)

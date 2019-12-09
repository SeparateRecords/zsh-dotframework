# These functions are readable shorthands for common operations.
# They are present purely to keep these files readable, and should not be
# depended on in ANY scripts outside of this or init.d/

# Usage:  is <shell_flag>
is() {
    [[ -o $1:u ]]
}

# Usage:  has <command>
has() {
    command -v $1 >/dev/null 2>&1
}


# Usage:  on [operating_system]...
on() {
    for name in $@; do
        local expected="$name:l"
        if [[ $expected == macos ]] || [[ $expected == osx ]]; then
            expected="darwin"
        fi
        local os=$(uname)
        [[ $os:l == $expected ]]
    done
}

# Usage:  currently <message>
currently() {
    return 0
}

# Usage:  file_at <path>
file_at() {
    [[ -f $1 ]]
}

# Usage: dir_at <path>
dir_at() {
    [[ -d $1 ]]
}

# Usage:  terminal_is [names...]
terminal_is() {
    [[ ${@[(i)$TERM_PROGRAM]} -le ${#@} ]]
}

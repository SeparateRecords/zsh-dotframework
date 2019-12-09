# dotframework: The ZSH not-framework

Everyone's shell init is unique to them. dotframework is a way to bring structure to chaos, without changing your scripts.

This init framework provides a small library of functions that help keep your scripts readable and maintainable, and a structure similar to [Fish](http://fishshell.com) that makes it easy to modify and modularize your code.

## Setup

See the heredoc at the top of [setup.zsh](https://github.com/SeparateRecords/zsh-dotframework/blob/master/setup.zsh) for instructions on how to set it up.

### Updating

Once installed, because the framework itself is a git repository, all you need to do is pull.

```console
$ git -C $ZSH_CONFIG_DIR/.framework pull
```

## Structure

1. Source `$ZSH_CONFIG_DIR/init_setup.zsh`, if it exists
2. Source `$ZSH_CONFIG_DIR/init.d/*.zsh`, if it contains any files
3. Source `$ZSH_CONFIG_DIR/init_teardown.zsh`, if it exists

Defining variables, functions, and sourcing the scripts is handled by `orchestrate.zsh`

## Variables

### ZSH_CONFIG_DIR

The directory containing your configuration. By default, `~/.config/zsh`.

## Functions

These functions are **only** accessible in your init scripts and exist purely for readability and maintenance.

### **is** _flag_

Check whether a flag is set.

The most common use is to check if the session is interactive.

```zsh
if is interactive; then
    # do a visual thing
fi
```

### **on** _operating\_system..._

Returns 0 if on any of the specified operating systems. Always case insensitive.

This function relies on `uname` being present. If it isn't, it will always return 1.

"macos" and "osx" are aliases for "Darwin"

```zsh
if on macOS; then
    # do some OS-specific logic
elif on linux; then
    # etc...
fi
```

### **has** _command..._

Check if all of the specified commands are available.

```zsh
if on macOS && has guname; then
    local uname_path=$(which guname)
else
    local uname_path=$(which uname)
fi
```

### **currently** _message_

A dummy function that can be redefined later. Used to display a message.

```zsh
if has revolver; then
    currently() {
        revolver update "$@"
    }
fi

# `currently` will just return 0 if not redefined
currently "sourcing plugins"
```

### **dir_at** _path_

Check if a path is a directory.

```zsh
if dir_at ~/.config; then
    # ...
fi
```

### **file_at** _path_

Check if a path is a file.

```zsh
if file_at ~/.config/zsh/init_setup.zsh; then
    # ...
fi
```

### **terminal_is** _name_

Check if the terminal is one of the specified program names.

```zsh
if terminal_is Hyper vscode; then
    # ...
fi
```

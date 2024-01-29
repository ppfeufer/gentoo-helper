#!/usr/bin/env bash

# Aliases

# BAT
if command -v /usr/bin/bat > /dev/null
    then
        alias cat='/usr/bin/bat'
fi

if command -v /usr/bin/batcat > /dev/null
    then
        alias cat='/usr/bin/batcat'
fi

# LSD
if command -v /usr/bin/lsd > /dev/null
    then
        alias ll='/usr/bin/lsd -lh --header --group-directories-first'
        alias la='/usr/bin/lsd -lAh --header --group-directories-first'
elif command -v /snap/bin/lsd > /dev/null  # Ubuntu snap install
    then
        alias ll='/snap/bin/lsd -lh --group-dirs first'
        alias la='/snap/bin/lsd -lAh --group-dirs first'
    else
        alias ll='ls -lh'
        alias la='ls -lAh'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias s='ssh -l root'
alias please='sudo'

# Good old `cls` command
alias cls='clear'

# Make aliases work with sudo
alias sudo='sudo '

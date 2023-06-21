#!/usr/bin/env bash

# Aliases
if command -v lsd > /dev/null
    then
        alias ll='lsd -lh --header'
        alias la='lsd -lAh --header'
    else
        alias ll='ls -lh'
        alias la='ls -lAh'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias s='ssh -l root'
alias please='sudo'

# Make aliases work with sudo
alias sudo='sudo '

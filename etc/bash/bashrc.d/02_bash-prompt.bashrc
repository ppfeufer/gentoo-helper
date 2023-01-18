#!/usr/bin/env bash

# Git
#parse_git_branch() {
#    # Either
##    git name-rev HEAD 2> /dev/null | sed 's#HEAD\ \(.*\)# (git » \1)#'
#
#    # Or
#    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/ (git » \1)/p'
##}

# This is a more sophisticated version of the above
parse_git_branch() {
    local s=''
    local branchName=''

    # Check if the current directory is in a Git repository.
    git rev-parse --is-inside-work-tree &>/dev/null || return

    # Check for what branch we’re on.
    # Get the short symbolic ref. If HEAD isn’t a symbolic ref, get a
    # tracking remote branch or tag. Otherwise, get the
    # short SHA for the latest commit, or give up.
    branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
        git describe --all --exact-match HEAD 2> /dev/null || \
        git rev-parse --short HEAD 2> /dev/null || \
        echo '(unknown)')"

    # Early exit for Chromium & Blink repo, as the dirty check takes too long.
    # Thanks, @paulirish!
    # https://github.com/paulirish/dotfiles/blob/dd33151f/.bash_prompt#L110-L123
    repoUrl="$(git config --get remote.origin.url)"

    if grep -q 'chromium/src.git' <<< "${repoUrl}"
        then
            s+='*'
        else
            # Check for uncommitted changes in the index.
            if ! $(git diff --quiet --ignore-submodules --cached)
                then
                    s+='+'
            fi

            # Check for unstaged changes.
            if ! $(git diff-files --quiet --ignore-submodules --)
                then
                    s+='!'
            fi

            # Check for untracked files.
            if [ -n "$(git ls-files --others --exclude-standard)" ]
                then
                    s+='?'
            fi

            # Check for stashed files.
            if $(git rev-parse --verify refs/stash &>/dev/null)
                then
                    s+='$'
            fi
    fi

    [ -n "${s}" ] && s=" [${s}]"

   echo -e " (git » ${1}${branchName}${2}${s})"
}


# SVN
parse_svn_repository_root() {
    svn info 2>/dev/null | sed -ne 's#^Repository Root: ##p'
}

parse_svn_branch() {
    parse_svn_url | sed -e 's#^'"$(parse_svn_repository_root)"'##g' | awk '{print " (svn » "$1")" }'
}

parse_svn_url() {
    svn info 2>/dev/null | sed -ne 's#^URL: ##p'
}


# Mercurial
parse_hg_branch() {
    hg branch 2> /dev/null | awk '{print " (mercurial » "$1")" }'
}


# Set the versioning system branch name
set_versioning_system_branch() {
    # Let's see if it's a git branch
    versioning_system_branch=$(parse_git_branch)

    # Or maybe SVN
    if [ "$versioning_system_branch" == "" ]
        then
            versioning_system_branch=$(parse_svn_branch)
    fi

    # Or even Mercurial
    if [ "$versioning_system_branch" == "" ]
        then
            versioning_system_branch=$(parse_hg_branch)
    fi
}


# Determine active Python virtualenv details.
set_python_virtual_environment () {
    if [ -z "$VIRTUAL_ENV" ]
        then
            python_virtual_environment=""
        else
            python_virtual_environment="${Cyan}[Python virtual environment: `basename \"$VIRTUAL_ENV\"`]${Color_Off}\n"
    fi
}


# Change the bash prompt
set_bash_prompt() {
    # Set the python_virtual_environment variable.
    set_python_virtual_environment

    # set the versioning_system_branch variable
    set_versioning_system_branch

    if [[ ${EUID} == 0 ]]
        then
            # root
            user_at_host_color=${BRed}
        else
            # normal user
            user_at_host_color=${BGreen}
    fi

    PS1="${python_virtual_environment}" # Python venv
    PS1+="${user_at_host_color}\u@\H " # user@host
    PS1+="${BBlue}\w " # Working directory
    PS1+="\$" # Command prompt ($)
    PS1+="${Red}${versioning_system_branch}" # Versioning system info
    PS1+="${Color_Off}\n» " # Set cursor to new line

    PS2="\[${Yellow}\]→ \[${Color_Off}\]"
}

# Tell bash to execute this function just before displaying its prompt.
PROMPT_COMMAND=set_bash_prompt

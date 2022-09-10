# Git
parse_git_branch() {
    git name-rev HEAD 2> /dev/null | sed 's#HEAD\ \(.*\)# (git » \1)#'
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
            python_virtual_environment="${Cyan}[`basename \"$VIRTUAL_ENV\"`]${Color_Off} "
    fi
}


# Change the bash prompt
set_bash_prompt() {
    # Set the python_virtual_environment variable.
    set_python_virtual_environment

    # set the versioning_system_branch variable
    set_versioning_system_branch

    if [[ ${EUID} == 0 ]] ; then
        # root
        PS1="${python_virtual_environment}${BRed}\u@\h${BBlue} \W \$${Red}${versioning_system_branch}${Color_Off} "
    else
        # normal user
        PS1="${python_virtual_environment}${BGreen}\u@\h${BBlue} \w \$${Red}${versioning_system_branch}${Color_Off} "
    fi
}

# Tell bash to execute this function just before displaying its prompt.
PROMPT_COMMAND=set_bash_prompt

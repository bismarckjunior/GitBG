#! /bin/bash
##############################################################################
# Copyright (C) 2014 Bismarck G. Souza Junior <bismarckgomes@gmail.com>      #
# Distributed under the GNU General Public License, version 3.0.             #
#                                                                            #
# This script allows to change the prompt in git repositories.               #
#                                                                            #
# To enable:                                                                 #
#    1) Copy this file to somewhere (e.g. ~/.gitBG/gitBG.sh).                #
#    2) Add the following line to your .bashrc file:                         #
#        source ~/.gitBG/gitBG.sh                                            #
##############################################################################

# Author data
GITBG_AUTHOR="Bismarck Gomes Souza Junior"
GITBG_EMAIL="bismarckgomes@gmail.com"

# Version
GITBG_VERSION="0.0.1"
GITBG_SITE="http://goo.gl/kVCx8n"

########################### REGULAR COLORS ####################################
GITBG_COLOR_RED="\033[0;31m"            # Red
GITBG_COLOR_RED2="\033[1;31m"           # Red (bold)
GITBG_COLOR_GREEN="\033[0;32m"          # Green
GITBG_COLOR_GREEN2="\033[1;32m"         # Green (bold)
GITBG_COLOR_YELLOW="\033[0;33m"         # Yellow
GITBG_COLOR_YELLOW2="\033[1;33m"        # Yellow (bold)
GITBG_COLOR_BLUE="\033[0;34m"           # Blue
GITBG_COLOR_BLUE2="\033[1;34m"          # Blue (bold)
GITBG_COLOR_MAGENTA="\033[0;35m"        # Magenta
GITBG_COLOR_MAGENTA2="\033[1;35m"       # Magenta (bold)
GITBG_COLOR_CYAN="\033[0;36m"           # Cyan
GITBG_COLOR_CYAN2="\033[1;36m"          # Cyan (bold)
GITBG_COLOR_WHITE="\033[0;37m"          # White
GITBG_COLOR_WHITE2="\033[1;37m"         # White (bold)
###############################################################################

# Checks if it is a git repository
__is_git_repo(){
    if git ls-files >& /dev/null; then
        return 0
    else
        return 1
    fi
}

# Prints git status
__print_git_status(){
    local status=$(GIT_PAGER_IN_USE=true git status -s)

    if [[ $status != "" ]] &&
       [[ $(git config gitBG.maxLineStatus) -gt 1 ]]; then

        lines=$(echo -e "$status" | wc -l)
        maxLine=$(git config gitBG.maxLineStatus)

        echo "$GITBG_COLOR_WHITE\n"
        echo "---------------------------------------------------"

        if [[ $lines -le $maxLine ]]; then
            echo -e "$status"
        else
            echo -e "$status" | head -$(($maxLine-1))
            echo "..\n.."
            echo -e "$status" | tail -1
        fi
        echo "---------------------------------------------------"
    fi
}

# Gets first part of prompt
__get_working_dir(){
    local rep=$(git rev-parse --show-toplevel)
    local repo=${rep##*/}

    if [[ ${PWD##*/} == $repo ]]; then
        echo "$repo"
    else
        echo "$repo | \W"
    fi
}

# Gets commits status
__get_commit_status(){
    co_status=`git status --short -b | head -n1 | cut -d ' ' -f3-`
    n_co=`echo $co_status | cut -d ' ' -f2`

    if [[ $co_status == [ahead* ]]; then
        echo -n "${GITBG_COLOR_GREEN}[$n_co"
        if [[ $co_status == *behind* ]]; then
            echo -n " ${GITBG_COLOR_RED}`echo $co_status | cut -d ' ' -f4`"
        fi
    elif [[ $co_status == [behind* ]]; then
        echo -n "${GITBG_COLOR_RED}[$n_co"
    fi
}

# Returns current branch
__get_current_branch(){
    local current_branch=$(git rev-parse --abbrev-ref --symbolic HEAD)
    local git_dir=$(git rev-parse --git-dir)
    local status=""
    local next=""
    local last=""

    if [[ current_branch -eq HEAD ]]; then
        current_branch=$(git name-rev --name-only HEAD)
    fi

    if [ -d "$git_dir/rebase-merge" ]; then
        # Interactive rebase ("git rebase -i")
        status="|REBASING"
        next=$(cat "$git_dir/rebase-merge/msgnum")
        last=$(cat "$git_dir/rebase-merge/end")

    elif [ -d "$git_dir/rebase-apply" ]; then
        # Normal rebase ("git rebase")
        status="|REBASING"
        next=$(cat "$git_dir/rebase-apply/next")
        last=$(cat "$git_dir/rebase-apply/last")

    elif [ -f "$git_dir/MERGE_HEAD" ]; then
        status="|MERGING $(cat "$git_dir/MERGE_MSG" | wc -l | tr -d ' ')"

    elif [ -f "$git_dir/REVERT_HEAD" ]; then
        status="|REVERTING"

    elif [ -f "$git_dir/CHERRY_PICK_HEAD" ]; then
        status="|CHERRY-PICKING"

    elif [ -f "$git_dir/BISECT_LOG" ]; then
        status="|BISECTING"
    fi

    echo -n "${current_branch##/*}${status}"

    if [[ $next && $last ]]; then
        echo -n " $next/$last"
    fi
}

# Gets branch color
__get_git_color(){
    case $(git status -s) in
        \ M*)
            git config gitBG.color.modifiedFile;;     # Modified files
        \ D*)
            git config gitBG.color.deletedFile;;      # Deleted files
        "??"*)
            git config gitBG.color.newFile;;          # New files
        \ *)
            git config gitBG.color.notAddedFile;;     # Not added to index
        A* | R* | M* | D*)
            git config gitBG.color.addedFile;;        # Added to index
    esac
}

# Starts ssh-agent
__start_ssh_agent(){
    # Starts ssh-agent if does not exist one
    if ! (ps | grep $SSH_AGENT_PID >& /dev/null) ; then
        eval `ssh-agent` >& /dev/null
    fi

    # Kills ssh-agent process in log out (using exit command)
    trap "kill $SSH_AGENT_PID" 0
}

# Adds a ssh-key for a period
__add_ssh_key(){
    # Starts ssh-agent
    __start_ssh_agent

    if [[ `ssh-add -l` != *:*:* ]]; then

        # Print message
        echo -e "\n${GITBG_COLOR_GREEN}Enter your passphrase or press enter to skip...\n"

        # Adds ssh-key
        if [ $(git config gitBG.logoff) == true ];then
            ssh-add -t $(git config gitBG.logonTime) >& /dev/null
        else
            ssh-add >& /dev/null
        fi
    fi

    local connection=""

    # Return connection status
    if [[ `ssh-add -l` == *:*:* ]]; then
        connection="${GITBG_COLOR_GREEN}[CONNECTED]"
    else
        connection="${GITBG_COLOR_RED}[DISCONNECTED]"
    fi

    # Prints header
    __print_header $connection
}

# Kills others ssh-agent process
__kill_ssh_agent_process(){
    l_pid=$(ps | grep -n ".* 1 .*ssh-agent" | sed -r 's/([0-9]+):\s*([0-9]+).*/\1 \2/g')
    n=`echo "$l_pid" | wc -l`

    read -a v_pid <<< $l_pid

    if [[ ${v_pid[0]} -eq 2 ]]; then
        kill ${v_pid[1]}
    fi

    for (( i=1; i < $n; ++i ));
    do
        if [[ ${v_pid[2*i-2]} -eq ${v_pid[2*i]}-1 ]]; then
            kill ${v_pid[2*i+1]}
        fi
    done
}

# Prints title and connection status
__print_header(){
    clear
    echo -e "\e]2;GitBG $GITBG_VERSION\a"
    local header="${GITBG_COLOR_YELLOW2}GitBG $GITBG_VERSION ($GITBG_SITE)"

    # Define columns defalut: 80
    if [ -z $COLUMNS ]; then
        COLUMNS=80
    fi

    # Prints header
    printf "%b%$(($COLUMNS-$(expr ${#header} % $COLUMNS)+16))b\n\n" "$header" "$1"
}

# Define defalut variables
__define_default_variables(){
    # Resets default variables
    git config --global gitBG.reset false

    # Auto SSH logon when start in git repository
    git config --global gitBG.logon true

    # Auto SSH logoff
    git config --global gitBG.logoff false

    # SSH logon time (in seconds)
    git config --global gitBG.logonTime 36000

    # Print "git status" after prompt
    git config --global gitBG.status true

    # Number of lines for "git status" after prompt
    git config --global gitBG.maxLineStatus 15

    # Path for GitBG files
    git config --global gitBG.path "~/GitBG"

    ### Prompt colors  ###
    # Color for modified file
    git config --global gitBG.color.modifiedFile $GITBG_COLOR_GREEN2

    # Color for deleted file
    git config --global gitBG.color.deletedFile $GITBG_COLOR_RED

    # Color for new file
    git config --global gitBG.color.newFile $GITBG_COLOR_CYAN

    # Color for not added file
    git config --global gitBG.color.notAddedFile $GITBG_COLOR_BLUE

    # Color for added file
    git config --global gitBG.color.addedFile $GITBG_COLOR_YELLOW
}

# Gets PS1
__gitBG_prompt(){
    if __is_git_repo; then
        # Print status before
        if [[ $(git config gitBG.status) == true ]]; then
            __print_git_status
        fi

        # Branch color
        local git_color=$(__get_git_color)

        # Gets working directory
        local dir=$(__get_working_dir)

        # Number the commits ahead or behind
        local co_status=$(__get_commit_status)

        # Current branch
        local cb=$(__get_current_branch)

        # PS1 for git folder
        echo -ne "\n${GITBG_COLOR_GREEN}$dir $git_color($cb)$co_status"
        echo "\n${GITBG_COLOR_WHITE}\$ "
    else
        # PS1 for not git folder
        #PS1_OLD="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w\$"
        echo -ne "${GITBG_COLOR_WHITE}$PS1_OLD"
    fi
}

#################################  M A I N  ####################################

# Set default variables
if [[ $(git config gitBG.reset) != false ]]; then
    __define_default_variables
fi

if __is_git_repo; then
    # Prints header
    __print_header

    # Kills others ssh-agent process
    __kill_ssh_agent_process

    # Adds ssh-key and prints the status of connection
    if [[ $(git config gitBG.logon) == true ]]; then
        __add_ssh_key
    fi
fi

# Save old PS1
PS1_OLD=$PS1

# New PS1
PROMPT_COMMAND='PS1="$(__gitBG_prompt)"'

################################################################################

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
GITBG_VERSION="1.1"
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
       [[ $GITBG_MAXLINE_STATUS -gt 1 ]]; then

        lines=$(echo -e "$status" | wc -l)

        echo "$GITBG_COLOR_WHITE\n"
        echo "---------------------------------------------------"

        if [[ $lines -le $GITBG_MAXLINE_STATUS ]]; then
            echo -e "$status"
        else
            echo -e "$status" | head -$(($GITBG_MAXLINE_STATUS-1))
            echo "..\n.."
            echo -e "$status" | tail -1
        fi
        echo "---------------------------------------------------"
    fi
}

# Gets first part of prompt and set title
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
    local current_branch=$(git rev-parse --abbrev-ref --symbolic HEAD 2> /dev/null)
    local git_dir=$(git rev-parse --git-dir)
    local status=""
    local next=""
    local last=""

    if [[ $current_branch == "HEAD" ]]; then
        current_branch=$(git symbolic-ref --short HEAD 2> /dev/null)
    fi

    if [[ $current_branch == "" ]]; then
        current_branch=$(echo "!$(git name-rev --name-only HEAD)")
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
            echo $GITBG_MOD_FILE_COLOR;;     # Modified files
        \ D*)
            echo $GITBG_DEL_FILE_COLOR;;     # Deleted files
        "??"*)
            echo $GITBG_NEW_FILE_COLOR;;     # New files
        \ *)
            echo $GITBG_N_A_FILE_COLOR;;     # Not added to index
        A* | R* | M* | D*)
            echo $GITBG_ADD_FILE_COLOR;;     # Added to index
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
add_ssh_key(){
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

    __print_header_connection
}

__print_header_connection(){

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

# Prints title
__print_title(){
    echo -en "\e]2;GitBG $GITBG_VERSION$1\a"
}

# Prints header and connection status
__print_header(){
    # clear
    printf "\ec"
    local header=" ${GITBG_COLOR_YELLOW2}GitBG $GITBG_VERSION ($GITBG_SITE)"

    # Define columns defalut: 80
    if [ -z $COLUMNS ]; then
        COLUMNS=80
    fi

    # Prints header
    printf "\n%b%$(($COLUMNS-$(expr ${#header} % $COLUMNS)+16))b\n\n" "$header" "$1"

    # Prints title
    __print_title
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

    # Print "git status" with double enter
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

        if [[ $(($(date +%s)-$T_OLD)) -le 2 ]]; then
            # Prints header
            __print_header_connection

            if [[ $GITBG_PRINT_STATUS == true ]]; then
                # Print status before
                __print_git_status
            fi
        fi

        # Branch color
        local git_color=$(__get_git_color)

        # Gets working directory
        local dir=$(__get_working_dir)

        # Number the commits ahead or behind
        local co_status=$(__get_commit_status)

        # Current branch
        local cb=$(__get_current_branch)

        # Prints title
        __print_title " - $dir"

        # PS1 for git folder
        echo -e "\n${GITBG_COLOR_GREEN}$dir $git_color($cb)${co_status}"
        echo -e "${GITBG_COLOR_WHITE}\$ "

    else
        # PS1 for not git folder
        #PS1_OLD="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w\$"
        echo -e "${GITBG_COLOR_WHITE}$PS1_OLD"
    fi
}

#################################  M A I N  ####################################

# Set default variables
if [[ $(git config gitBG.reset) != false ]]; then
    __define_default_variables
fi

# Get varibles for file status
GITBG_MOD_FILE_COLOR=$(git config gitBG.color.modifiedFile)
GITBG_DEL_FILE_COLOR=$(git config gitBG.color.deletedFile)
GITBG_NEW_FILE_COLOR=$(git config gitBG.color.newFile)
GITBG_ADD_FILE_COLOR=$(git config gitBG.color.addedFile)
GITBG_N_A_FILE_COLOR=$(git config gitBG.color.notAddedFile)

if __is_git_repo; then
    # Prints header
    __print_header

    # Kills others ssh-agent process
    __kill_ssh_agent_process

    # Adds ssh-key and prints the status of connection
    if [[ $(git config gitBG.logon) == true ]]; then
        add_ssh_key
    fi
fi

# Old time
T_OLD=$(($(date +%s)-2))

# Save old PS1
PS1_OLD=$PS1

# Get status variables
GITBG_PRINT_STATUS=$(git config gitBG.status)
GITBG_MAXLINE_STATUS=$(git config gitBG.maxLineStatus)

# New PS1
PROMPT_COMMAND='PS1="$(__gitBG_prompt)"; T_OLD=$(($(date +%s)-2));'

################################################################################

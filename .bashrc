# ENV VARIABLES

# editor
export EDITOR="nano"

# colors for directories
export CLICOLOR=1
export LSCOLORS=DxExFxFxfxaxaxaxaxaxax

# ALIASES AND FUNCTIONS

#forgot a sudo? redo!
alias redo='sudo $(history -p \!\!)'

# copy ssh key
alias getssh='pbcopy < ~/.ssh/id_rsa.pub'

# cd into directory and ls it
function cdl() {
  cd $1;
  ls;
}

# make a directory and cd into it
function mdir () {
  mkdir -p "$@" && eval cd "\"\$$#\"";
}

# CUSTOM PS1

# set our PS1 env variable to be
# Default:
#   ~/current/path/to/dir
#   > _
#
# Pristine Git Repo
#   ~/current/path/to/dir [git-branch-name]
#   > _
#
# Dirty Git Repo
#   ~/current/path/to/dir [git-branch-name] Δ
#   > _
#
# Untracked Files in Repo
#   ~/current/path/to/dir [git-branch-name] ??
#   > _
#
# Stashed Changes in Repo
#   ~/current/path/to/dir [git-branch-name] ∴(2)
#   > _
function format_prompt {
  local   GREEN="\[\e[32m\]"
  local   RED="\[\033[1;31m\]"
  local   CYAN="\[\033[1;36m\]"
  local   DEFAULT="\[\033[0m\]"
  local   BLUE="\[\033[0;34m\]"
  local   YELLOWBOLD="\[\033[1;33m\]"

  local PROMPT=">"

  # get git branch name
  function parse_git_branch {
      git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \[#\1\]/'
  }

  # Returns " ∴(N)" where N is the number of stashed states (if any).
  function parse_git_stash {
    local stash=`expr $(git stash list 2>/dev/null| wc -l)`

    if [ "$stash" != "0" ]; then
      echo " ∴($stash)"
    fi
  }

  # figure out if we are in a git repo and if it has uncommitted changes or not
  function parse_git_status {
      # check if we're in a git repo
      local is_git=`git status 2> /dev/null`

      if [ -z "$is_git" ] ; then
          return 1
      fi

      # check if there are changes
      local clean_status=`git status 2> /dev/null | grep "nothing to commit"`
      local untracked_status=`git status 2> /dev/null | grep "Untracked files"`

      # set up our default markers
      local unclean_marker="Δ"
      local untracked_marker="??"

      if [ "$clean_status" != "nothing to commit, working directory clean" ]; then
          if [ "$untracked_status" == "Untracked files:" ]; then
            echo " $untracked_marker"
          else
            echo " $unclean_marker"
          fi
      fi
  }

  export PS1="$CYAN\w$GREEN\$(parse_git_branch)$YELLOWBOLD\$(parse_git_status)$DEFAULT\$(parse_git_stash)\n$RED$PROMPT$DEFAULT "
}

format_prompt

# macOS only
# trigger ssh-agent managing key so we only enter our password once
#if [ -z "$SSH_AUTH_SOCK" ]; then
#  eval `ssh-agent -s`
#  ssh-add -k ~/.ssh/id_rsa
#fi

# rbenv only
# eval "$(rbenv init -)"

# nvm only
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

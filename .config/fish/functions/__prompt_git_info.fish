function __prompt_git_info
  function _git_stash_info
    set stashed (command git stash list 2> /dev/null | wc -l | awk '{print $1}')
    if test -n "$stashed"
      echo -n (set_color blue)"✭ $stashed"(set_color normal)
    end

    functions -e _git_stash_info
  end

  function _git_branch_info
    set branch (command git symbolic-ref HEAD 2> /dev/null | perl -pe 's,^refs/heads/,,')
    if test -n "$branch"
      echo -n (set_color --bold green)$branch(set_color normal)

      set position (command git describe --contains --all HEAD 2> /dev/null)
      echo -n (set_color brmagenta) $position(set_color normal)

      set commit (command git rev-parse HEAD 2> /dev/null | cut -c-7)
      echo -n (set_color yellow) $commit(set_color normal)

      # TODO: action

      set ahead_and_behind (command git rev-list --count --left-right 'HEAD...@{upstream}')
      set ahead (echo -n $ahead_and_behind | cut -f1)
      set behind (echo -n $ahead_and_behind | cut -f2)
      test $ahead -ne 0 ;and echo -n (set_color brmagenta)" ⬆ $ahead"(set_color normal)
      test $behind -ne 0 ;and echo -n (set_color brmagenta)" ⬇ $behind"(set_color normal)
    end

    functions -e _git_branch_info
  end

  function _git_status_info
    set git_status (command git status --porcelain)
    if test -n "$git_status"
      set added 0
      set deleted 0
      set modified 0
      set renamed 0
      set unmerged 0
      set untracked 0
      for line in $git_status
        string match -r '([ACDMT][ MT]|[ACMT]D) *' $line > /dev/null ;and set added (math $added + 1)
        string match -r '[ ACMRT]D *]' $line > /dev/null ;and set deleted (math $deleted + 1)
        string match -r '.?[MT] *' $line > /dev/null ;and set modified (math $modified + 1)
        string match -r 'R? *' $line > /dev/null ;and set renamed (math $renamed + 1)
        string match -r '(AA|DD|U.?|.?U) *' $line > /dev/null ;and set unmerged (math $unmerged + 1)
        string match -r '\?\? *' $line > /dev/null ;and set untracked (math $untracked + 1)
      end

      test $added -ne 0 ;and echo -n (set_color green)"✚ $added"(set_color normal)
      test $deleted -ne 0 ;and echo -n (set_color red)"✖ $deleted"(set_color normal)
      test $modified -ne 0 ;and echo -n (set_color blue)"✱ $modified"(set_color normal)
      test $renamed -ne 0 ;and echo -n (set_color magenta)"➜ $renamed"(set_color normal)
      test $unmerged -ne 0 ;and echo -n (set_color blue)"═ $unmerged"(set_color normal)
      test $untracked -ne 0 ;and echo -n (set_color white)"◼ $untracked"(set_color normal)
    end

    functions -e _git_status_info
  end

  set git_dir (git rev-parse --git-dir 2> /dev/null)
  if test -n "$git_dir"
    _git_branch_info
    _git_stash_info
    _git_status_info
  end
end

function __prompt_git_info
  function _git_action_info
    set -l git_dir $argv[1]

    function __action
      set -l git_dir $argv[1]

      for dir in "$git_dir/rebase-apply" "$git_dir/rebase" "$git_dir/../.dotest"
        if test -d $dir
          echo -n (set_color blue)
          if test -f "$dir/rebasing"
            echo -n rebase
          else if test -f "$dir/applying"
            echo -n apply
          else
            echo -n rebase/apply
          end
          return 0
        end
      end

      for file in "$git_dir/rebase-merge/interactive" "$git_dir/.dotest-merge/interactive"
        if test -f $file
          echo -n rebase-interactive
          return 0
        end
      end

      for dir in "$git_dir/rebase-merge" "$git_dir/.dotest-merge"
        if test -d $dir
          echo -n rebase-merge
          return 0
        end
      end

      if test -f "$dir/MERGE_HEAD"
        echo -n merge
        return 0
      end

      if test -f "$dir/CHERRY_PICK_HEAD"
        if test -d "$dir/sequencer"
          echo -n cherry-pick-sequence
        else
          echo -n cherry-pick
        end
        return 0
      end

      if test -f "$dir/REVERT_HEAD"
        if test -d "$dir/sequencer"
          echo -n revert-sequence
        else
          echo -n revertt
        end
        return 0
      end

      if test -f "$dir/BISECT_LOG"
        echo -n bisect
        return 0
      end

      functions -e __action
    end

    set -l action (__action "$git_dir")
    if test -n "$action"
      echo -n (set_color white):(set_color normal)
      echo -n (set_color -o brred)$action(set_color normal)
    end

    functions -e _git_action_info
  end

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
    end

    set position (command git describe --contains --all HEAD 2> /dev/null)
    if test "$branch" != "$position"
      echo -n (set_color brmagenta) $position(set_color normal)
    else if test -z "$branch"
      echo -n (set_color brmagenta)$position(set_color normal)
    end

    set commit (command git rev-parse HEAD 2> /dev/null | cut -c-7)
    echo -n (set_color yellow) $commit(set_color normal)

    set ahead_and_behind (command git rev-list --count --left-right 'HEAD...@{upstream}' 2> /dev/null)
    if test -n "$ahead_and_behind"
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
        string match -r '^([ACDMT][ MT]|[ACMT]D) *' $line > /dev/null ;and set added (math $added + 1)
        string match -r '^[ ACMRT]D *]' $line > /dev/null ;and set deleted (math $deleted + 1)
        string match -r '^.[MT] *' $line > /dev/null ;and set modified (math $modified + 1)
        string match -r '^R. *' $line > /dev/null ;and set renamed (math $renamed + 1)
        string match -r '^(AA|DD|U.|.U) *' $line > /dev/null ;and set unmerged (math $unmerged + 1)
        string match -r '^\?\? *' $line > /dev/null ;and set untracked (math $untracked + 1)
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
    _git_action_info "$git_dir"
    _git_stash_info
    _git_status_info
  end
end

function __check_settings
  test -n "$FISH_GIT_INFO";           or set -g FISH_GIT_INFO           '%b%p%c:%s%A%B%S%a%d%m%r%U%u%D%C'
  test -n "$FISH_GIT_INFO_VERBOSE";   or set -g FISH_GIT_INFO_VERBOSE   yes
  test -n "$FISH_GIT_INFO_ACTION";    or set -g FISH_GIT_INFO_ACTION    (set_color -o brred)%s      # %s
  test -n "$FISH_GIT_INFO_BRANCH";    or set -g FISH_GIT_INFO_BRANCH    (set_color -o green)'%s '   # %b
  test -n "$FISH_GIT_INFO_POSITION";  or set -g FISH_GIT_INFO_POSITION  (set_color brmagenta)'%s '  # %p
  test -n "$FISH_GIT_INFO_COMMIT";    or set -g FISH_GIT_INFO_COMMIT    (set_color yellow)%s        # %c
  test -n "$FISH_GIT_INFO_STASHED";   or set -g FISH_GIT_INFO_STASHED   (set_color blue)'✭ %d'      # %S
  test -n "$FISH_GIT_INFO_AHEAD";     or set -g FISH_GIT_INFO_AHEAD     (set_color brmagenta)'⬆ %d' # %A
  test -n "$FISH_GIT_INFO_BEHIND";    or set -g FISH_GIT_INFO_BEHIND    (set_color brmagenta)'⬇ %d' # %B
  test -n "$FISH_GIT_INFO_ADDED";     or set -g FISH_GIT_INFO_ADDED     (set_color green)'✚ %d'     # %a
  test -n "$FISH_GIT_INFO_DELETED";   or set -g FISH_GIT_INFO_DELETED   (set_color red)'✖ %d'       # %d
  test -n "$FISH_GIT_INFO_MODIFIED";  or set -g FISH_GIT_INFO_MODIFIED  (set_color blue)'✱ %d'      # %m
  test -n "$FISH_GIT_INFO_RENAMED";   or set -g FISH_GIT_INFO_RENAMED   (set_color magenta)'➜ %d'   # %r
  test -n "$FISH_GIT_INFO_UNMERGED";  or set -g FISH_GIT_INFO_UNMERGED  (set_color blue)'═ %d'      # %U
  test -n "$FISH_GIT_INFO_UNTRACKED"; or set -g FISH_GIT_INFO_UNTRACKED (set_color white)'◼ %d'     # %u
  test -n "$FISH_GIT_INFO_INDEXED";   or set -g FISH_GIT_INFO_INDEXED   (set_color brblue)'◆ %d'    # %i
  test -n "$FISH_GIT_INFO_UNINDEXED"; or set -g FISH_GIT_INFO_UNINDEXED (set_color brblue)'◇ %d'    # %I
  test -n "$FISH_GIT_INFO_DIRTY";     or set -g FISH_GIT_INFO_DIRTY     (set_color brred)'✖ '       # %D
  test -n "$FISH_GIT_INFO_CLEAN";     or set -g FISH_GIT_INFO_CLEAN     (set_color -o brgreen)'✔ '  # %C
end

function __git_info -d 'Parse the output and print infos from `git status`'

  __check_settings

  # simulates pseudo-`dict` feature in fish
  function set_field --argument-names key value
    set -g '__git_fish__'$key $value
  end

  function get_field --argument-names key
    eval echo \$'__git_fish__'$key $value
  end

  function __action
    set git_dir $argv[1]

    for dir in "$git_dir/rebase-apply" "$git_dir/rebase" "$git_dir/../.dotest"
      if test -d "$dir"
        set -q FISH_GIT_INFO_ACTION_REBASE; or set -g FISH_GIT_INFO_ACTION_REBASE rebase
        set -q FISH_GIT_INFO_ACTION_APPLY; or set -g FISH_GIT_INFO_ACTION_APPLY apply
        if test -f "$dir/rebasing"
          echo -n $FISH_GIT_INFO_ACTION_REBASE
        else if test -f "$dir/applying"
          echo -n $FISH_GIT_INFO_ACTION_APPLY
        else
          echo -n $FISH_GIT_INFO_ACTION_REBASE/$FISH_GIT_INFO_ACTION_APPLY
        end
        return 0
      end
    end

    for file in "$git_dir/rebase-merge/interactive" "$git_dir/.dotest-merge/interactive"
      if test -f "$file"
        set -q FISH_GIT_INFO_ACTION_REBASE_INTERACTIVE; or set -g FISH_GIT_INFO_ACTION_REBASE_INTERACTIVE rebase-interactive
        echo -n $FISH_GIT_INFO_ACTION_REBASE_INTERACTIVE
        return 0
      end
    end

    for dir in "$git_dir/rebase-merge" "$git_dir/.dotest-merge"
      if test -d "$dir"
        set -q FISH_GIT_INFO_ACTION_REBASE_MERGE; or set -g FISH_GIT_INFO_ACTION_REBASE_MERGE rebase-merge
        echo -n $FISH_GIT_INFO_ACTION_REBASE_MERGE
        return 0
      end
    end

    if test -f "$dir/MERGE_HEAD"
      set -q FISH_GIT_INFO_ACTION_MERGE; or set -g FISH_GIT_INFO_ACTION_MERGE merge
      echo -n $FISH_GIT_INFO_ACTION_MERGE
      return 0
    end

    if test -f "$dir/CHERRY_PICK_HEAD"
      if test -d "$dir/sequencer"
        set -q FISH_GIT_INFO_ACTION_CHERRY_PICK_SEQUENCE; or set -g FISH_GIT_INFO_ACTION_CHERRY_PICK_SEQUENCE cherry-pick
        echo -n $FISH_GIT_INFO_ACTION_CHERRY_PICK_SEQUENCE
      else
        set -q FISH_GIT_INFO_ACTION_CHERRY_PICK; or set -g FISH_GIT_INFO_ACTION_CHERRY_PICK cherry-pick
        echo -n $FISH_GIT_INFO_ACTION_CHERRY_PICK
      end
      return 0
    end

    if test -f "$dir/REVERT_HEAD"
      if test -d "$dir/sequencer"
        set -q FISH_GIT_INFO_ACTION_REVERT_SEQUENCE; or set -g FISH_GIT_INFO_ACTION_REVERT_SEQUENCE revert
        echo -n $FISH_GIT_INFO_ACTION_REVERT_SEQUENCE
      else
        set -q FISH_GIT_INFO_ACTION_REVERT; or set -g FISH_GIT_INFO_ACTION_REVERT revert
        echo -n $FISH_GIT_INFO_ACTION_REVERT
      end
      return 0
    end

    if test -f "$dir/BISECT_LOG"
      set -q FISH_GIT_INFO_ACTION_BISECT; or set -g FISH_GIT_INFO_ACTION_BISECT bisect
      echo -n $FISH_GIT_INFO_ACTION_BISECT
      return 0
    end
  end

  function __set_verbose_status
    set dirty 0
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
        set dirty (math $dirty + 1)
      end

      # added -- %a
      # deleted -- %d
      # modified -- %m
      # renamed -- %r
      # unmerged -- %U
      # untracked -- %u
      test -n "$FISH_GIT_INFO_ADDED"; and test $added -ne 0; and set_field a (printf "$FISH_GIT_INFO_ADDED" $added)
      test -n "$FISH_GIT_INFO_DELETED"; and test $deleted -ne 0; and set_field d (printf "$FISH_GIT_INFO_DELETED" $deleted)
      test -n "$FISH_GIT_INFO_MODIFIED"; and test $modified -ne 0; and set_field m (printf "$FISH_GIT_INFO_MODIFIED" $modified)
      test -n "$FISH_GIT_INFO_RENAMED"; and test $renamed -ne 0; and set_field r (printf "$FISH_GIT_INFO_RENAMED" $renamed)
      test -n "$FISH_GIT_INFO_UNMERGED"; and test $unmerged -ne 0; and set_field U (printf "$FISH_GIT_INFO_UNMERGED" $unmerged)
      test -n "$FISH_GIT_INFO_UNTRACKED"; and test $untracked -ne 0; and set_field u (printf "$FISH_GIT_INFO_UNTRACKED" $untracked)
    end

    echo -n $dirty
  end

  function __set_simple_status
    # indexed -- %i
    set indexed 0
    if test -n "$FISH_GIT_INFO_INDEXED"
      set indexed (command git diff-index \
        --no-ext-diff \
        --name-only \
        --cached \
        HEAD \
        2> /dev/null \
      | wc -l)
      if test $indexed -ne 0
        set_field i (printf "$FISH_GIT_INFO_INDEXED" $indexed)
      end
    end

    # unindexed -- %I
    set unindexed 0
    if test -n "$FISH_GIT_INFO_UNINDEXED"
      set unindexed (command git diff-files \
        --no-ext-diff \
        --name-only \
        2> /dev/null \
      | wc -l)
      if test $unindexed -ne 0
        set_field I (printf "$FISH_GIT_INFO_UNINDEXED" $unindexed)
      end
    end

    # untracked -- %u
    set untracked 0
    if test -n "$FISH_GIT_INFO_UNTRACKED"
      set untracked (command git ls-files \
        --other \
        --exclude-standard \
        2> /dev/null \
      | wc -l)
      if test $untracked -ne 0
        set_field u (printf "$FISH_GIT_INFO_UNTRACKED" $untracked)
      end
    end

    echo -n (math $indexed + $unindexed + $untracked)
  end

  if test -n "$FISH_GIT_INFO"
    set -l git_dir (git rev-parse --git-dir 2> /dev/null)
    if test -n "$git_dir"

      # branch -- %b
      if test -n "$FISH_GIT_INFO_BRANCH"
        set branch (command git symbolic-ref HEAD 2> /dev/null | perl -pe 's,^refs/heads/,,')
        if test -n "$branch"
          set_field b (printf "$FISH_GIT_INFO_BRANCH" "$branch")
        end
      end

      # position -- %p
      if test -n "$FISH_GIT_INFO_POSITION"
        set position (command git describe --contains --all HEAD 2> /dev/null | perl -pe 's,^remotes/origin/,,')
        if test -n "$position"
          if test -n "$branch"; and test "$branch" != "$position"
            set_field p (printf "$FISH_GIT_INFO_POSITION" "$position")
          else if test -z "$branch"
            set_field p (printf "$FISH_GIT_INFO_POSITION" "$position")
          end
        end
      end

      # commit -- %c
      if test -n "$FISH_GIT_INFO_COMMIT"
        set commit (command git rev-parse HEAD 2> /dev/null | cut -c-7)
        if test -n "$commit"
          set_field c (printf "$FISH_GIT_INFO_COMMIT" "$commit")
        end
      end

      # action -- %s
      if test -n "$FISH_GIT_INFO_ACTION"
        set action (__action "$git_dir")
        if test -n "$action"
          set_field s (printf "$FISH_GIT_INFO_ACTION" "$action")
        end
      end

      # ahead -- %A
      # behind -- %B
      if test -n "$branch"; and test -n "$FISH_GIT_INFO_AHEAD" || test -n "$FISH_GIT_INFO_BEHIND"
        set -l ahead_and_behind_string (command git rev-list --count --left-right 'HEAD...@{upstream}' 2> /dev/null)
        if test -n "$ahead_and_behind_string"
          set ahead_and_behind (string match -ar '\d+' "$ahead_and_behind_string")
          if test -n "$FISH_GIT_INFO_AHEAD"; and test $ahead_and_behind[1] -ne 0
            set_field A (printf "$FISH_GIT_INFO_AHEAD" $ahead_and_behind[1])
          end
          if test -n "$FISH_GIT_INFO_BEHIND"; and test $ahead_and_behind[2] -ne 0
            set_field B (printf "$FISH_GIT_INFO_BEHIND" $ahead_and_behind[2])
          end
        end
      end

      # stashed -- %S
      if test -n "$FISH_GIT_INFO_STASHED"
        set commondir ''
        if test -f "$git_dir/commondir"
          set commondir (cat "$git_dir/commondir")
          if string match -vr '^/' -- "$commondir"
            set commondir "$git_dir/$commondir"
          end
        end
        if test -f "$git_dir/refs/stash"; or test -n "$commondir"; and test -f "$commondir/refs/stash"
          set stashed (command git stash list 2> /dev/null | wc -l | awk '{print $1}')
          set_field S (printf "$FISH_GIT_INFO_STASHED" $stashed)
        end
      end

      # dirty -- %D
      # clean -- %C
      if test -n "$FISH_GIT_INFO_VERBOSE"
        set dirty (__set_verbose_status)
      else
        set dirty (__set_simple_status)
      end
      if test $dirty -ne 0
        if test -n "$FISH_GIT_INFO_DIRTY"
          set_field D (printf "$FISH_GIT_INFO_DIRTY" $dirty)
        end
      else if test -n "$FISH_GIT_INFO_CLEAN"
        set_field C (printf "$FISH_GIT_INFO_CLEAN")
      end

      # print results
      for key in (string match -ar %. "$FISH_GIT_INFO")
        set i (string replace % '' $key)
        set -a results (get_field $i)(set_color normal)
      end
      set format (string replace -ar %. %s "$FISH_GIT_INFO")
      printf "$format" $results
    end
  end
end

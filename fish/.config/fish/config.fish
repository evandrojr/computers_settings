rvm default
git_load_aliases_and_functions
lazy_aliases

# BEGIN ############## from http://www.martinklepsch.org/posts/git-prompt-for-fish-shell.html
  set normal (set_color normal)
  set magenta (set_color magenta)
  set yellow (set_color yellow)
  set green (set_color green)
  set red (set_color red)
  set gray (set_color -o black)

  # Fish git prompt
  set __fish_git_prompt_showdirtystate 'yes'
  set __fish_git_prompt_showstashstate 'yes'
  set __fish_git_prompt_showuntrackedfiles 'yes'
  set __fish_git_prompt_showupstream 'yes'
  set __fish_git_prompt_color_branch yellow
  set __fish_git_prompt_color_upstream_ahead green
  set __fish_git_prompt_color_upstream_behind red

  # Status Chars
  set __fish_git_prompt_char_dirtystate '⚡'
  set __fish_git_prompt_char_stagedstate '→'
  set __fish_git_prompt_char_untrackedfiles '☡'
  set __fish_git_prompt_char_stashstate '↩'
  set __fish_git_prompt_char_upstream_ahead '+'
  set __fish_git_prompt_char_upstream_behind '-'


  function fish_prompt
    set last_status $status

    set_color $fish_color_cwd
#    printf '%s' (prompt_pwd)
     printf '%s' (pwd)

    set_color normal

    printf '%s\n-> ' (__fish_git_prompt)

    set_color normal
  end

# END ############## from http://www.martinklepsch.org/posts/git-prompt-for-fish-shell.html

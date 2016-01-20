function lazy_aliases
  ## Git specifics
  # alias a="ag '(#DONT_COMMIT)|(binding.pry)' ; and git add"
  alias a="remove_breakpoints.rb ; and git add "
  alias b='git branch'
  alias ba='git branch -a'
  alias bi='bundle install --jobs=8 --retry=3'
  alias c="remove_breakpoints.rb ; and git commit"
  alias d='git diff'
  alias f='git fetch'
  alias gf='git fetch'
  alias k='git checkout'
  alias kp='git checkout production'
  alias km='git checkout master'
  alias ks='git checkout staging'
  alias l='git log'
  alias m='git merge'
  alias pl='git pull'
  alias ph='git push'
  alias prs='git pull --recurse-submodules'
  alias r='git reset'
  alias s='git status'
  alias gs='git stash'

  ## Editors
  alias v='vim'
  alias t='atom .'

  ## Ruby specifics
  alias rg='rm -f Gemfile.lock'
  alias gem_install='gem install --no-rdoc --no-ri '

  ## Rails specifics
  alias rs='rails s'
  alias rc='rails c'
  alias rdm='rails db:migrate'
  alias x='rake db:migrate; and script/development'
  alias z='rake db:migrate; and rails s'
  alias rt='ruby -I.:lib:test'

  ## Super nice!
  alias add_database_yml='cp ~/bin/noosfero/config/database.yml ./config/'
  alias add_gemfile_for_debbuging='cp ~/bin/noosfero/config/Gemfile ./config/'
  alias add_travis='cp ~/bin/noosfero/.travis.yml ./'

  alias relax_db_reset='add_database_yml; and rm -f Gemfile.lock; bi; and rake db:drop; and rake db:create; and rake db:schema:load; and rake db:migrate'
  alias relax_test='add_database_yml; and rm -f Gemfile.lock; bi; and rake db:migrate; and rake test'
  alias relax_full='add_database_yml; and rm -f Gemfile.lock; bi ;bundle exec spring binstub --all; rake db:drop; and rake db:create; and rake db:schema:load; and rake db:migrate; and rake test'
  alias spring='bi; bundle exec spring binstub --all'

  ## Noosfero specifics
  alias n='cd ~/p/softwarepublico-noosferogov; t'
  
  function pd  --description 'Disable a noosfero plugin'
    command  ./script/noosfero-plugins disable $argv
  end

  function pe --description 'Enable a noosfero plugin'
    command  ./script/noosfero-plugins disable $argv
    command  ./script/noosfero-plugins enable $argv
  end

  ## Swap /etc/hosts
  alias tp='sudo cp /etc/hosts_prod /etc/hosts'
  alias td='sudo cp /etc/hosts_dev /etc/hosts'

  # Really lazy aliases
  alias cs='cd ~/p/computers_settings; and t'

  # # # function rtm(){ ruby -I.:lib:test $1 -n 'test_should_$2' ; }

end

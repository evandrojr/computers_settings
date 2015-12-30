function lazy_aliases
  ## Git specifics
  # alias a="ag '(#DONT_COMMIT)|(binding.pry)' ; and git add"
  alias a="remove_breakpoints.rb ; and git add "
  alias b='git branch'
  alias ba='git branch -a'
  alias bi='bundle install'
  alias c="remove_breakpoints.rb ; and git commit"
  alias d='git diff'
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

  ## Ruby specifics
  alias rg='rm Gemfile.lock'

  ## Rails specifics
  alias rs='rails s'
  alias rc='rails c'
  alias rdm='rails db:migrate'
  alias x='rake db:migrate ; and script/development'
  alias z='rake db:migrate ; and rails s'
  alias rt='ruby -I.:lib:test'
  alias rt='ruby -I.:lib:test'

  ## Super nice!
  alias relax='add_database_yml; and rm -f Gemfile.lock; and bundle; and rake db:migrate; and rake test'
  alias full_relax='add_database_yml; and rm -f Gemfile.lock; and bundle; and rake db:drop; and rake db:create; and rake db:schema:load; and rake db:migrate; and rake test'
  alias add_database_yml='cp ~/bin/rails/config/database.yml ./config/'
  alias add_gemfile_for_debbuging='cp ~/bin/rails/config/database.yml ./config/'
  alias add_travis='cp ~/bin/rails/.travis.yml ./'

  ## Editors
  alias v='vim'
  alias t='atom .'

  ## Noosfero specifics
  alias n='cd ~/p/noosfero'



  ## Swap /etc/hosts
  alias tp='sudo cp /etc/hosts_prod /etc/hosts'
  alias td='sudo cp /etc/hosts_dev /etc/hosts'

  # # # function rtm(){ ruby -I.:lib:test $1 -n 'test_should_$2' ; }
end

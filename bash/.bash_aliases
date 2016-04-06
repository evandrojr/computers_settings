## Git specifics
# alias a="ag '(#DONT_COMMIT)|(binding.pry)' && git add"

alias f="fish"
alias a="remove_breakpoints.rb && git add"
alias b='git branch'
alias bi='bundle install'
alias c="ag '(#DONT_COMMIT)|(binding.pry)' && git commit"
alias d='git diff'
alias gf='git fetch'
alias k='git checkout'
alias kp='git checkout production'
alias km='git checkout master'
alias ks='git checkout staging'
alias l='git log'
alias gl='git log'
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
alias rc='rails c'
alias rdm='rails db:migrate'
alias x='rake db:migrate && script/development'
alias z='zsh'
alias v='vim'
alias rt='ruby -I.:lib:test'

alias tp='sudo cp /etc/hosts_prod /etc/hosts'
alias td='sudo cp /etc/hosts_dev /etc/hosts'
alias rt='ruby -I.:lib:test'
alias rs='rails s'

alias t='atom .'

## Noosfero specifics
alias n='cd ~/p/noosfero'
# # # function rtm(){ ruby -I.:lib:test $1 -n 'test_should_$2' ; }

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="robbyrussell"

# bira and abden are nice
ZSH_THEME="random"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git history-substring-search)

# User configuration

  export PATH="$HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


################### Begin Lazy Aliases ########################################


  ## Git specifics
  # alias a="ag '(#DONT_COMMIT)|(binding.pry)' && git add"
  alias a="remove_breakpoints.rb && git add "
  alias b='git branch'
  alias ba='git branch -a'
  alias bi='bundle install --jobs=8 --retry=3'
  alias c="remove_breakpoints.rb  && git commit"
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
  alias x='rake db:migrate && script/development'
  alias z='rake db:migrate && rails s'
  alias rt='ruby -I.:lib:test'

  ## Super nice!
  alias add_database_yml='cp ~/bin/noosfero/config/database.yml ./config/'
  alias add_gemfile_for_debbuging='cp ~/bin/noosfero/config/Gemfile ./config/'
  alias add_travis='cp ~/bin/noosfero/.travis.yml ./'
  alias db_setup='rake db:create && rake db:schema:load && rake db:migrate'
  alias relax_db_reset='add_database_yml && rg; bi && rake db:drop && db_setup && rake db:data:minimal && add_noosfero_administrator.rb'
  alias relax_db_setup='add_database_yml && db_setup && rake db:data:minimal && add_noosfero_administrator.rb'
  alias relax_test='add_database_yml && rm -f Gemfile.lock; bi && rake db:migrate && rake test'
  alias relax='add_database_yml && rm -f Gemfile.lock; bi && bundle exec spring binstub --all; rake db:drop && db_setup && add_noosfero_administrator.rb'
  alias relax_full='add_database_yml && rm -f Gemfile.lock; bi && bundle exec spring binstub --all; rake db:drop && db_setup && rake test'
  alias spring='bi; bundle exec spring binstub --all'

  ## Noosfero specifics
  alias n='cd ~/_/softwarepublico-noosferogov; t'

  function pd {
    command  ./script/noosfero-plugins disable $argv
  }

  function pe {
    command  ./script/noosfero-plugins disable $argv
    command  ./script/noosfero-plugins enable $argv
  }

  ## Swap /etc/hosts
  alias tp='sudo cp /etc/hosts_prod /etc/hosts'
  alias td='sudo cp /etc/hosts_dev /etc/hosts'

  # Really lazy aliases
  alias cs='cd ~/_/computers_settings && t'
  alias lb='cd ~/_/layback && t'

################### END Lazy Aliases ########################################


export NVM_DIR="/home/j/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

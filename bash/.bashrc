#Prompt do maluco
export PS1='\[\033[38m\]\u@\[\033[1;33m\]\h\[\033[32m\]\w\[\033[1;33m\]\[\033[0;31m\]`git branch 2> /dev/null | grep -e ^* | sed -E s/^\\\\\*\ \(.+\)$/\(\\\\\1\)\ /`\[\033[37m\]\[\033[00m\]\n -> '
source $HOME/.bash_aliases
echo export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"

export NVM_DIR="/home/93274300500/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

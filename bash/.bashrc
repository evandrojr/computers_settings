#PRompt do maluco
export PS1='\[\033[38m\]\u@\[\033[1;33m\]\h\[\033[32m\]\w\[\033[1;33m\]\[\033[0;31m\]`git branch 2> /dev/null | grep -e ^* | sed -E s/^\\\\\*\ \(.+\)$/\(\\\\\1\)\ /`\[\033[37m\]\[\033[00m\]\n -> '

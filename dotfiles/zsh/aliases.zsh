## エイリアス
# ls
alias ll='lsd -al --group-directories-first'
alias l='lsd -a1 --group-directories-first'

# editor
alias vim='nvim'
alias vi='nvim'

# GitHub
# リポジトリページをブラウザで開くエイリアス
alias gb='xdg-open $(git config --get remote.origin.url | sed -e "s|git@github.com:|https://github.com/|" -e "s|\.git$||")'
alias ghcc='gh-create-and-cd'

# tools
alias lg='lazygit'
alias fk='fzf-kill'

## git
function glgd() {
	git cherry -v --abbrev $1 | grep + | grep -v maven-release-plugin
}
function _glgd() {
	for ref in $(git show-ref --heads --tags | cut -d/ -f3-); do 
		compadd $ref
	done
}
compdef _glgd glgd

# alias co="git-branches | dmenu -l 10 | xargs -I {} git checkout {}"
alias co='git checkout $(git for-each-ref refs/heads/ --format="%(refname:short)" | fzf)'

alias git-current-branch="git branch | grep \* | cut -d ' ' -f2"
alias git-branches="git branch --sort=-committerdate | tr -d ' ' | tr -d '*' | tr -d '+'"
alias git-upstream-branch="git rev-parse --abbrev-ref --symbolic-full-name @{u} | cut -d '/' -f2"
alias git-upstream-branches="git branch -r | grep upstream | grep -v HEAD | cut -d '/' -f2"

alias gb="git branch --sort=-committerdate"

# 列出git stash列表，让用户选择并应用stash
function gstpick() {
  # 列出git stash列表并使用fzf选择一个stash
  selected_stash=$(git stash list | sed 's/:/ /' | fzf --preview "git stash show -p {}")

  # 检查是否有选择
  if [ -n "$selected_stash" ]; then
    # 应用所选的stash
    git stash apply "$(echo "$selected_stash" | awk '{print $1}')"
    echo "已应用stash: $selected_stash"
  else
    echo "未选择stash，退出"
  fi
}

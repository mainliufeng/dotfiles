if [ -f ~/dotfiles/git/.gitconfig ]; then
  cp ~/dotfiles/git/.gitconfig ~/.gitconfig
else
  echo "skip: ~/dotfiles/git/.gitconfig not found"
fi
ln -svfn ~/dotfiles/git/.gitignore_global ~/.gitignore_global

# 如需针对特定仓库使用不同配置，可在 ~/.gitconfig 中追加类似：
# [includeIf "gitdir:~/Code/rcrai/"]
#     path = ~/.rcrai.gitconfig

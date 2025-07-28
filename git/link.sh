cp ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -svfn ~/dotfiles/git/.gitignore_global ~/.gitignore_global

# ~/.gitconfig增加：
# [includeIf "gitdir:/mnt/d/Code/rcrai/"]
#     path = ~/.rcrai.gitconfig


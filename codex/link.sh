mkdir -p ~/.codex
ln -svfn ~/dotfiles/codex/config.toml ~/.codex/config.toml
ln -svfn ~/dotfiles/codex/prompts ~/.codex/prompts

superpowers_dir="$HOME/.codex/superpowers"
if [ -d "$superpowers_dir" ]; then
  if [ ! -d "$superpowers_dir/.git" ]; then
    rm -rf "$superpowers_dir"
    git clone https://github.com/obra/superpowers.git "$superpowers_dir"
  else
    git -C "$superpowers_dir" pull
  fi
else
  git clone https://github.com/obra/superpowers.git "$superpowers_dir"
fi

bash ~/dotfiles/codex/agents_md/install.sh
node ~/dotfiles/codex/agents_md/agents-md.js enable base superpowers

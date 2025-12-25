mkdir -p ~/.codex
ln -svfn ~/dotfiles/codex/config.toml ~/.codex/config.toml
ln -svfn ~/dotfiles/codex/prompts ~/.codex/prompts
mkdir -p ~/.codex/skills
rsync -a ~/dotfiles/codex/skills/ ~/.codex/skills/

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

python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo anthropics/skills \
  --path skills/webapp-testing

python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo anthropics/skills \
  --path skills/frontend-design

python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo michalparkola/tapestry-skills-for-claude-code \
  --path tapestry

python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --url https://github.com/ComposioHQ/awesome-claude-skills/tree/master/content-research-writer

source $HOME/dotfiles/app/env.sh

for config_sh in ~/dotfiles/dotfiles/*/*.*sh; do
    source $config_sh
done

#!/bin/sh

for link_sh in ~/dotfiles/dotfiles/*/*.symlink; do
    source $link_sh
done

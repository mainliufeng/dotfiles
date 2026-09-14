#!/usr/bin/env bash
set -euo pipefail

# CLI tooling for downloading Baidu Netdisk (百度网盘) and Quark (夸克网盘)
# shares on Arch Linux.
#
#   baidupcs-go  Baidu Netdisk client: log in with cookies, transfer a share
#                into your own drive, then download it (resumable, multi-thread).
#   aria2        optional accelerator for the CDN direct links the two
#                downloaders hand out.
#
# Quark share downloads themselves are handled by ../bin/quark-dl (no package
# needed beyond curl + python). `kuake-cli` (AUR) is a nice interactive Quark
# CLI if you want one: yay -S kuake-cli

yay -S --needed --noconfirm baidupcs-go aria2

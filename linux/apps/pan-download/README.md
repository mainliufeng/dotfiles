# pan-download

Download 百度网盘 (Baidu Netdisk) and 夸克网盘 (Quark) **share links** to local
disk from the CLI, using the session of the agent browser instead of a manual
cookie copy-paste.

## Install

```bash
# packages (Arch): BaiduPCS-Go + aria2
~/dotfiles/linux/setup.sh --platform-only

# or directly
yay -S --needed baidupcs-go aria2

# put the helpers on PATH (~/.local/bin)
~/dotfiles/link.sh --platform-only
```

The module is registered in `modules/linux.txt`, so the normal
`~/dotfiles/setup.sh` / `~/dotfiles/link.sh` runs include it.

## Helpers

| command | what it does |
| --- | --- |
| `chrome-cookies <domain>` | print the Cookie header for a domain from the agent Chrome (CDP :9222); works while the browser is running and includes HttpOnly cookies |
| `quark-dl <share-url> [passcode]` | download a Quark share straight to disk, no 转存 needed |
| `baidu-login` | log `BaiduPCS-Go` in with the cookies of `pan.baidu.com` from the agent browser |

Start the agent browser first:

```bash
chrome-agent                      # CDP on :9222, dedicated profile
```

## Quark

Quark caps web-UI downloads of *shared* files at ~50 MiB per file for free
accounts (API error `23018 download file size limit`). The desktop-client
User-Agent lifts that cap, so `quark-dl` sends it for both the API and the CDN
request. No 转存 is involved, so it works even when your own drive is full.

```bash
# just list the share
quark-dl --list 'https://pan.quark.cn/s/42889c48a2f1'

# download everything (3 files at a time) to ~/Downloads/pan/quark
quark-dl -j 3 -o ~/Downloads/pan/quark 'https://pan.quark.cn/s/42889c48a2f1'

# only some paths
quark-dl -o ~/Downloads/pan/quark --only '.zip' 'https://pan.quark.cn/s/42889c48a2f1'
```

Notes:

- Completed files are skipped on re-run (size check), partial files resume.
- Free-account throughput is throttled (~0.2–0.9 MB/s); raise `-j` to get more
  out of it. A Quark membership removes the throttle.
- Cookie source order: `--cookie` / `--cookie-file`, `$KUAKE_COOKIE`, then
  `chrome-cookies pan.quark.cn`.

## Baidu

Baidu needs a logged-in account: guest downloads hit a captcha and then demand
the desktop client. Log in at <https://pan.baidu.com> in the **agent browser**,
then:

```bash
baidu-login
BaiduPCS-Go transfer 'https://pan.baidu.com/s/XXXX' pwd     # 转存 into your drive
BaiduPCS-Go download '/转存目录' --saveto ~/Downloads/pan/baidu
```

Set a default download directory and thread count:

```bash
BaiduPCS-Go config set -savedir ~/Downloads/pan/baidu
BaiduPCS-Go config set -max_parallel 4
```

Free Baidu accounts are throttled hard; the transfer step also needs enough
free space in your drive (and 会员 for large archives).

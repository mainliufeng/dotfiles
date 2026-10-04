# Pi through Magpie

Pi uses Magpie as its only model provider. Magpie owns the gateway URL, key and
model catalog in `~/.pi/agent/models.json`; this repository never stores those
machine-specific credentials.

Run `bash ~/dotfiles/pi/setup.sh` to install Pi and its local resources. Configure
providers and keys in Magpie, then configure Pi's startup routing group:

```bash
magpie group set auto-deepseek-flash \
  models=opencode-go/deepseek-flash,deepseek/deepseek-flash \
  routing=order stays=off
magpie pi group/auto-deepseek-flash
```

This tries OpenCode Go first and uses the DeepSeek API when that route cannot
answer, including quota exhaustion. `stays=off` checks the configured order on
every request, so a previous fallback does not keep future requests on DeepSeek
after OpenCode Go becomes available again. These group settings live in Magpie;
Pi's default model is `group/auto-deepseek-flash` on the `magpie` provider.

OpenCode Go's DeepSeek models require **Global** regions in the workspace's
**Privacy** settings. With a different region setting, OpenCode returns HTTP 400
(`This Go model requires Global regions`); Magpie classifies that as a configuration
error and stops without trying the next member. Set the region before using this
group. Quota exhaustion and availability failures use the ordered fallback.
For an existing Pi conversation, select `magpie/group/auto-deepseek-flash` in
`/model`; changing the startup default does not replace a restored session model.

The default provider is `magpie`, and `/model` and Ctrl+P use `magpie/**`.
The `magpie-only.ts` extension also empties Pi's built-in provider catalogs, so
switching the picker to **all** does not expose direct Vercel, Anthropic, DeepSeek
or other routes merely because the shell has their API keys. Tools still inherit
those environment variables.

Setup removes obsolete direct providers from Pi's model configuration while
preserving Magpie's existing gateway key and catalog. It also preserves unrelated
settings such as packages and themes. On a fresh machine, configure Magpie before
starting a model conversation.

After installing the extension into an already-running Pi, restart Pi to refresh
its model scope. Magpie can continue updating its own catalog normally.

Skills are installed separately by `~/dotfiles-private/pi/install-skills.py`.

# Pi through Magpie

Pi uses Magpie as its only model provider. Magpie owns the gateway URL, key and
model catalog in `~/.pi/agent/models.json`; this repository never stores those
machine-specific credentials.

Run `bash ~/dotfiles/pi/setup.sh` to install Pi and its local resources. Configure
providers and keys in Magpie, then select Pi's startup model there, for example:

```bash
magpie pi deepseek/deepseek-flash
```

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

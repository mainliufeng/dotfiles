# agent-skill-manager (Hermes / Pi)

This legacy manager installs and audits Hermes/Pi skills from the public and private TSV registries. `all` means Hermes and Pi only. Their existing source directories and installation behavior remain unchanged.

```bash
./setup.sh --target hermes
./bin/skill-manager sync --target pi --dry-run
./bin/skill-manager audit --target all
```

Codex is not supported here: its implementation, registry column, document catalogs and forwarding adapter have been removed. Run `python3 ~/dotfiles-private/codex/install-skills.py` directly. There is no fallback or forwarding through this manager.

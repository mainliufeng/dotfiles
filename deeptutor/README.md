# DeepTutor

Installs the pinned PyPI release with `uv tool` and configures the local Web app
to use `deepseek-v4-flash` through Aliyun DashScope's OpenAI-compatible endpoint.

The API key remains sourced from
`~/dotfiles-private/llm/env.sh` (`DASHSCOPE_API_KEY`). During setup DeepTutor's
required runtime catalog is generated at
`~/.local/share/deeptutor/data/user/settings/model_catalog.json` with mode `600`;
no secret is stored in this repository.

Run:

```bash
~/dotfiles/deeptutor/setup.sh
~/dotfiles/deeptutor/link.sh
deeptutor-local
```

Then open <http://127.0.0.1:3782>. Embeddings and Web search are intentionally
left unconfigured; add them later from Settings if Knowledge Base indexing or
live Web research is needed.

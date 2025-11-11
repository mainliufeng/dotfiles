### Playwright 缓存位置（保持不变）
export PLAYWRIGHT_BROWSERS_PATH="$HOME/.cache/ms-playwright"

### 优先检测 nvm / fnm（用它们管理 Node 时，不要改 npm 前缀）
if command -v nvm >/dev/null 2>&1 || [ -n "$NVM_DIR" ]; then
  # nvm 自己会处理 PATH
  : # no-op
elif command -v fnm >/dev/null 2>&1; then
  # fnm 也会自动处理 PATH（如果没处理，你可以启用 eval "$(fnm env)"
  : # no-op
else
  ### 无 nvm/fnm：使用用户目录作为 npm 全局安装前缀
  export NPM_GLOBAL_HOME="$HOME/.npm-global"
  # 确保目录存在
  [ -d "$NPM_GLOBAL_HOME" ] || mkdir -p "$NPM_GLOBAL_HOME"

  # 如果当前 npm 的全局前缀不是 $HOME 下的目录，则设置为 ~/.npm-global
  if command -v npm >/dev/null 2>&1; then
    current_prefix="$(npm config get prefix 2>/dev/null)"
    case "$current_prefix" in
      "$HOME"/*) : ;;  # 已经是用户目录，无需修改
      *)
        # 设置前缀到 ~/.npm-global（幂等；重复执行也没问题）
        npm config set prefix "$NPM_GLOBAL_HOME" >/dev/null 2>&1
        ;;
    esac
  fi

  # 把 ~/.npm-global/bin 加入 PATH（放前面保证 npx 优先用用户全局包）
  case ":$PATH:" in
    *":$NPM_GLOBAL_HOME/bin:"*) : ;;
    *) export PATH="$NPM_GLOBAL_HOME/bin:$PATH" ;;
  esac
fi

### 统一计算并导出 NODE_PATH，让 require 能找到全局模块
if command -v npm >/dev/null 2>&1; then
  NODE_GLOBAL_ROOT="$(npm root -g 2>/dev/null)"
  if [ -n "$NODE_GLOBAL_ROOT" ]; then
    case ":$NODE_PATH:" in
      *":$NODE_GLOBAL_ROOT:"*) : ;;
      *)
        if [ -n "$NODE_PATH" ]; then
          export NODE_PATH="$NODE_GLOBAL_ROOT:$NODE_PATH"
        else
          export NODE_PATH="$NODE_GLOBAL_ROOT"
        fi
        ;;
    esac
  fi
fi


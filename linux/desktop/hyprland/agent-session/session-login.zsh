# SDDM executes wayland-session through the user's login zsh.
# Scope the fork PATH to the existing Hyprland login entry only.
# zsh has not populated the script's $0/$1 while reading .zprofile.
# Inspect this process's original argv instead of terminal/session env flags.
if /usr/bin/python3 -c 'import pathlib,sys; a=pathlib.Path("/proc/"+sys.argv[1]+"/cmdline").read_bytes().split(b"\0"); sys.exit(not (b"/usr/bin/start-hyprland" in a and any(x.endswith(b"/wayland-session") for x in a)))' "$$"; then
  export PATH="$HOME/dotfiles/linux/desktop/hyprland/agent-session:$PATH"
fi

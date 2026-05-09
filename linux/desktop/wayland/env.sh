if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
    export MOZ_ENABLE_WAYLAND=1
    export GDK_BACKEND=wayland

    # Hyprland already applies output scaling via monitor scale (e.g. 2x).
    # Setting GDK_SCALE=2 here would cause many GTK apps to be scaled twice.
    if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || case "${XDG_CURRENT_DESKTOP:-}" in *Hyprland*|*hyprland*) true;; *) false;; esac; then
        export GDK_SCALE=1
        export GDK_DPI_SCALE=1
    else
        : "${GDK_SCALE:=2}"
        export GDK_SCALE
    fi
fi

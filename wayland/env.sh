if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    export MOZ_ENABLE_WAYLAND=1
    export GDK_BACKEND=wayland
    export GDK_SCALE=2
fi

sudo pacman -S --needed rustup base-devel
rustup default stable
rustup component add rustfmt clippy

sudo pacman -S --needed gtk3 webkit2gtk libsoup libayatana-appindicator librsvg
cargo install tauri-cli

#!/bin/bash

# Install Zellij
if command -v zellij &> /dev/null; then
    echo "Zellij is already installed"
    zellij --version
else
    echo "Installing Zellij..."

    # Try installing via package manager first
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm zellij
    elif command -v apt &> /dev/null; then
        # For Debian/Ubuntu, install from cargo or download binary
        if command -v cargo &> /dev/null; then
            cargo install --locked zellij
        else
            echo "Installing via download..."
            ZELLIJ_VERSION=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
            curl -L "https://github.com/zellij-org/zellij/releases/download/${ZELLIJ_VERSION}/zellij-x86_64-unknown-linux-musl.tar.gz" -o /tmp/zellij.tar.gz
            tar -xzf /tmp/zellij.tar.gz -C /tmp
            sudo mv /tmp/zellij /usr/local/bin/
            rm /tmp/zellij.tar.gz
        fi
    else
        echo "Unable to determine package manager. Please install Zellij manually."
        exit 1
    fi
fi

echo "Zellij installation complete!"

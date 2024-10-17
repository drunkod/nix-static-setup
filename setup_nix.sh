#!/bin/bash

# Define variables
NIX_VERSION="2.18"
NIX_STATIC_URL="https://hydra.nixos.org/job/nix/maintenance-${NIX_VERSION}/buildStatic.x86_64-linux/latest/download-by-type/file/binary-dist"
NIX_ROOT="$HOME/mynixroot"
NIX_CONF_DIR="$HOME/.config/nix"
NIX_CONF_FILE="$NIX_CONF_DIR/nix.conf"
SSL_CERT_FILE="/etc/pki/tls/cert.pem"

# Create the configuration directory if it doesn't exist
mkdir -p "$NIX_CONF_DIR"

# Download the static version of Nix
echo "Downloading static version of Nix..."
curl -L "$NIX_STATIC_URL" -o "$HOME/nixstatic"

# Make the downloaded file executable
chmod +x "$HOME/nixstatic"

# Configure Nix
echo "Configuring Nix..."
cat <<EOL > "$NIX_CONF_FILE"
store = $NIX_ROOT
extra-experimental-features = flakes nix-command
ssl-cert-file = $SSL_CERT_FILE
EOL

# Inform the user about the next steps
echo "Nix has been configured."
echo "You can now run programs using the following command:"
echo "~/nixstatic run nixpkgs#hello"
echo "To enter a Nix shell, use:"
echo "~/nixstatic shell nixpkgs#nix nixpkgs#bashInteractive --command bash"
echo "You can now use commands like 'nix profile install'."
echo "Note: You cannot recursively enter another Nix shell!"


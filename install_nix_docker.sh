#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Nix Configuration Phase ---
echo "Configuring Nix for installation..."
sudo mkdir -m 0755 -p /nix
sudo chown swebot /nix
sudo mkdir -p /home/jules/.config/nix

# Create nix.conf for the installation and for future use.
# Using 'relaxed' sandbox for better compatibility in constrained environments.
sudo tee /home/jules/.config/nix/nix.conf > /dev/null <<EOF
sandbox = relaxed
experimental-features = nix-command flakes
EOF

# Ensure the user 'jules' owns their own configuration files
sudo chown -R jules:jules /home/jules/.config

# --- Nix Installation Phase ---
echo "Installing Nix..."
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) \
    --no-daemon \
    --nix-extra-conf-file /home/jules/.config/nix/nix.conf \
    --yes

# --- Verification Phase ---
echo "Activating Nix environment for verification..."
# Source the Nix profile to make `nix` commands available in this script session
. /home/jules/.nix-profile/etc/profile.d/nix.sh

echo "Verifying installation and printing system info with 'nix-info -m'..."
# Use nix-shell to run nix-info, which confirms Nix can fetch and run packages.
nix-shell -p nix-info --run 'nix-info -m'

echo "Nix installation and verification complete!"

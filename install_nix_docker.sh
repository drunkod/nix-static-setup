#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

CALLING_USER=${SUDO_USER:-$(whoami)}

# Get the home directory for that specific user.
# Using 'eval' is a robust way to expand the tilde (~) for any user.
USER_HOME=$(eval echo "~$CALLING_USER")

echo "---"
echo "Running script for user: $CALLING_USER"
echo "Using home directory:    $USER_HOME"
echo "---"



# --- Nix Configuration Phase ---
echo "Configuring Nix for installation..."
# The /nix directory should be owned by the user who will manage it.
sudo mkdir -m 0755 -p /nix
sudo chown "$CALLING_USER" /nix

# Create the user-specific Nix config directory using the detected home path.
sudo mkdir -p "$USER_HOME/.config/nix"

# Create nix.conf with settings for compatibility in containers.
# This file will be owned by root initially.
sudo tee "$USER_HOME/.config/nix/nix.conf" > /dev/null <<EOF
sandbox = relaxed
experimental-features = nix-command flakes
filter-syscalls = false
EOF

# IMPORTANT: Change ownership of the entire .config directory back to the user.
# This ensures the user can manage their own files without sudo later.
echo "Setting correct ownership for $USER_HOME/.config..."
sudo chown -R "$CALLING_USER:$CALLING_USER" "$USER_HOME/.config"


# --- Nix Installation Phase ---
echo "Installing Nix..."
# The installer is run as the original user to ensure profiles are set up correctly.
# We use 'sudo -u' to de-escalate privileges from root to the target user.
# The installer itself will use 'sudo' internally where needed if run this way.
# NOTE: The Determined Nix Installer requires being run as the user.
# For other installers, you might need to adjust. The official installer
# handles this well.
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) \
    --no-daemon \
    --nix-extra-conf-file "$USER_HOME/.config/nix/nix.conf" \
    --yes


# --- Verification Phase ---
echo "Activating Nix environment for verification..."
# Source the Nix profile script from the user's actual home directory.
. "$USER_HOME/.nix-profile/etc/profile.d/nix.sh"

echo "Verifying installation and printing system info with 'nix-info -m'..."
# Use nix-shell to run nix-info. This is a full end-to-end test.
nix-shell -p nix-info --run 'nix-info -m'

echo "---"
echo "Nix installation and verification complete for user '$CALLING_USER'!"
echo "---"

#!/bin/bash

# Script to install Nix on Alpine Linux

# Function to check if a command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Update package index and install required packages
echo "Installing required packages..."
apk update
apk add sudo shadow bash curl xz
check_success "Failed to install required packages."

# Download and install Nix
echo "Downloading and installing Nix..."
sh <(curl -L https://nixos.org/nix/install) --daemon
check_success "Failed to install Nix."

# Create Nix daemon service script
echo "Configuring Nix daemon..."
cat << 'EOF' > /etc/init.d/nix-daemon
#!/sbin/openrc-run
description="Nix multi-user support daemon"

command="/usr/sbin/nix-daemon"
command_background="yes"
pidfile="/run/$RC_SVCNAME.pid"
EOF

sudo chmod a+rx /etc/init.d/nix-daemon

# Copy the nix-daemon binary to /usr/sbin
echo "Copying nix-daemon binary..."
sudo cp /root/.nix-profile/bin/nix-daemon /usr/sbin
check_success "Failed to copy nix-daemon binary."

# Enable and start the Nix daemon service
echo "Enabling and starting Nix daemon service..."
sudo rc-update add nix-daemon
sudo rc-service nix-daemon start
check_success "Failed to start Nix daemon service."

# Add user to nixbld group
echo "Adding user to nixbld group..."
sudo adduser "$USER" nixbld
check_success "Failed to add user to nixbld group."

# Create Nix configuration directory and file
echo "Configuring Nix..."
mkdir -p ~/.config/nix
echo 'extra-experimental-features = flakes nix-command' >> ~/.config/nix/nix.conf

# Update PATH in .profile
echo "Updating PATH in ~/.profile..."
echo 'export PATH=$PATH:/nix/var/nix/profiles/default/bin' >> ~/.profile

# Instructions for reboot
echo "Installation complete! Please reboot your system to apply changes."
echo "After reboot, you can verify the installation by running:"
echo "nix-shell -p nix-info --run 'nix-info -m'"

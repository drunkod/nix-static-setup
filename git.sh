#!/bin/bash

# Script to install Git without root privileges
# This will install Git and required dependencies in your home directory
# This version excludes curl support

# Set up variables
GIT_VERSION="2.43.0"  # Update this as needed
INSTALL_DIR="$HOME/git"
BUILD_DIR="$HOME/git_build"
DEPS_DIR="$HOME/git_deps"

echo "Installing Git $GIT_VERSION to $INSTALL_DIR"

# Create directories if they don't exist
mkdir -p "$INSTALL_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$DEPS_DIR"

# Install zlib dependency first
cd "$BUILD_DIR"
echo "Installing zlib dependency..."
wget https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz
tar -xzf zlib-1.3.1.tar.gz
cd zlib-1.3.1
./configure --prefix="$DEPS_DIR"
make
make install

# Download Git source code
cd "$BUILD_DIR"
echo "Downloading Git source code..."
wget "https://www.kernel.org/pub/software/scm/git/git-$GIT_VERSION.tar.gz"

# Extract the source code
echo "Extracting source code..."
tar -xzf "git-$GIT_VERSION.tar.gz"
cd "git-$GIT_VERSION"

# Configure Git with custom prefix and dependency paths
echo "Configuring Git..."
export CFLAGS="-I$DEPS_DIR/include"
export LDFLAGS="-L$DEPS_DIR/lib"
export LD_LIBRARY_PATH="$DEPS_DIR/lib:$LD_LIBRARY_PATH"
./configure --prefix="$INSTALL_DIR" --with-curl

# Compile and install Git
echo "Compiling Git (this may take a while)..."
make 
make install

# Add Git and deps to PATH and LD_LIBRARY_PATH in shell configuration
echo "Adding Git to your PATH..."
SHELL_CONFIG="$HOME/.bashrc"

if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
fi

if ! grep -q "PATH=\$PATH:$INSTALL_DIR/bin" "$SHELL_CONFIG"; then
    echo "export PATH=\$PATH:$INSTALL_DIR/bin" >> "$SHELL_CONFIG"
    echo "export LD_LIBRARY_PATH=$DEPS_DIR/lib:\$LD_LIBRARY_PATH" >> "$SHELL_CONFIG"
    echo "Git has been added to your PATH in $SHELL_CONFIG"
fi

# Clean up
echo "Cleaning up build files..."
cd "$HOME"
# rm -rf "$BUILD_DIR"  # Commented out for debugging if needed

echo "Git $GIT_VERSION has been installed to $INSTALL_DIR/bin"
echo "Dependencies were installed to $DEPS_DIR"
echo "Please restart your shell or run: source $SHELL_CONFIG"
echo "You can verify the installation by running: git --version"
echo "Note: This Git installation does not include curl support"

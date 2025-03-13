#!/bin/bash

# Script to install VS Code as a portable application without root privileges

# Set up variables
INSTALL_DIR="$HOME/vscode"
DOWNLOAD_DIR="$HOME/vscode_download"
VSCODE_VERSION="latest"  # Can be changed to a specific version if needed

echo "Installing portable VS Code to $INSTALL_DIR"

# Create directories if they don't exist
mkdir -p "$INSTALL_DIR"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

# Download VS Code
echo "Downloading VS Code..."
if [ "$VSCODE_VERSION" = "latest" ]; then
    # Download the latest stable version
    wget -O vscode.tar.gz "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"
else
    # Download a specific version if specified
    wget -O vscode.tar.gz "https://update.code.visualstudio.com/commit:$VSCODE_VERSION/server-linux-x64/stable"
fi

# Extract VS Code
echo "Extracting VS Code..."
tar -xzf vscode.tar.gz -C "$INSTALL_DIR" --strip-components=1

# Create a launcher script
echo "Creating launcher script..."
cat > "$INSTALL_DIR/code-portable.sh" << 'EOL'
#!/bin/bash
SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
export VSCODE_PORTABLE="$SCRIPT_PATH/data"
"$SCRIPT_PATH/code" "$@"
EOL

chmod +x "$INSTALL_DIR/code-portable.sh"

# Create data directory for portable mode
mkdir -p "$INSTALL_DIR/data"

# Create desktop entry file
echo "Creating desktop entry file..."
mkdir -p "$HOME/.local/share/applications"

cat > "$HOME/.local/share/applications/code-portable.desktop" << EOL
[Desktop Entry]
Name=VS Code (Portable)
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=$INSTALL_DIR/code-portable.sh
Icon=$INSTALL_DIR/resources/app/resources/linux/code.png
Type=Application
StartupNotify=false
StartupWMClass=Code
Categories=Utility;TextEditor;Development;IDE;
MimeType=text/plain;inode/directory;
Actions=new-empty-window;
Keywords=vscode;code;

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=$INSTALL_DIR/code-portable.sh --new-window
Icon=$INSTALL_DIR/resources/app/resources/linux/code.png
EOL

# Add VS Code to PATH in shell configuration
echo "Adding VS Code to your PATH..."
SHELL_CONFIG="$HOME/.bashrc"

if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
fi

if ! grep -q "PATH=\$PATH:$INSTALL_DIR" "$SHELL_CONFIG"; then
    echo "export PATH=\$PATH:$INSTALL_DIR" >> "$SHELL_CONFIG"
    echo "VS Code has been added to your PATH in $SHELL_CONFIG"
fi

# Create a symbolic link in ~/bin if it exists
if [ -d "$HOME/bin" ]; then
    ln -sf "$INSTALL_DIR/code-portable.sh" "$HOME/bin/code-portable"
    echo "Created symbolic link in ~/bin/code-portable"
fi

# Clean up
echo "Cleaning up download files..."
rm -rf "$DOWNLOAD_DIR"

echo "VS Code has been installed to $INSTALL_DIR"
echo "You can launch it by running: $INSTALL_DIR/code-portable.sh"
echo "Or by clicking VS Code (Portable) in your application menu"
echo "Please restart your shell or run: source $SHELL_CONFIG to update your PATH"

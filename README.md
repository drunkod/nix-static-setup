# Nix Static Setup Script

This repository contains a bash script to automate the setup of a static version of Nix on your system. The script downloads the latest static version of Nix, configures it, and provides commands to build and run programs.

## Prerequisites

- A Unix-like operating system (Linux, macOS, etc.)
- `curl` installed on your system
- Basic knowledge of using the terminal

## Usage

1. **Clone the repository:**

   ```bash
   git clone https://github.com/yourusername/nix-static-setup.git
   cd nix-static-setup
   ```

2. **Make the script executable:**

   ```bash
   chmod +x setup_nix.sh
   ```

3. **Run the script:**

   ```bash
   ./setup_nix.sh
   ```

   This will download the latest static version of Nix, configure it, and set up the necessary environment.

## Configuration

The script will create a configuration file at `~/.config/nix/nix.conf` with the following content:

```ini
store = ~/mynixroot
extra-experimental-features = flakes nix-command
ssl-cert-file = /etc/pki/tls/cert.pem
```

- **store**: Specifies the root directory for Nix.
- **extra-experimental-features**: Enables experimental features like flakes and the Nix command.
- **ssl-cert-file**: Path to the SSL certificate file. Adjust this path if necessary.

## Running Nix Programs

After running the script, you can use the following commands to run Nix programs:

- To run a program (e.g., `hello`):

  ```bash
  ~/nixstatic run nixpkgs#hello
  ```

- To enter a Nix shell:

  ```bash
  ~/nixstatic shell nixpkgs#nix nixpkgs#bashInteractive --command bash
  ```

  You can then use commands like `nix profile install`. Note that you cannot recursively enter another Nix shell.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any suggestions or improvements.

## Acknowledgments

- Thanks to the Nix community for their contributions and support.


# Run apps --no-sandbox

code --no-sandbox
google-chrome-stable --no-sandbox

# Run To enter a Nix shell:

~/nixstatic shell nixpkgs#nix nixpkgs#bashInteractive nixpkgs#git --command bash

fix error ssl
git config --global http.sslVerify false

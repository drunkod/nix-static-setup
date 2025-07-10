

# How to Install Nix in Docker

This guide provides a robust method for installing Nix inside a Docker container. The primary challenge when doing this is that Docker's default security settings can conflict with the Nix installer's sandboxing feature (`seccomp`), leading to installation errors.

The solution is to configure Nix to use a more relaxed sandbox and explicitly disable certain system call filters during the installation process.

---

## Method 1: Quick Install via Script

This method uses a pre-written script that automates all the necessary steps, including creating the required configuration.

### A) The One-Liner (Fastest)

Run this command to download and execute the installation script directly. Use this only if you trust the source of the script.

```bash
curl -sSL "https://raw.githubusercontent.com/drunkod/nix-static-setup/refs/heads/main/install_nix_docker.sh" | bash
```

### B) The Safe Method (Recommended)

This approach lets you inspect the script before running it.

1.  **Download the script:**
    ```bash
    curl -L "https://raw.githubusercontent.com/drunkod/nix-static-setup/refs/heads/main/install_nix_docker.sh" -o install_nix_docker.sh
    ```

2.  **Inspect the script (optional but recommended):**
    ```bash
    less install_nix_docker.sh
    ```

3.  **Make the script executable:**
    ```bash
    chmod +x install_nix_docker.sh
    ```

4.  **Run the script:**
    ```bash
    ./install_nix_docker.sh
    ```

---

## Method 2: Creating a Dockerfile (Most Reproducible)

For a truly automated and reproducible environment, a `Dockerfile` is the best solution. This file builds an image with Nix pre-installed.

1.  Create a file named `Dockerfile` in an empty directory.
2.  Copy the contents below into your `Dockerfile`.

```dockerfile
# Start from a common base image
FROM debian:stable-slim

# Set an environment variable for non-interactive installs
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies needed for the Nix installation
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user to own the Nix profile and configuration
# The user 'swebot' is used here as an example, matching the script
RUN useradd --create-home --shell /bin/bash swebot
RUN adduser swebot sudo

# Switch to the user to set up user-specific config
USER swebot
WORKDIR /home/swebot

# Create the Nix configuration directory and file
# This is the most critical step to avoid sandbox errors
RUN mkdir -p /home/swebot/.config/nix && \
    echo "sandbox = relaxed" > /home/swebot/.config/nix/nix.conf && \
    echo "experimental-features = nix-command flakes" >> /home/swebot/.config/nix/nix.conf && \
    echo "filter-syscalls = false" >> /home/swebot/.config/nix/nix.conf

# Switch back to root to run the installer with sudo privileges
USER root

# Run the official Nix installer
# --daemon:       Use the standard multi-user installation
# --yes:          Run non-interactively
# --nix-extra-conf-file:  Tell the installer to use our custom config
RUN sh <(curl -L https://nixos.org/nix/install) \
    --daemon \
    --yes \
    --nix-extra-conf-file /home/swebot/.config/nix/nix.conf

# Add the nix command to the PATH for all users
# and ensure it's available in subsequent shell sessions
RUN echo ". /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" >> /etc/profile

# Verify the installation
# Note: We need to source the script to get `nix` in the PATH for this RUN command
RUN . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && \
    nix-shell -p nix-info --run "nix-info -m"

# Set a default command to start a shell with Nix environment sourced
CMD ["/bin/bash"]
```

### Building and Running the Docker Image

1.  **Build the image:**
    ```bash
    docker build -t nix-docker-image .
    ```

2.  **Run a container:**
    ```bash
    docker run -it nix-docker-image
    ```

You will now be inside a shell where you can immediately start using `nix` commands.

---

### Key Configuration Explained

The core of this solution is the `nix.conf` file created before installation.

```sandbox = relaxed
experimental-features = nix-command flakes
filter-syscalls = false
```

*   `sandbox = relaxed`: This tells Nix to use a less strict sandboxing mode. The default mode (`true`) tries to use Linux `seccomp` features that are often disabled by default in Docker, causing the installation to fail with an `invalid argument` error. `relaxed` provides a good balance of security and compatibility.
*   `experimental-features = nix-command flakes`: This enables the modern `nix` command-line interface and Flakes, which are central to modern Nix workflows.
*   `filter-syscalls = false`: This is an older setting that directly disables the system call filtering that causes issues in Docker. While `sandbox = relaxed` is the modern way to achieve this, including `filter-syscalls = false` provides maximum compatibility and explicitly prevents potential errors in certain environments.

# Installing Nix on Alpine Linux

This tutorial will guide you through the steps to install Nix on Alpine Linux. Follow the steps below to get started.

## Prerequisites

Make sure you have Alpine Linux installed and you have access to the terminal.

## Installation Steps

### 1. Install Required Packages

Before installing Nix, you need to install some required packages. Run the following commands:

```sh
apk add sudo
apk add shadow
apk add bash
apk add curl
apk add xz
```

- The `sudo` package is needed; aliasing `/usr/bin/doas` does not work.
- The `shadow` package provides `groupadd` and related tools, which are needed by the Nix install script.
- The install script might not behave with `ash`, so we install `bash`.

### 2. Download and Install Nix

Run the following command to install Nix:

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon
```

During the installation, you will be prompted to:
- Answer **no** to more info.
- Answer **yes** to use `sudo`.
- Answer **yes** to proceed with the multi-user installation.
- Answer **yes** to continue.
- If successful, acknowledge the reminder.

### 3. Configure Nix Daemon

Alpine does not use `systemd`. You need to create a service script for the Nix daemon. Copy the following script to `/etc/init.d/nix-daemon` and make it executable:

```sh
#!/sbin/openrc-run
description="Nix multi-user support daemon"

command="/usr/sbin/nix-daemon"
command_background="yes"
pidfile="/run/$RC_SVCNAME.pid"
```

For some reason, the multi-user install does not place the `nix-daemon` binary in a system directory; instead, it gets installed here:

```sh
/root/.nix-profile/bin/nix-daemon
```

You can copy this binary to `/usr/sbin`:

```sh
# run as root or sudo
chmod a+rx /etc/init.d/nix-daemon
cp /root/.nix-profile/bin/nix-daemon /usr/sbin
rc-update add nix-daemon
rc-service nix-daemon start
```

### 4. Post-Install Steps

Ensure that your user ID has been added to the `nixbld` group. You also need to open up the permissions on the `nix-daemon` socket so that `nixbld` group members can communicate with the daemon.

Follow the instructions emitted by the script. Run it as root the first time:

```sh
# The nix installer should have emitted this text:
#   Alright! We're done!
#   Try it! Open a new terminal, and type:
#   nix-shell -p nix-info --run "nix-info -m"
```

The output should look something like this:

```
 - system: `"x86_64-linux"`
 - host os: `Linux 6.1.8-0-lts, Alpine Linux, noversion, nobuild`
 - multi-user?: `yes`
 - sandbox: `yes`
 - version: `nix-env (Nix) 2.13.1`
 - channels(root): `"nixpkgs"`
 - nixpkgs: `/root/.nix-defexpr/channels/nixpkgs`
```

Now, before trying to run Nix as a non-root user, add yourself to the `nixbld` group and reboot. This ensures your user ID is in the `nixbld` group and that all running shells have picked it up. Rebooting will also test that the service starts correctly on a fresh boot.

```sh
sudo adduser YOURUSERID nixbld
reboot  # or do a safe shutdown however you usually do it
```

### 5. Verify Nix Installation

After installation, you can verify that Nix is installed correctly by checking the contents of the `/nix` directory:

```sh
ls /nix
```

### 6. Check Default Profile Binaries

To see the binaries available in the default Nix profile, run:

```sh
ls /nix/var/nix/profiles/default/bin
```

### 7. Update Your PATH

To ensure that the Nix binaries are available in your terminal session, add the Nix profile to your PATH. You can do this by adding the following line to your `~/.profile`:

```sh
echo 'export PATH=$PATH:/nix/var/nix/profiles/default/bin' >> ~/.profile
```

### 8. Apply Changes

After updating your `~/.profile`, either restart your terminal or run the following command to apply the changes:

```sh
source ~/.profile
```

### 9. Configure Nix

Create a configuration file for Nix to enable extra experimental features. First, create the necessary directory:

```sh
mkdir -p ~/.config/nix
```

Then, add the following line to `~/.config/nix/nix.conf`:

```sh
echo 'extra-experimental-features = flakes nix-command' >> ~/.config/nix/nix.conf
```

## Conclusion

You have successfully installed Nix on Alpine Linux! You can now use Nix to manage packages and environments. For more information on using Nix, refer to the [Nix documentation](https://nixos.org/manual/nix/stable/).

### Additional Resources

- [Nixpkgs](https://nixos.org/nixpkgs/)
- [NixOS Wiki](https://nixos.wiki/)
- [Nix Community](https://nixos.org/community)

Feel free to explore the capabilities of Nix and customize your environment as needed!
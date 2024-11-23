You're right. Let me provide a corrected configuration for Nix-on-Droid that properly sets up NuShell. Here's the correct approach:

1. Basic Configuration (nix-on-droid.nix):

```nix
{ pkgs, ... }:

{
  system.stateVersion = "24.05";

  # Add NuShell to the environment packages
  environment.packages = with pkgs; [
    nushell
  ];

  # Configure user shell
  user.shell = "${pkgs.nushell}/bin/nu";

  # Enable nix-index for command-not-found
  nixpkgs.config.allowUnfree = true;
}
```

2. If you want to add custom configuration for NuShell, create a config file:

```bash
mkdir -p ~/.config/nushell
```

Create `~/.config/nushell/config.nu`:

```nu
# Basic configuration
let-env PATH = ($env.PATH | split row (char esep))

# Aliases
alias ll = ls -l
alias la = ls -a

# Custom prompt (optional)
def create_left_prompt [] {
    let path_segment = ($env.PWD | str replace $env.HOME "~")
    $"(ansi green)[$path_segment](ansi reset) "
}

# Use the custom prompt
let-env PROMPT_COMMAND = { create_left_prompt }
```

3. Create `~/.config/nushell/env.nu`:

```nu
# Environment variables
let-env PATH = ($env.PATH | split row (char esep))
let-env EDITOR = "vim"
let-env VISUAL = "vim"
```

4. To apply the changes:

```bash
nix-on-droid switch
```

5. To start using NuShell:

```bash
nu
```

Additional Tips:

1. To make NuShell work better with Nix-on-Droid, you might want to add some helper functions to your config:

```nu
# Add to ~/.config/nushell/config.nu

# Nix-related aliases
alias nod = nix-on-droid
alias nos = nix-on-droid switch

# Helper function for Nix shell
def nix-shell [pkg: string] {
    ^nix-shell -p $pkg
}
```

2. If you need to handle environment variables from Nix:

```nix
# In nix-on-droid.nix
environment.variables = {
  EDITOR = "vim";
  VISUAL = "vim";
  TERM = "xterm-256color";
};
```

3. To ensure proper PATH handling:

```nu
# In ~/.config/nushell/env.nu
let-env PATH = ($env.PATH | split row (char esep) | uniq)
```

This configuration:
- Installs NuShell via Nix-on-Droid
- Sets NuShell as the default shell
- Provides basic configuration for NuShell
- Maintains compatibility with Nix-on-Droid's environment

Remember that NuShell's syntax and behavior differ from traditional shells like Bash or Zsh, so you might need to adjust your scripts and commands accordingly.

To switch back to your previous shell if needed:

```bash
# In your nix-on-droid.nix
user.shell = "${pkgs.bash}/bin/bash";  # or whatever shell you prefer
```

Then run `nix-on-droid switch` to apply the changes.

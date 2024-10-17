It looks like you're trying to initialize a new Nix flake using a template from a registry, but you're encountering issues with the attributes not being found. Here are some steps to help you troubleshoot and resolve the problem:

1. **Check the Template Attributes**: The error messages indicate that the flake you are trying to use does not provide the expected attributes (`templates.rust` or `rust`). You can check the available attributes in the `github:MordragT/nix-templates` repository by inspecting its `flake.nix` file. You can do this by cloning the repository or viewing it directly on GitHub.

   ```bash
   git clone https://github.com/MordragT/nix-templates.git
   cd nix-templates
   cat flake.nix
   ```

   Look for the `outputs` section to see what templates are available.

2. **Use the Correct Template Name**: If the `flake.nix` file does not define `templates.rust`, you will need to use the correct attribute name as defined in that file. For example, if the template is defined under a different name, use that name instead.

3. **List Available Templates**: You can also list the available templates directly from the flake using the following command:

   ```bash
   nix flake show templates
   ```

   This will show you the available outputs and their corresponding attribute names.

4. **Use the Correct Registry Entry**: It seems you have added the `templates` registry entry correctly. However, ensure that you are using the correct flake reference. If you want to use the `NixOS/templates` flake instead, you can do so by running:

   ```bash
   nix flake init -t github:NixOS/templates#rust
   ```

5. **Check for Updates**: If you are using a specific version of the template, ensure that you are using the latest version. You can update the registry entry or specify a version tag if necessary.

6. **Consult Documentation**: If you're still having trouble, refer to the documentation for the specific template repository or the Nix documentation for more guidance on using flakes and templates.

By following these steps, you should be able to identify the correct template to use and successfully initialize your Nix flake.


https://github.com/MordragT/nix-templates

https://github.com/the-nix-way/dev-templates

work with 23 version https://bnikolic.co.uk/blog/nix/2024/01/16/nix-without-root.html
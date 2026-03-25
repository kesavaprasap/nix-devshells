# Standard preset - Current common.nix behavior
# Includes minimal preset + editors, utilities, and main MCP servers
{
  pkgs,
  lib,
  modules,
}: let
  # Inherit from minimal preset and add more modules
  minimalPreset = modules.presets.minimal;

  # Additional modules beyond minimal
  additionalModules = [
    modules.tools.editors # Neovim with LSP + plugins
    modules.mcp.codanna # Code intelligence
    modules.mcp.serena # Project analysis
    modules.mcp.shrimp # Task management
  ];

  # Combine minimal packages with additional packages
  allPackages =
    minimalPreset.packages
    ++ (lib.flatten (map (m: m.packages or []) additionalModules));

  # Merge shellHooks from minimal and additional modules
  allShellHooks =
    minimalPreset.shellHook
    + "\n"
    + (lib.concatStringsSep "\n" (map (m: m.shellHook or "") additionalModules));
in {
  meta = {
    name = "standard";
    description = "Standard development toolset (matches current common.nix)";
    category = "preset";
  };

  # Combined packages from minimal + additional
  packages = allPackages;

  # Combined shellHooks
  shellHook = allShellHooks;

  # Track all included modules (minimal + additional)
  includes = minimalPreset.includes ++ additionalModules;
}

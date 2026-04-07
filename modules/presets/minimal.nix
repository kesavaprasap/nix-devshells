# Minimal preset - Essential development tools only
# Includes only version control and Nix tools for lightweight shells
{
  pkgs,
  lib,
  modules,
}: let
  # Include essential tool modules
  includedModules = [
    modules.tools.version-control # git, git-lfs
    modules.tools.utilities # jq, curl, wget, tree, fd, ripgrep, etc.
    modules.tools.nix-tools # nixfmt, nil, alejandra, deadnix, statix
    modules.tools.prompt # starship prompt with git integration
  ];

  # Flatten packages from all included modules
  allPackages = lib.flatten (map (m: m.packages or []) includedModules);

  # Merge shellHooks from all included modules
  allShellHooks = lib.concatStringsSep "\n" (map (m: m.shellHook or "") includedModules);
in {
  meta = {
    name = "minimal";
    description = "Essential development tools only (git + nix tools)";
    category = "preset";
  };

  # Flattened packages from included modules
  packages = allPackages;

  # Combined shellHook
  shellHook = allShellHooks;

  # Track what was included (useful for debugging/introspection)
  includes = includedModules;
}

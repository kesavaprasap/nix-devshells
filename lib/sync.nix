# Generates the sync-mcps script
  # Reads all MCP module configs and produces a script that:
  #   1. Installs MCP packages to the nix profile
  #   2. Writes mcpServers entries to ~/.claude.json (with secret wrappers)
  {
    pkgs,
    lib,
    modules,
    flakeSelf,
    system,
  }:
  let
    mcpModules = builtins.filter
      (mod: !(mod.meta.disabled or false))
      (lib.attrValues modules.mcp);

    # For modules with a secret, wrap the command so age decrypts at process start
    makeEntry = mod:
      let
        cfg = mod.mcpConfig or {};
        serverName = mod.meta.name;
        server = cfg.${serverName} or {};
        secret = mod.meta.secret or null;
        ageDir = "~/.secrets";
        ageKey = "~/.config/age/key.txt";
      in
        if secret != null then
          cfg // {
            ${serverName} = server // {
              command = "bash";
              args = [
                "-c"
                "${secret.envVar}=$(age -d -i ${ageKey} ${ageDir}/${secret.ageFile}) exec ${server.command}"
              ];
            };
          }
        else
          cfg;

    # Merge all MCP configs into one attrset
    allConfigs = lib.foldl (acc: mod: acc // (makeEntry mod)) {} mcpModules;

    # JSON to splice into ~/.claude.json
    mcpJson = builtins.toJSON allConfigs;

    # List of flake package attrs for nix profile install
    packageAttrs = map (mod: "github:kesavaprasap/nix-devshells#${mod.meta.name}")
  mcpModules;
  in
    pkgs.writeShellScript "sync-mcps" ''
      set -e
      JQ=${pkgs.jq}/bin/jq
      AGE=${pkgs.age}/bin/age

      echo "→ Syncing MCP servers to ~/.claude.json"

      # Patch mcpServers in ~/.claude.json
      MCP_CONFIGS='${mcpJson}'
      $JQ --argjson mcps "$MCP_CONFIGS" '.mcpServers = (.mcpServers // {}) + $mcps' \
        ~/.claude.json > ~/.claude.json.tmp \
        && mv ~/.claude.json.tmp ~/.claude.json
      echo "  ✓ ~/.claude.json updated"

      echo ""
      echo "Done. Restart Claude Code to pick up the new servers."
    ''


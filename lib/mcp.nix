# MCP configuration generation
# Generates .mcp.json files from MCP modules
{
  pkgs,
  lib,
  filterByCategory,
}: rec {
  # Generate MCP configuration from modules
  # Returns a derivation containing the mcp.json file
  generateMcpConfig = modules: generateMcpConfigFiltered modules [];

  # Generate MCP configuration excluding specific servers by name
  # excludeNames is a list of module names to exclude (e.g., ["claude-task-master"])
  generateMcpConfigFiltered = modules: excludeNames: let
    # Filter to only MCP modules
    mcpModules = filterByCategory "mcp" modules;

    # Filter out excluded modules by name
    filteredModules =
      builtins.filter
      (m: !(builtins.elem (m.meta.name or "") excludeNames))
      mcpModules;

    # Extract mcpConfig from each module
    configs = map (m: m.mcpConfig or {}) filteredModules;

    # Merge all configs (later configs override earlier ones)
    mergedConfig = lib.foldl (a: b: a // b) {} configs;

    # Generate JSON content
    jsonContent = builtins.toJSON {mcpServers = mergedConfig;};
  in
    # Write to a file in the Nix store
    pkgs.writeText "mcp.json" jsonContent;

  # Generate MCP configs for worktree setup
  # Returns attrset with orchestrator (all MCPs) and shared (without task-master)
  generateWorktreeMcpConfigs = modules: {
    orchestrator = generateMcpConfig modules;
    shared = generateMcpConfigFiltered modules ["claude-task-master"];
  };

  # Generate shellHook snippet for MCP config setup
  # Nix devshell is the source of truth — overwrites .mcp.json and syncs settings.local.json
  mcpConfigShellHook = mcpConfigFile: ''
    # .mcp.json — always written from Nix (source of truth)
    cp ${mcpConfigFile} .mcp.json
    echo "  ✓ .mcp.json ($(${pkgs.jq}/bin/jq -r '.mcpServers | keys | join(", ")' ${mcpConfigFile}))"

    # .claude/settings.local.json — sync enabledMcpjsonServers
    _mcp_keys=$(${pkgs.jq}/bin/jq -c '.mcpServers | keys' ${mcpConfigFile})
    mkdir -p .claude
    if [ -f .claude/settings.local.json ]; then
      ${pkgs.jq}/bin/jq --argjson k "$_mcp_keys" '.enabledMcpjsonServers = $k' \
        .claude/settings.local.json > .claude/.settings.local.tmp \
        && mv .claude/.settings.local.tmp .claude/settings.local.json
    else
      printf '{"enabledMcpjsonServers":%s}\n' "$_mcp_keys" > .claude/settings.local.json
    fi
    echo "  ✓ .claude/settings.local.json (enabledMcpjsonServers synced)"
  '';
}

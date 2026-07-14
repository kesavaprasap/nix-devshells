# CrateDocs MCP server - Rust documentation search
{
  pkgs,
  lib,
  devPkgs,
}: {
  meta = {
    name = "cratedocs";
    description = "Rust documentation MCP server";
    category = "mcp";
    languages = ["rust"];
  };

  packages = [devPkgs.cratedocs-mcp];

  mcpConfig = {
    cratedocs = {
      type = "stdio";
      command = "cratedocs";
      args = ["stdio"];
    };
  };

  shellHook = ''
    echo "  📚 cratedocs: Rust documentation search"
  '';
}

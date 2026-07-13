# Development-only packages for devshells
# These packages are specific to development environments and not meant for system-wide use
{pkgs}: {
  cargo-mcp = pkgs.callPackage ./cargo-mcp.nix {
    inherit (pkgs) rust-bin;
  };

  mcp-shrimp-task-manager = pkgs.callPackage ./shrimp.nix {};

  mcp-gitlab = pkgs.callPackage ./gitlab.nix {};

  codanna = pkgs.callPackage ./codanna.nix {};

  cratedocs-mcp = pkgs.callPackage ./cratedocs-mcp.nix {};

  puppeteer-mcp-server = pkgs.callPackage ./puppeteer-mcp.nix {};

  universal-screenshot-mcp = pkgs.callPackage ./universal-screenshot-mcp.nix {};

  computer-use-mcp = pkgs.callPackage ./computer-use-mcp.nix {};

  mcp-grafana = pkgs.callPackage ./grafana-mcp.nix {};

  claude-task-master = pkgs.callPackage ./claude-task-master {};
}

{
  pkgs,
  inputs,
  lib,
}:
# Nix development tools and environment
# Provides everything needed for NixOS configuration development including formatters and analysis tools
{
  meta = {
    name = "nix";
    description = "Nix/NixOS development environment";
    category = "language";
  };

  packages = [
    # NixOS specific tools
    pkgs.nixos-rebuild

    # Nix development tools
    pkgs.alejandra # Nix formatter
    pkgs.deadnix # Dead code detection
    pkgs.statix # Nix linter
    pkgs.cachix # Binary cache management
    pkgs.nix-tree # Analyze dependency trees
    pkgs.nix-diff # Compare derivations

    # Pre-commit hook tools
    pkgs.prettier # Multi-language formatter
    pkgs.yamllint # YAML linting
    pkgs.typos # Spell checker
    pkgs.shellcheck # Shell script linter
  ];

  shellHook = ''
    echo "🏗️  NixOS configuration development environment"
    echo "📦 Cache optimization enabled with Cachix integration"
    echo ""
    echo "Available commands:"
    echo "  nixos-rebuild switch --flake .#<hostname>"
    echo "  home-manager switch --flake .#<username>@<hostname>"
    echo "  alejandra . # Format nix files"
    echo "  deadnix . # Check for dead code"
    echo "  statix check . # Lint nix files"
    echo "  cachix push <cache-name> <store-path> # Push to cache"
    echo "  nix-tree # Analyze dependency tree"
    echo "  nix-diff derivation1 derivation2 # Compare builds"
    echo ""
    echo "💡 Build performance optimizations active:"
    echo "  - Multiple Cachix caches configured"
    echo "  - Auto store optimization enabled"
    echo "  - Parallel builds with all cores"
  '';

  suggestedMcps = [];
}

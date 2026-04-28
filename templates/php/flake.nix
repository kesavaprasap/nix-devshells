{
  description = "My PHP Project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Import devshells for development environment
    devshells.url = "github:Ba-So/nix-devshells";
    # Optionally pin to a specific version:
    # devshells.url = "github:Ba-So/nix-devshells?ref=v1.0.0";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devshells,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: {
      # Uncomment to build your PHP project
      # packages.default = let
      #   pkgs = nixpkgs.legacyPackages.${system};
      # in pkgs.stdenv.mkDerivation {
      #   pname = "my-php-project";
      #   version = "0.1.0";
      #
      #   src = ./.;
      #
      #   buildInputs = with pkgs; [
      #     php83
      #     php83Packages.composer
      #   ];
      #
      #   buildPhase = ''
      #     # Install composer dependencies
      #     composer install --no-dev --optimize-autoloader
      #   '';
      #
      #   installPhase = ''
      #     mkdir -p $out/share/php/my-php-project
      #     cp -r * $out/share/php/my-php-project/
      #
      #     # Optional: Create a wrapper script
      #     # mkdir -p $out/bin
      #     # cat > $out/bin/my-php-project << EOF
      #     # #!/bin/sh
      #     # ${pkgs.php83}/bin/php $out/share/php/my-php-project/index.php "\$@"
      #     # EOF
      #     # chmod +x $out/bin/my-php-project
      #   '';
      #
      #   meta = with pkgs.lib; {
      #     description = "My PHP project";
      #     homepage = "https://github.com/yourusername/my-php-project";
      #     license = licenses.mit;
      #     maintainers = [];
      #   };
      # };

      # Development environment using NEW composition API
      # This provides: PHP, Composer, development tools, git, helix, etc.
      devShells.default = devshells.lib.${system}.composeShell {
        languages = ["php"];
        mcps = ["serena" "puppeteer"]; # MCP servers for AI assistance & browser automation
        tools = "standard"; # or "minimal" for lightweight setup
      };

      # Alternative configurations (uncomment to use):

      # Minimal shell (fast startup, no MCP overhead):
      # devShells.default = devshells.lib.${system}.composeShell {
      #   languages = ["php"];
      #   tools = "minimal";
      #   mcps = [];
      # };

      # Extended shell with project-specific tools:
      # devShells.default = let
      #   pkgs = nixpkgs.legacyPackages.${system};
      # in devshells.lib.${system}.composeShell {
      #   languages = ["php"];
      #   mcps = ["serena" "puppeteer"];
      #   tools = "standard";
      #   extraPackages = with pkgs; [
      #     # Add project-specific development tools
      #     nodejs # For frontend asset compilation
      #     mysql84 # For local database
      #     redis # For caching
      #   ];
      #   extraShellHook = ''
      #     export DATABASE_URL="mysql://root@localhost/mydb"
      #   '';
      # };

      # Advanced: Direct module composition for full control
      # devShells.default = let
      #   inherit (devshells.lib.${system}) modules composeShellFromModules;
      # in
      #   composeShellFromModules [
      #     modules.languages.php
      #     modules.mcp.serena
      #     modules.mcp.puppeteer
      #     modules.tools.version-control
      #     modules.tools.editors
      #   ];

      # OLD API (still works, for migration reference):
      # devShells.default = devshells.devShells.${system}.php;
      #
      # OLD API with extension:
      # devShells.default = pkgs.mkShell {
      #   inputsFrom = [ devshells.devShells.${system}.php ];
      #   packages = with pkgs; [ nodejs mysql84 ];
      # };

      # Optional: Define apps for easy running
      # apps.default = {
      #   type = "app";
      #   program = "${self.packages.${system}.default}/bin/my-php-project";
      # };
    });
}

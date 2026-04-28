{
  description = "Development shells for various programming languages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    serena = {
      # pin to last-working commit, there is no release with a flake.nix yet
      url = "github:oraios/serena?ref=eb54e834b6da7a5e11f51c27afbcf55be92ae066";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codanna = {
      url = "github:ba-so/codanna";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs = {
        pyproject-nix.follows = "pyproject-nix";
        uv2nix.follows = "uv2nix";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
    rust-overlay,
    nixvim,
    serena,
    codanna,
    pyproject-nix,
    uv2nix,
    pyproject-build-systems,
    ...
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        # Create pkgs with rust overlay for cargo-mcp
        pkgs-with-rust = import nixpkgs {
          inherit system;
          overlays = [rust-overlay.overlays.default];
        };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            # Fix conan build failure (test_create_pip_manager fails with Python 3.13)
            (_: prev: {
              conan = prev.conan.overridePythonAttrs (old: {
                disabledTestPaths =
                  (old.disabledTestPaths or [])
                  ++ [
                    "test/functional/tools/system/pip_manager_test.py"
                  ];
              });
            })
          ];
        };

        # Create pkgs with unfree packages allowed for specific packages
        pkgs-unfree = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        # Import our shell definitions
        shells = import ./default.nix {
          inherit pkgs;
          _system = system;
          inputs = {inherit nixpkgs nixpkgs-unstable rust-overlay serena codanna nixvim;};
        };

        # Import lib system for module composition
        libSystem = import ./lib/default.nix {
          inherit pkgs system;
          inputs = {
            inherit nixpkgs nixpkgs-unstable rust-overlay serena codanna nixvim;
            inherit pyproject-nix uv2nix pyproject-build-systems;
          };
        };
      in {
        # Standard flake structure: devShells.<name>
        devShells = {
          inherit (shells) rust php nix cpp python py-cpp latex ansible julia;
          default = shells.nix; # Default to nix shell

          # NEW: Composed shells using module system
          rust-minimal = libSystem.composeShell {
            languages = ["rust"];
            tools = "minimal";
            mcps = ["cargo-mcp"];
          };

          rust-python = libSystem.composeShell {
            languages = ["rust" "python"];
            mcps = ["cargo-mcp" "serena"];
            tools = "standard";
          };

          web-dev = libSystem.composeShell {
            languages = ["rust" "python" "php"];
            mcps = ["cargo-mcp" "serena" "puppeteer"];
            tools = "standard";
          };
          kesava-dev = libSystem.composeShell {
            languages = ["rust" "python" "cpp"];
            mcps = ["cargo-mcp" "serena" "codanna"];
            tools = "standard";
          };
        };

        # Expose package sets for easy composition in other projects
        # Usage: buildInputs = devshells.packageSets.${system}.rust;
        inherit (shells) packageSets;

        # Expose lib for module composition
        # Usage: devshells.lib.${system}.composeShell { languages = ["rust"]; tools = "minimal"; }
        lib = {
          inherit (libSystem) composeShell composeShellFromModules modules;
        };

        # Expose custom packages
        packages = {
          cargo-mcp = pkgs-with-rust.callPackage ./pkgs/cargo-mcp.nix {
            inherit (pkgs-with-rust) rust-bin;
          };
          cratedocs-mcp = pkgs.callPackage ./pkgs/cratedocs-mcp.nix {};
          codanna = codanna.packages.${system}.default;
          claude-task-master = pkgs-unfree.callPackage ./pkgs/claude-task-master {};
          mcp-gitlab = pkgs.callPackage ./pkgs/gitlab.nix {};
          puppeteer-mcp-server = pkgs.callPackage ./pkgs/puppeteer-mcp.nix {};
          universal-screenshot-mcp = pkgs.callPackage ./pkgs/universal-screenshot-mcp.nix {};
          computer-use-mcp = pkgs.callPackage ./pkgs/computer-use-mcp.nix {};

          # Qdrant MCP - MCP server for semantic documentation search
          qdrant-mcp = pkgs.callPackage ./pkgs/qdrant-mcp.nix {
            inherit pyproject-nix uv2nix pyproject-build-systems;
          };

          # Paper Search MCP - Academic paper search across multiple sources
          paper-search-mcp = pkgs.callPackage ./pkgs/paper-search-mcp.nix {
            inherit pyproject-nix uv2nix pyproject-build-systems;
          };

          # Serena - MCP server for project analysis
          serena = serena.packages.${system}.default or serena.defaultPackage.${system};

          # Deprecated/legacy packages
          mcp-shrimp-task-manager = pkgs.callPackage ./pkgs/shrimp.nix {};

          # Default to cargo-mcp as it's most generally useful
          default = pkgs-with-rust.callPackage ./pkgs/cargo-mcp.nix {
            inherit (pkgs-with-rust) rust-bin;
          };
        };
      }
    )
    // {
      # Non-system-specific outputs
      templates = {
        rust = {
          path = ./templates/rust;
          description = "Rust project template with complete package definition";
        };
        php = {
          path = ./templates/php;
          description = "PHP project template with complete package definition";
        };
        latex = {
          path = ./templates/latex;
          description = "LaTeX document template with build configuration";
        };
        cpp = {
          path = ./templates/cpp;
          description = "C++ project template with CMake and complete package definition";
        };
        worktree = {
          path = ./templates/worktree;
          description = "Multi-agent worktree project with orchestrator and worker support";
        };
      };

      # Overlay for easy integration into other configurations
      overlays.default = final: _prev: {
        cargo-mcp = final.callPackage ./pkgs/cargo-mcp.nix {
          inherit (final) rust-bin;
        };
        cratedocs-mcp = final.callPackage ./pkgs/cratedocs-mcp.nix {};
        codanna = codanna.packages.${final.system}.default;
        claude-task-master = final.callPackage ./pkgs/claude-task-master {};
        mcp-gitlab = final.callPackage ./pkgs/gitlab.nix {};
        puppeteer-mcp-server = final.callPackage ./pkgs/puppeteer-mcp.nix {};
        universal-screenshot-mcp = final.callPackage ./pkgs/universal-screenshot-mcp.nix {};
        computer-use-mcp = final.callPackage ./pkgs/computer-use-mcp.nix {};
        qdrant-mcp = final.callPackage ./pkgs/qdrant-mcp.nix {
          inherit pyproject-nix uv2nix pyproject-build-systems;
        };
        paper-search-mcp = final.callPackage ./pkgs/paper-search-mcp.nix {
          inherit pyproject-nix uv2nix pyproject-build-systems;
        };

        # Deprecated/legacy packages
        mcp-shrimp-task-manager = final.callPackage ./pkgs/shrimp.nix {};

        # Expose devshells lib for external users
        devshells-lib = final.callPackage ./lib/default.nix {
          pkgs = final;
          inherit (final) system;
          inputs = {
            inherit nixpkgs nixpkgs-unstable rust-overlay serena codanna;
          };
        };
      };
    };
}

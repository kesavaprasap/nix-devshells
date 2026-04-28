{
  lib,
  pkgs,
  fetchFromGitHub,
  pyproject-nix,
  uv2nix,
  pyproject-build-systems,
}: let
  # Load the paper-search-mcp workspace
  src = fetchFromGitHub {
    owner = "openags";
    repo = "paper-search-mcp";
    rev = "cf2697fd04a7b7c1ced0e382ab84f0c214614f83";
    hash = "sha256-xnNvIcGHNe7L9OSRwCExQMnBJGbpSA5iUZZ/CVd1XGA=";
  };

  workspace = uv2nix.lib.workspace.loadWorkspace {workspaceRoot = src;};

  # Select Python interpreter
  python = pkgs.python3;

  # Create base Python package set
  pythonBase = pyproject-nix.build.packages {
    inherit pkgs python;
  };

  # Create overlay from uv.lock
  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel"; # Prefer binary wheels
  };

  # Fix for sgmllib3k which needs setuptools as build dependency
  buildSystemOverlay = final: prev: {
    sgmllib3k = prev.sgmllib3k.overrideAttrs (old: {
      nativeBuildInputs =
        (old.nativeBuildInputs or [])
        ++ [
          final.setuptools
        ];
    });
  };

  # Compose into final Python set with build systems
  pythonSet = pythonBase.overrideScope (
    lib.composeManyExtensions [
      pyproject-build-systems.overlays.wheel
      overlay
      buildSystemOverlay
    ]
  );

  # Build virtual environment with all dependencies
  venv = pythonSet.mkVirtualEnv "paper-search-mcp-env" workspace.deps.default;
in
  # Create wrapper script since package doesn't expose console_scripts
  pkgs.runCommand "paper-search-mcp" {
    nativeBuildInputs = [pkgs.makeWrapper];
    meta = {
      description = "MCP server for searching academic papers (arXiv, PubMed, bioRxiv, etc.)";
      homepage = "https://github.com/openags/paper-search-mcp";
      license = lib.licenses.mit;
      mainProgram = "paper-search-mcp";
    };
  } ''
    mkdir -p $out/bin
    makeWrapper ${venv}/bin/python $out/bin/paper-search-mcp \
      --add-flags "-m" \
      --add-flags "paper_search_mcp.server" \
      --unset PYTHONPATH \
      --unset PYTHONHOME
  ''

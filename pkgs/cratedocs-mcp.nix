{
  pkgs,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  rustPlatform ? pkgs.rustPlatform,
  pkg-config ? pkgs.pkg-config,
  openssl ? pkgs.openssl,
}:
rustPlatform.buildRustPackage rec {
  pname = "cratedocs-mcp";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "promptexecution";
    repo = "cratedocs-mcp";
    rev = "main";
    hash = "sha256-dbHL6NYrbngXViYl3q4gRQvlOR2OBZvT/GLttK/fxVk="; # Nix will provide the correct hash in error message
  };

  cargoHash = "sha256-m39S9KmPiFqYSyUqc1IJujiWLx3DQJSTjxPiUSfbplI="; # Nix will provide the correct hash in error message

  # Optimize build for faster compilation
  doCheck = false; # Skip tests to speed up build
  auditable = false; # Disable auditable builds for faster compilation

  nativeBuildInputs = [pkg-config];
  buildInputs = [openssl];

  # The binary is named 'cratedocs' according to Cargo.toml
  postInstall = ''
        # List what was actually installed
        echo "Contents of $out/bin/:"
        ls -la $out/bin/ || echo "No bin directory found"

        # Only create wrapper if binary exists
        if [ -f "$out/bin/cratedocs" ]; then
          # Rename original binary
          mv "$out/bin/cratedocs" "$out/bin/cratedocs-unwrapped"

          # Create wrapper script
          cat > "$out/bin/cratedocs" << 'EOF'
    #!/usr/bin/env bash

    # Set up runtime environment for MCP server
    export CRATEDOCS_CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/cratedocs"
    export CRATEDOCS_CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/cratedocs"

    # Create necessary directories for cache and configuration
    mkdir -p "$CRATEDOCS_CACHE_DIR" "$CRATEDOCS_CONFIG_DIR"

    # Execute the actual cratedocs binary as MCP server
    exec "$(dirname "$0")/cratedocs-unwrapped" "$@"
    EOF
          chmod +x "$out/bin/cratedocs"
          echo "Created wrapper for cratedocs binary"
        else
          echo "ERROR: cratedocs binary not found after installation!"
          exit 1
        fi
  '';

  meta = with pkgs.lib; {
    description = "Rust Documentation MCP Server for LLM crate assistance";
    homepage = "https://github.com/promptexecution/cratedocs-mcp";
    license = licenses.mit;
    maintainers = [];
    mainProgram = "cratedocs";
    platforms = platforms.all;
  };
}

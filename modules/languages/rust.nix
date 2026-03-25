{
  pkgs,
  inputs,
  lib,
}:
# Rust development tools and environment
# Provides everything needed for Rust development including toolchain and optimization tools
let
  devPkgs = import ../../pkgs {inherit pkgs;};

  # Use rust-overlay to create unified toolchain for RustRover
  # pkgs already has rust-overlay applied from default.nix
  # Specify Rust version 1.90.0
  rustToolchain = pkgs.rust-bin.stable."1.90.0".default.override {
    extensions = ["rust-src" "rust-analyzer" "clippy" "rustfmt"];
  };
in {
  meta = {
    name = "rust";
    description = "Rust 1.90.0 development environment";
    category = "language";
  };

  packages = [
    # Core Rust toolchain (unified from rust-overlay)
    rustToolchain

    # Common Rust development utilities
    pkgs.cargo-watch # Auto-rebuild on file changes
    pkgs.cargo-edit # cargo add/rm commands
    pkgs.cargo-outdated # Check for outdated dependencies
    pkgs.cargo-audit # Security audit

    # Testing and benchmarking
    pkgs.cargo-nextest # Fast test runner
    pkgs.cargo-criterion # Benchmarking

    # Cross-compilation and platforms
    pkgs.cargo-cross # Cross-compilation made easy

    # Performance and optimization tools
    pkgs.sccache # Compilation cache for faster builds
    pkgs.cargo-flamegraph # Generate flamegraphs from Rust code
    pkgs.perf
    pkgs.binutils # Provides addr2line for flamegraph symbol resolution
    pkgs.elfutils # Better DWARF parsing support
    pkgs.cargo-machete # Find unused dependencies
    pkgs.cargo-bloat # Analyze binary size and identify bloat
    pkgs.cargo-llvm-lines # Count LLVM IR lines for compile-time analysis

    # Code analysis tools
    pkgs.cargo-modules
    pkgs.graphviz
    pkgs.cargo-depgraph
    pkgs.cargo-tarpaulin
    pkgs.rust-code-analysis # Metrics and complexity analysis
    pkgs.jq # JSON processor for parsing analysis output

    # MCP (Model Context Protocol) tools
    devPkgs.cargo-mcp # MCP server for Cargo operations
    devPkgs.cratedocs-mcp # Rust documentation MCP server
    devPkgs.puppeteer-mcp-server # Browser automation MCP server

    # Build optimization dependencies
    pkgs.lld # Fast linker
    pkgs.clang # C compiler (needed for lld and some builds)
    pkgs.gcc # Provides 'cc' for ring and other crates

    # dependencies for rust
    pkgs.pkg-config
    pkgs.openssl.dev
  ];

  shellHook = ''
    echo " Rust toolchain ready!"
    echo "   cargo --version: $(cargo --version)"
    echo "   rustc --version: $(rustc --version)"
    echo ""

    # RustRover setup: Start RustRover from this shell (oktola's approach)
    # Configure toolchain in Settings → Rust, pointing to rust-toolchain in PATH
    # For stdlib sources, use the same path but remove /bin suffix
    echo " Rust toolchain location: ${rustToolchain}"

    # Generate .cargo/config.toml for RustRover (which doesn't inherit all env vars)
    # Only generate if it doesn't exist to avoid overwriting user customizations

    # Set up sccache for compilation caching
    export RUSTC_WRAPPER=sccache
    export SCCACHE_DIR="$HOME/.cache/sccache"
    mkdir -p "$SCCACHE_DIR"
    echo " sccache enabled at $SCCACHE_DIR"

    # Add Nix cache optimization
    export NIX_CONFIG="extra-substituters = https://cache.nixos.org https://nix-community.cachix.org"

    # cargo-mcp status
    echo " MCP tools ready:"
    echo "   ✅ cargo-mcp: $(cargo-mcp --version)"
    echo "      Built with nightly Rust for unstable feature support"

    echo ""
    echo " Quick commands:"
    echo "   cargo new <project>     # Create new Rust project"
    echo "   cargo check             # Check code for errors"
    echo "   cargo test              # Run tests"
    echo "   cargo run               # Build and run"
    echo ""
    echo " Optimization tools:"
    echo "   cargo flamegraph        # Generate CPU flamegraphs"
    echo "   cargo machete           # Find unused dependencies"
    echo "   cargo bloat             # Analyze binary size"
    echo "   cargo llvm-lines        # Count LLVM IR lines"
    echo "   tokei                   # Count lines of code (from base tools)"
    echo "   sccache --show-stats    # Show compilation cache stats"
    echo ""
    echo " Analysis tools:"
    echo "   cargo deps              # Create dependency graphs"
    echo "   cargo modules           # Analyze binary size"
    echo ""
    echo " MCP tools:"
    echo "   cargo-mcp               # MCP server for Cargo operations"
    echo "   cratedocs               # Rust documentation MCP server"
    echo "   mcp-server-puppeteer    # Browser automation MCP server"
    echo ""
  '';

  env = {
    RUST_BACKTRACE = "1";
  };

  suggestedMcps = ["cargo" "cratedocs"];
}

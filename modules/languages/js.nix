{
  pkgs,
  inputs,
  lib,
}:
# JavaScript/TypeScript development tools and environment
# Provides a modern JS/TS/React development setup with fast tooling and quality checks
{
  meta = {
    name = "js";
    description = "JavaScript/TypeScript development environment with Node.js 22";
    category = "language";
  };

  packages = [
    # Core Node.js runtime
    pkgs.nodejs_22

    # Package managers (npm is bundled with nodejs_22)
    pkgs.pnpm # Fast, disk-efficient package manager

    # Language server and tooling (Biome - modern Rust-based toolchain)
    pkgs.biome # LSP, formatter, and linter in one (replaces ESLint, Prettier partially)

    # Additional formatting (Prettier for full ecosystem support)
    pkgs.prettier # Code formatter

    # Type checking
    pkgs.typescript # TypeScript compiler and type checker
    pkgs.typescript-language-server # TypeScript language server (backup LSP)

    # Build and development tools
    pkgs.vite # Fast build tool and dev server (standalone package)

    # Code quality
    pkgs.eslint # Linter (for projects using ESLint config)

    # Development utilities
    pkgs.nodemon # Auto-restart on file changes
    pkgs.npm-check-updates # Update dependencies

    # System dependencies for native modules
    pkgs.stdenv.cc.cc.lib
    pkgs.python3 # Required for node-gyp
    pkgs.pkg-config
  ];

  shellHook = ''
    echo "🟨 JavaScript/TypeScript development environment ready!"
    echo "   node --version: $(node --version)"
    echo "   npm --version: $(npm --version)"
    echo "   pnpm --version: $(pnpm --version)"
    echo ""

    # Set up npm and pnpm cache directories
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PNPM_HOME="$HOME/.local/share/pnpm"
    mkdir -p "$NPM_CONFIG_PREFIX" "$PNPM_HOME"
    export PATH="$NPM_CONFIG_PREFIX/bin:$PNPM_HOME:$PATH"

    # Configure for native module builds
    export npm_config_build_from_source=true
    export PYTHON="${pkgs.python3}/bin/python"

    # Set up library paths for native modules
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"

    echo "⚡ Package managers configured"
    echo "   NPM cache: $NPM_CONFIG_PREFIX"
    echo "   PNPM home: $PNPM_HOME"
    echo ""

    # Check for package.json
    if [ -f "package.json" ]; then
      echo "📦 Project detected (package.json found)"

      if [ ! -d "node_modules" ]; then
        echo "   No node_modules found. Install with:"
        echo "   npm install    (or)    pnpm install"
        echo ""
      else
        echo "   ✅ node_modules found"
        echo ""
      fi
    fi

    echo "🔧 Development tools:"
    echo "   ✅ biome: Modern LSP, formatter & linter (Helix-compatible)"
    echo "   ✅ prettier: Code formatter"
    echo "   ✅ typescript: Type checking for JS/TS"
    echo "   ✅ vite: Fast build tool and dev server"
    echo ""

    echo "💡 Quick commands:"
    echo "   npm init / pnpm init       # Initialize new project"
    echo "   npm install / pnpm install # Install dependencies"
    echo "   pnpm add <pkg>             # Add package (faster than npm)"
    echo "   pnpm add -D vitest         # Add vitest for testing"
    echo "   npm run <script>           # Run package.json script"
    echo ""

    echo "🎨 Code quality:"
    echo "   biome check .              # Lint and format check (fast!)"
    echo "   biome check --write .      # Auto-fix issues"
    echo "   biome format .             # Format code"
    echo "   prettier --write .         # Format with Prettier"
    echo "   tsc --noEmit               # Type check TypeScript"
    echo ""

    echo "🚀 Development:"
    echo "   vite                       # Start Vite dev server"
    echo "   vite build                 # Build for production"
    echo "   nodemon index.js           # Auto-restart on changes"
    echo ""

    echo "📦 Package management tips:"
    echo "   - pnpm is faster and more disk-efficient than npm"
    echo "   - Use 'pnpm install --frozen-lockfile' in CI"
    echo "   - Biome is much faster than ESLint for linting"
    echo "   - Install test frameworks (vitest, jest) per-project"
    echo ""
  '';

  suggestedMcps = ["serena"];
}

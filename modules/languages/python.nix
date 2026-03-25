{
  pkgs,
  inputs,
  lib,
}:
# Python development tools and environment with UV package manager
# Provides a modern Python development setup with fast dependency management and quality tools
{
  meta = {
    name = "python";
    description = "Python 3.12 development environment with UV";
    category = "language";
  };

  packages = [
    # Core Python runtime
    pkgs.python312

    # UV - Modern, fast Python package and project manager
    pkgs.uv

    # LSP server for neovim integration
    pkgs.basedpyright

    # Development tools
    pkgs.ruff # Extremely fast Python linter and formatter (replaces black, isort, flake8, pylint)
    pkgs.mypy # Static type checker for Python
    pkgs.python312Packages.pytest # Testing framework
    pkgs.python312Packages.pytest-cov # Coverage plugin for pytest
    pkgs.python312Packages.pytest-xdist # Parallel test execution
    pkgs.python312Packages.pytest-asyncio # Async test support
    pkgs.python312Packages.coverage # Code coverage measurement

    # Code quality and analysis
    pkgs.bandit # Security linter for Python
    pkgs.python312Packages.vulture # Find dead Python code
    pkgs.python312Packages.pydocstyle # Docstring style checker
    pkgs.python312Packages.pyupgrade # Automatically upgrade syntax for newer Python versions

    # Performance profiling
    pkgs.py-spy # Sampling profiler for Python
    # memray and scalene might not be available in nixpkgs, commenting out for now
    # pkgs.python312Packages.memray # Memory profiler
    # pkgs.python312Packages.scalene # High-performance CPU and memory profiler

    # Documentation tools
    pkgs.python312Packages.mkdocs # Project documentation with Markdown
    pkgs.python312Packages.mkdocs-material # Material theme for MkDocs
    pkgs.python312Packages.pdoc3 # Auto-generate Python API documentation

    # Build tools
    pkgs.python312Packages.build # PEP 517 package builder
    pkgs.python312Packages.twine # Upload packages to PyPI
    pkgs.python312Packages.wheel # Wheel packaging format

    # System dependencies for common Python packages with C extensions
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
    pkgs.openssl.dev
    pkgs.libffi
    pkgs.postgresql # For psycopg2 and similar
    pkgs.mysql80 # For mysqlclient
    pkgs.pkg-config
  ];

  shellHook = ''
    echo " Python development environment ready!"
    echo "   python --version: $(python --version 2>&1)"
    echo "   uv --version: uv $(uv --version | cut -d' ' -f2)"
    echo ""

    # Set up UV to use Nix-provided Python
    export UV_PYTHON="${pkgs.python312}/bin/python"
    export UV_CACHE_DIR="$HOME/.cache/uv"
    mkdir -p "$UV_CACHE_DIR"

    # Set up library paths for packages with C extensions
    # Note: OpenSSL is intentionally excluded from LD_LIBRARY_PATH to avoid breaking
    # system binaries like curl that may be linked against a different OpenSSL version.
    # Python packages should use rpath for OpenSSL linking at runtime.
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zlib}/lib:$LD_LIBRARY_PATH"

    # Configure build environment for packages that compile C extensions
    export CFLAGS="-I${pkgs.zlib.dev}/include -I${pkgs.openssl.dev}/include"
    export LDFLAGS="-L${pkgs.zlib}/lib -L${pkgs.openssl.out}/lib"
    export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.zlib.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"

    echo " UV package manager configured"
    echo "   Cache: $UV_CACHE_DIR"
    echo "   Python: ${pkgs.python312}/bin/python"
    echo ""

    # Check for virtual environment
    if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
      if [ ! -d ".venv" ]; then
        echo " No virtual environment found. Create one with:"
        echo "   uv venv"
        echo ""
      else
        echo " Virtual environment detected at .venv"
        echo "   Activate with: source .venv/bin/activate"
        echo ""
      fi
    fi

    echo " Development tools:"
    echo "   ✅ ruff: Fast Python linter and formatter"
    echo "   ✅ mypy: Static type checker"
    echo "   ✅ pytest: Testing framework with coverage support"
    echo "   ✅ bandit: Security vulnerability scanner"
    echo "   ✅ py-spy: Performance profiler"
    echo ""

    echo " Quick commands:"
    echo "   uv init                    # Initialize new Python project"
    echo "   uv venv                    # Create virtual environment"
    echo "   source .venv/bin/activate  # Activate virtual environment"
    echo "   uv pip install -r requirements.txt  # Install from requirements"
    echo "   uv pip install package     # Install a package"
    echo "   uv pip compile requirements.in > requirements.txt  # Lock dependencies"
    echo "   uv pip sync requirements.txt  # Sync exact dependencies"
    echo ""

    echo " Testing:"
    echo "   pytest                     # Run all tests"
    echo "   pytest -v --cov=.          # Run with coverage"
    echo "   pytest -n auto             # Run tests in parallel"
    echo ""

    echo " Code quality:"
    echo "   ruff check .               # Lint code (replaces flake8, pylint, etc.)"
    echo "   ruff format .              # Format code (replaces black, isort)"
    echo "   mypy .                     # Type check code"
    echo "   bandit -r .                # Security scan"
    echo "   vulture .                  # Find dead code"
    echo "   pyupgrade --py312-plus     # Upgrade syntax to Python 3.12+"
    echo ""

    echo " Profiling:"
    echo "   py-spy record -o profile.svg -- python script.py  # CPU profiling"
    echo ""

    echo " Documentation:"
    echo "   mkdocs new .               # Create new docs project"
    echo "   mkdocs serve               # Serve docs locally"
    echo "   mkdocs build               # Build docs"
    echo "   pdoc --html --output-dir docs module  # Generate API docs"
    echo ""

    echo " Package management tips:"
    echo "   - UV is 10-100x faster than pip"
    echo "   - Use 'uv pip compile' for reproducible dependencies"
    echo "   - UV caches packages globally for speed"
    echo "   - Compatible with pip requirements files"
    echo ""
  '';

  suggestedMcps = ["serena"];
}

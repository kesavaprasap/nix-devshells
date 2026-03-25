{
  pkgs,
  inputs,
  lib,
}:
# C++ development tools and environment
# Provides everything needed for modern C++ development including compilers, build systems, and analysis tools
{
  meta = {
    name = "cpp";
    description = "C++ development environment with GCC and Clang";
    category = "language";
  };

  packages = [
    # Core C++ toolchain - both GCC and Clang for flexibility
    pkgs.gcc14
    pkgs.clang_18
    pkgs.llvmPackages_18.bintools # LLVM tools like lld linker

    # Build systems
    pkgs.cmake
    pkgs.cmakeWithGui # CMake GUI for visual configuration
    pkgs.ninja # Fast build system
    pkgs.meson # Alternative modern build system
    pkgs.gnumake # Traditional make

    # Package managers for C++
    pkgs.conan # C++ package manager
    pkgs.vcpkg # Microsoft's C++ package manager
    pkgs.pkg-config # Library discovery tool

    # Development tools

    pkgs.llvmPackages_18.clang-tools # Includes clangd, clang-format, clang-tidy
    pkgs.ccache # Compilation cache for faster rebuilds
    pkgs.distcc # Distributed compilation (optional)

    # Debugging and profiling
    pkgs.gdb # GNU debugger
    pkgs.lldb_18 # LLVM debugger
    pkgs.valgrind # Memory analysis
    pkgs.heaptrack # Heap memory profiler
    pkgs.hotspot # GUI for performance analysis
    pkgs.perf-tools # Performance analysis tools

    # Static analysis and code quality
    pkgs.cppcheck # Static analysis tool
    pkgs.include-what-you-use # Include optimization
    pkgs.cpplint # Google's C++ style checker
    pkgs.bear # Build command database generator

    # Documentation generation
    pkgs.doxygen # Documentation generator
    pkgs.graphviz # For dependency graphs in docs

    # Testing frameworks (header-only, for reference)
    pkgs.catch2 # Modern C++ testing framework
    pkgs.gtest # Google Test framework
    pkgs.gbenchmark # Google's microbenchmark library

    # Common libraries often needed
    pkgs.boost # Boost C++ libraries
    pkgs.fmt # Modern formatting library
    pkgs.spdlog # Fast C++ logging library
    pkgs.eigen # Linear algebra library
    pkgs.nlohmann_json # JSON for Modern C++

    # Build optimization
    pkgs.lld_18 # Fast LLVM linker
    pkgs.mold # Even faster modern linker
  ];

  shellHook = ''
    echo " C++ development environment ready!"
    echo "   gcc --version: $(gcc --version | head -n1)"
    echo "   clang --version: $(clang --version | head -n1)"
    echo "   cmake --version: $(cmake --version | head -n1)"
    echo ""

    # Set up ccache for compilation caching
    export CC="ccache gcc"
    export CXX="ccache g++"
    export CCACHE_DIR="$HOME/.cache/ccache"
    mkdir -p "$CCACHE_DIR"
    echo " ccache enabled at $CCACHE_DIR"
    echo "   Use 'ccache -s' to see statistics"
    echo ""

    # Configure for better debugging
    export CXXFLAGS="-g -O0 -fno-omit-frame-pointer"
    export CFLAGS="-g -O0 -fno-omit-frame-pointer"
    echo " Debug symbols enabled by default (override with your own CXXFLAGS)"
    echo ""

    echo " Available compilers:"
    echo "   ✅ gcc ${pkgs.gcc14.version} (default via ccache)"
    echo "   ✅ clang ${pkgs.clang_18.version}"
    echo "   Switch with: export CC=clang CXX=clang++"
    echo ""

    echo " Build systems:"
    echo "   ✅ cmake ${pkgs.cmake.version}"
    echo "   ✅ ninja ${pkgs.ninja.version}"
    echo "   ✅ meson ${pkgs.meson.version}"
    echo "   ✅ make ${pkgs.gnumake.version}"
    echo ""

    echo " Package managers:"
    echo "   ✅ conan $(conan --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "2.x")"
    echo "   ✅ vcpkg (use: vcpkg search/install)"
    echo ""

    echo " Development tools:"
    echo "   ✅ clangd: LSP server for IDE integration"
    echo "   ✅ clang-format: Code formatter"
    echo "   ✅ clang-tidy: Static analyzer"
    echo "   ✅ cppcheck: Additional static analysis"
    echo "   ✅ include-what-you-use: Header optimization"
    echo ""

    echo " Debugging & Profiling:"
    echo "   ✅ gdb: GNU debugger"
    echo "   ✅ lldb: LLVM debugger"
    echo "   ✅ valgrind: Memory analysis"
    echo "   ✅ heaptrack: Heap profiling"
    echo "   ✅ hotspot: Performance analysis GUI"
    echo ""

    echo " Quick commands:"
    echo "   cmake -B build -G Ninja    # Configure with Ninja"
    echo "   cmake --build build        # Build project"
    echo "   ctest --test-dir build     # Run tests"
    echo "   clang-format -i *.cpp      # Format code"
    echo "   clang-tidy *.cpp           # Run static analysis"
    echo "   cppcheck --enable=all .    # Additional checks"
    echo "   bear -- make               # Generate compile_commands.json"
    echo "   ccache -s                  # Show cache statistics"
    echo ""

    echo " Performance tips:"
    echo "   - Use 'mold' linker: -fuse-ld=mold"
    echo "   - Use 'lld' linker: -fuse-ld=lld"
    echo "   - Enable LTO: -flto"
    echo "   - Profile-guided optimization: -fprofile-generate/-fprofile-use"
    echo ""
  '';

  suggestedMcps = ["serena"];
}

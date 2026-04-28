{
  pkgs,
  inputs,
  lib,
}:
# PHP development tools and environment
# Provides everything needed for PHP development including interpreter, extensions, and tools
let
  # PHP environment with common development extensions
  phpEnv = pkgs.php.buildEnv {
    extensions = {
      enabled,
      all,
    }:
      enabled
      ++ (with all; [
        # Development essentials
        xdebug # Debugging and profiling
        opcache # Performance optimization

        # Database connectivity
        pdo_mysql # MySQL PDO driver
        pdo_pgsql # PostgreSQL PDO driver
        pdo_sqlite # SQLite PDO driver
        mysqli # MySQL improved extension

        # Caching and session
        redis # Redis support
        memcached # Memcached support

        # Image processing
        imagick # ImageMagick binding
        gd # GD graphics library

        # Data formats
        curl # HTTP client
        xml # XML processing
        zip # Archive handling

        # Development utilities
        mbstring # Multibyte string support
        intl # Internationalization
        bcmath # Arbitrary precision mathematics
      ]);

    # Development-optimized configuration
    extraConfig = ''
      ; Development settings
      memory_limit = -1
      max_execution_time = 0
      display_errors = On
      display_startup_errors = On
      error_reporting = E_ALL
      log_errors = On

      ; Xdebug configuration for development
      xdebug.mode = debug,develop,coverage
      xdebug.start_with_request = yes
      xdebug.client_host = localhost
      xdebug.client_port = 9003

      ; Opcache settings for development
      opcache.enable = 1
      opcache.enable_cli = 1
      opcache.validate_timestamps = 1
      opcache.revalidate_freq = 0
    '';
  };
in {
  meta = {
    name = "php";
    description = "PHP development environment with extensions";
    category = "language";
  };

  packages = [
    # Core PHP with extensions
    phpEnv

    # Package management
    phpEnv.packages.composer

    # Framework tools
    pkgs.symfony-cli

    # Code quality and analysis
    # Note: php-cs-fixer is best installed via composer
    # as it is marked broken or unavailable in nixpkgs
    phpEnv.packages.php-codesniffer # PHP_CodeSniffer for style checking
    pkgs.phpstan # Static analysis tool

    # Development utilities
    pkgs.nodejs # For frontend asset compilation (npm is bundled with nodejs)

    # Database tools
    pkgs.mysql84 # MySQL client
    pkgs.postgresql # PostgreSQL client
    pkgs.sqlite # SQLite client

    # Web server for development
    pkgs.caddy # Modern web server with automatic HTTPS
  ];

  shellHook = ''
    echo "🐘 PHP development environment ready!"
    echo "   php --version: $(php --version | head -n1)"
    echo "   composer --version: $(composer --version)"
    echo ""

    # Display enabled extensions
    echo "🔧 Enabled PHP extensions:"
    php -m | grep -E "(xdebug|opcache|redis|imagick|pdo_|mysqli)" | sed 's/^/   ✅ /'
    echo ""

    echo "🌐 Web development tools:"
    echo "   ✅ symfony-cli: $(symfony version --no-ansi)"
    echo "   ✅ caddy: $(caddy version)"
    echo "   ✅ nodejs: $(node --version)"
    echo ""

    echo "📊 Database clients:"
    echo "   ✅ mysql: $(mysql --version | cut -d' ' -f1-5)"
    echo "   ✅ postgresql: $(psql --version)"
    echo "   ✅ sqlite: $(sqlite3 --version | cut -d' ' -f1)"
    echo ""

    echo "🔍 Code quality tools:"
    echo "   ✅ phpcs: $(phpcs --version 2>/dev/null || echo "Install via: composer require --dev squizlabs/php_codesniffer")"
    echo "   ✅ phpstan: $(phpstan --version 2>/dev/null || echo "not found")"
    echo "   📦 php-cs-fixer: Install via: composer require --dev friendsofphp/php-cs-fixer"
    echo "   📦 parallel-lint: Install via: composer require --dev php-parallel-lint/php-parallel-lint"
    echo ""

    echo "💡 Quick commands:"
    echo "   composer create-project <package> <dir>  # Create new project"
    echo "   composer install                         # Install dependencies"
    echo "   composer require <package>               # Add dependency"
    echo "   symfony new <project> --webapp           # Create Symfony project"
    echo "   php -S localhost:8000                    # Built-in dev server"
    echo "   caddy file-server --browse               # Static file server"
    echo ""

    echo "🔧 Additional tools (install via composer):"
    echo "   composer require --dev friendsofphp/php-cs-fixer"
    echo "   composer require --dev php-parallel-lint/php-parallel-lint"
    echo ""

    echo "🐛 Debugging:"
    echo "   Xdebug enabled on port 9003"
    echo "   Set breakpoints in your IDE and start debugging!"
    echo ""
  '';

  suggestedMcps = [];
}

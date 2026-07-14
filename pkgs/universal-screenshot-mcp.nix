{
  pkgs,
  stdenv ? pkgs.stdenv,
  fetchurl ? pkgs.fetchurl,
  nodejs_20 ? pkgs.nodejs_20,
  chromium ? pkgs.chromium,
  maim ? pkgs.maim,
  xdotool ? pkgs.xdotool,
  cacert ? pkgs.cacert,
}: let
  pname = "universal-screenshot-mcp";
  version = "1.0.0";

  # Fetch npm dependencies in a fixed-output derivation (allows network)
  npmDeps = stdenv.mkDerivation {
    name = "${pname}-${version}-npm-deps";

    src = fetchurl {
      url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
      hash = "sha256-UMpI4SKi8HZd6ubvxj1eWOR61wvy0lTXYiTQl0FSh/E=";
    };

    nativeBuildInputs = [nodejs_20 cacert];

    unpackPhase = ''
      mkdir -p package
      tar -xzf $src -C package --strip-components=1
    '';

    buildPhase = ''
      cd package
      export HOME=$TMPDIR
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
      npm install --omit=dev --ignore-scripts
    '';

    installPhase = ''
      cp -r node_modules $out
    '';

    outputHashMode = "recursive";
    outputHash = "sha256-mtezMBf+iHiWjp7zYsTW1Rh105Pj2TttinN+DaeNAeg=";
  };
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
      hash = "sha256-UMpI4SKi8HZd6ubvxj1eWOR61wvy0lTXYiTQl0FSh/E=";
    };

    dontBuild = true;

    unpackPhase = ''
      mkdir -p package
      tar -xzf $src -C package --strip-components=1
    '';

    installPhase = ''
          mkdir -p $out/lib/node_modules/${pname}

          cp -r package/build/ $out/lib/node_modules/${pname}/
          cp -r ${npmDeps}/ $out/lib/node_modules/${pname}/node_modules
          cp package/package.json $out/lib/node_modules/${pname}/

          chmod +x $out/lib/node_modules/${pname}/build/index.js

          mkdir -p $out/bin
          cat > $out/bin/universal-screenshot-mcp << EOF
      #!/usr/bin/env bash
      export NODE_PATH="$out/lib/node_modules/${pname}/node_modules:$out/lib/node_modules"

      # Puppeteer environment
      export PUPPETEER_CACHE_DIR="\''${XDG_CACHE_HOME:-\$HOME/.cache}/puppeteer"
      export PUPPETEER_SKIP_DOWNLOAD=1
      export PUPPETEER_EXECUTABLE_PATH="${chromium}/bin/chromium"

      # Ensure screenshot tools are in PATH for Linux system screenshots
      export PATH="${maim}/bin:${xdotool}/bin:\$PATH"

      mkdir -p "\$PUPPETEER_CACHE_DIR"

      exec ${nodejs_20}/bin/node "$out/lib/node_modules/${pname}/build/index.js" "\$@"
      EOF
          chmod +x $out/bin/universal-screenshot-mcp
    '';

    meta = with pkgs.lib; {
      description = "MCP server for web page and cross-platform system screenshots";
      homepage = "https://github.com/sethbang/mcp-screenshot-server";
      license = licenses.asl20;
      maintainers = [];
      mainProgram = "universal-screenshot-mcp";
      platforms = platforms.linux ++ platforms.darwin;
    };
  }

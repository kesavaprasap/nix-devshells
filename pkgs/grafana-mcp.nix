{
  lib,
  pkgs,
  fetchurl,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "mcp-grafana";
  version = "0.17.1";

  src = fetchurl {
    url = "https://github.com/grafana/mcp-grafana/releases/download/v${version}/mcp-grafana_Linux_x86_64.tar.gz";
    hash = "sha256-1sLbBsFhd+720kt9U7VRXw4cn9IJMXqe2GeIRZjHY7M=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [pkgs.autoPatchelfHook];

  installPhase = ''
    runHook preInstall
    install -Dm755 mcp-grafana $out/bin/mcp-grafana
    runHook postInstall
  '';

  meta = {
    description = "MCP server for Grafana — query dashboards, datasources, and alerts via Claude";
    homepage = "https://github.com/grafana/mcp-grafana";
    license = lib.licenses.asl20;
    mainProgram = pname;
    platforms = ["x86_64-linux"];
  };
}
